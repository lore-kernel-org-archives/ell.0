Received: from mail-ed1-f45.google.com (mail-ed1-f45.google.com [209.85.208.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3B55D33E4
	for <ell@lists.linux.dev>; Mon,  7 Nov 2022 11:30:22 +0000 (UTC)
Received: by mail-ed1-f45.google.com with SMTP id 21so17068826edv.3
        for <ell@lists.linux.dev>; Mon, 07 Nov 2022 03:30:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=haLBDMsq0WtfBQH2Tp+q8Bvgt/UgTA9GLN2neLQOUvA=;
        b=BWEImbvFEcIO/VRTT4AFEKOxrHGThPyGx5ISEnvhlmBu7Pe6SBG5UAPHaXsX+0PFAL
         MgooKMGVJ9eAObsRnHiYa7uZUH0W3KW+WcWuB9ff468T74ds8ABNTvnWi/Mr9zFKBNU8
         p+F1IyGGOtH8R2fH4kpsVBX1eyNNAW1GJoDEUaufY9sNGD46HvZXX4Le8y3IlRlArPeW
         Li2t8IpYNOz7vHx9JmjU1W52WztmkKju5FggJ3nCbqwIOpp3Cn+6d8rifa0dweCQsuxw
         9st8zIeu8GZSj+s7kXPD3IHNECV3cxzIYgimGZi0TKb0AiQWHxeRl6XSveftzgvXuqwc
         pOVA==
X-Gm-Message-State: ACrzQf0JMQrHTe4nkG4FPIBEYPzT5Z8nU01eD3wiI0fOwFTsTHZoREkL
	iuYKA2mP/kTLJe8GPFcAORdaymS5XXs=
X-Google-Smtp-Source: AMsMyM4+dM8dGWbiMNw4oYFBLZFZrxJdrIm5CLv4dmxCoC6F5BJKFm2VczhufUvu+Jxe56L+ysi0dg==
X-Received: by 2002:a50:ccc2:0:b0:460:4db2:5006 with SMTP id b2-20020a50ccc2000000b004604db25006mr49909468edj.369.1667820619213;
        Mon, 07 Nov 2022 03:30:19 -0800 (PST)
Received: from iss.ger.corp.intel.com ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id x16-20020a170906135000b007ae32daf4b9sm3259769ejb.106.2022.11.07.03.30.17
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 07 Nov 2022 03:30:18 -0800 (PST)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 2/3] tls: Server mode session caching
Date: Mon,  7 Nov 2022 12:30:11 +0100
Message-Id: <20221107113012.328918-2-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20221107113012.328918-1-andrew.zaborowski@intel.com>
References: <20221107113012.328918-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Cache session states when they're established, load them when parsing
the ClientHello.  When loading first expire old sessions, look up the
requested session among those left and enforce the cache size limit by
dropping the oldest session if cache is over limit.
---
 ell/tls-private.h |   2 +
 ell/tls.c         | 343 ++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 305 insertions(+), 40 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index ce69553..a3a9393 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -260,6 +260,8 @@ struct l_tls {
 
 	uint8_t session_id[32];
 	size_t session_id_size;
+	uint8_t session_id_replaced[32];
+	size_t session_id_size_replaced;
 	bool session_id_new;
 	uint8_t session_cipher_suite_id[2];
 	uint8_t session_compression_method_id;
diff --git a/ell/tls.c b/ell/tls.c
index a28a455..98bc682 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -209,6 +209,7 @@ static void tls_reset_handshake(struct l_tls *tls)
 	tls->cert_sent = 0;
 
 	tls->session_id_size = 0;
+	tls->session_id_size_replaced = 0;
 	tls->session_id_new = false;
 	l_free(l_steal_ptr(tls->session_peer_identity));
 }
@@ -392,7 +393,7 @@ static void tls_reset_cipher_spec(struct l_tls *tls, bool txrx)
 	tls_change_cipher_spec(tls, txrx, NULL);
 }
 
-bool tls_cipher_suite_is_compatible(struct l_tls *tls,
+static bool tls_cipher_suite_is_compatible_no_key_xchg(struct l_tls *tls,
 					const struct tls_cipher_suite *suite,
 					const char **error)
 {
@@ -477,19 +478,6 @@ bool tls_cipher_suite_is_compatible(struct l_tls *tls,
 		return false;
 	}
 
-	if (suite->key_xchg->need_ffdh &&
-			!l_key_is_supported(L_KEY_FEATURE_DH)) {
-		if (error) {
-			*error = error_buf;
-			snprintf(error_buf, sizeof(error_buf),
-					"Cipher suite %s's key exchange "
-					"mechanism needs kernel DH support",
-					suite->name);
-		}
-
-		return false;
-	}
-
 	/*
 	 * If the certificate is compatible with the signature algorithm it
 	 * also must be compatible with the key exchange mechanism because
@@ -510,6 +498,38 @@ bool tls_cipher_suite_is_compatible(struct l_tls *tls,
 		return false;
 	}
 
+	return true;
+}
+
+/*
+ * Assumes that Client Hello extensions have been processed and that we
+ * will want to start a new session using this cipher suite, including the
+ * key exchange.  This is unlike tls_cipher_suite_is_compatible_no_key_xchg()
+ * which runs fewer checks and must succeed even for a cipher suite loaded
+ * during session resumption.
+ */
+bool tls_cipher_suite_is_compatible(struct l_tls *tls,
+					const struct tls_cipher_suite *suite,
+					const char **error)
+{
+	static char error_buf[200];
+
+	if (!tls_cipher_suite_is_compatible_no_key_xchg(tls, suite, error))
+		return false;
+
+	if (suite->key_xchg->need_ffdh &&
+			!l_key_is_supported(L_KEY_FEATURE_DH)) {
+		if (error) {
+			*error = error_buf;
+			snprintf(error_buf, sizeof(error_buf),
+					"Cipher suite %s's key exchange "
+					"mechanism needs kernel DH support",
+					suite->name);
+		}
+
+		return false;
+	}
+
 	/*
 	 * On the server we know what elliptic curve we'll be using as soon
 	 * as we've processed the ClientHello so for EC-based key exchange
@@ -933,8 +953,9 @@ static bool tls_load_cached_session(struct l_tls *tls, const char *group_name,
 	 * It is up to the user to keep multiple cache instances if it needs
 	 * to save multiple sessions.
 	 */
-	if (unlikely(!tls_cipher_suite_is_compatible(tls, cipher_suite,
-							&error))) {
+	if (unlikely(!tls_cipher_suite_is_compatible_no_key_xchg(tls,
+								cipher_suite,
+								&error))) {
 		TLS_DEBUG("Cached session %s cipher suite not compatible: %s",
 				session_id_str, error);
 		goto forget;
@@ -1019,6 +1040,118 @@ static bool tls_load_cached_client_session(struct l_tls *tls)
 					session_id_size, session_id_str);
 }
 
+static bool tls_load_cached_server_session(struct l_tls *tls,
+						const uint8_t *session_id,
+						size_t session_id_size)
+{
+	_auto_(l_free) char *session_id_str =
+		l_util_hexstring(session_id, session_id_size);
+	const char *target_group_name =
+		tls_get_cache_group_name(tls, session_id, session_id_size);
+	_auto_(l_strv_free) char **groups =
+		l_settings_get_groups(tls->session_settings);
+	char **group;
+	unsigned int cnt = 0;
+	size_t prefix_len = strlen(tls->session_prefix);
+	uint64_t now = time_realtime_now();
+	char *oldest_session_group = NULL;
+	uint64_t oldest_session_expiry = UINT64_MAX;
+	bool found = false;
+	bool changed = false;
+	bool loaded = false;
+
+	tls->session_id_size = 0;
+	tls->session_id_new = false;
+
+	/* Clean up expired entries and enforce session count limit */
+	for (group = groups; *group; group++) {
+		uint64_t expiry_time;
+
+		if (memcmp(*group, tls->session_prefix, prefix_len) ||
+				(*group)[prefix_len] != '-')
+			continue;
+
+		/* Group seems to be a session cache entry */
+
+		if (unlikely(!l_settings_get_uint64(tls->session_settings,
+							*group,
+							"SessionExpiryTime",
+							&expiry_time)) ||
+				expiry_time <= now) {
+			TLS_DEBUG("Cached session %s is expired or invalid, "
+					"purging entry",
+					*group + prefix_len + 1);
+			l_settings_remove_group(tls->session_settings, *group);
+			changed = true;
+		}
+
+		cnt++;
+
+		if (!strcmp(*group + prefix_len + 1,
+				target_group_name + prefix_len + 1)) {
+			found = true;
+			continue; /* Don't purge this entry */
+		}
+
+		if (expiry_time < oldest_session_expiry) {
+			oldest_session_group = *group;
+			oldest_session_expiry = expiry_time;
+		}
+	}
+
+	/*
+	 * Enforce tls->session_count_max by dropping the entry for the
+	 * oldest session (more specifically the one closest to its expiry
+	 * time) in the cache, that is not the session we're trying to
+	 * load.  If the target session was not found, do this as soon as
+	 * tls->session_count_max is reached rather than when it's exceeded
+	 * so as to make room for a new entry.  If we end up not saving
+	 * a new session due to an error before the handshake finish, we'll
+	 * be left with tls->session_count_max - 1 entries and will have
+	 * purged that entry unnecessarily but the cache will have room for
+	 * a future session.  Same when we did find the target session but
+	 * later had to forget it because of a fatal alert during or after
+	 * the handshake.
+	 *
+	 * If we did find the target session but we later find that we
+	 * can't resume it, we will forget it so the new session can take
+	 * the old session's place and the limit is not exceeded, see
+	 * discussion in tls_server_resume_error.
+	 */
+	if (tls->session_count_max && oldest_session_group &&
+			cnt >= tls->session_count_max + (found ? 1 : 0)) {
+		l_settings_remove_group(tls->session_settings,
+					oldest_session_group);
+		changed = true;
+	}
+
+	if (!found) {
+		TLS_DEBUG("Requested session %s not found in cache, will "
+				"start a new session", session_id_str);
+		goto call_back;
+	}
+
+	loaded = tls_load_cached_session(tls, target_group_name,
+						session_id, session_id_size,
+						session_id_str);
+
+	/*
+	 * If tls_load_cached_session() returned false it will have called
+	 * session_update_cb for us.
+	 */
+	if (!loaded)
+		changed = false;
+
+call_back:
+	if (changed && tls->session_update_cb) {
+		tls->in_callback = true;
+		tls->session_update_cb(tls->session_update_user_data);
+		tls->in_callback = false;
+	}
+
+	return loaded;
+}
+
 #define SWITCH_ENUM_TO_STR(val) \
 	case (val):		\
 		return L_STRINGIFY(val);
@@ -1068,10 +1201,11 @@ void tls_disconnect(struct l_tls *tls, enum l_tls_alert_desc desc,
 			enum l_tls_alert_desc local_desc)
 {
 	bool forget_session = false;
+	/* Save session_id_size before tls_reset_handshake() */
+	size_t session_id_size = tls->session_id_size;
 
-	if (!tls->server && (desc || local_desc) &&
-			tls->session_settings && tls->session_id_size &&
-			!tls->session_id_new)
+	if ((desc || local_desc) && tls->session_settings &&
+			session_id_size && !tls->session_id_new)
 		/*
 		 * RFC5246 Section 7.2: "Alert messages with a level of fatal
 		 * result in the immediate termination of the connection.  In
@@ -1299,7 +1433,12 @@ static bool tls_send_server_hello(struct l_tls *tls, struct l_queue *extensions)
 	memcpy(ptr, tls->pending.server_random, 32);
 	ptr += 32;
 
-	*ptr++ = 0; /* Sessions are not cached */
+	if (tls->session_id_size) {
+		*ptr++ = tls->session_id_size;
+		memcpy(ptr, tls->session_id, tls->session_id_size);
+		ptr += tls->session_id_size;
+	} else
+		*ptr++ = 0;
 
 	*ptr++ = tls->pending.cipher_suite->id[0];
 	*ptr++ = tls->pending.cipher_suite->id[1];
@@ -1825,6 +1964,33 @@ decode_error:
 	return false;
 }
 
+static void tls_server_resume_error(struct l_tls *tls)
+{
+	/*
+	 * When Client Hello parameters don't match the parameters of the
+	 * cached session that was requested by the client, we'll probably
+	 * start and cache a new session.  Even though RFC 5246 doesn't
+	 * specifically mandate that the requested session be forgotten
+	 * (there's no fatal Alert in that case), we overwrite the old
+	 * session's entry in the cache with the new session's data to
+	 * avoid keeping many sessions related to one client in the cache.
+	 * In theory this allows an attacker to connect as a client and
+	 * invalidate a legitimate client's session entry in our cache,
+	 * DoSing the session resumption mechanism so that clients have
+	 * to go through the full handshake.  In practice there are many
+	 * ways for an attacker to do that even without this.
+	 *
+	 * Our client mode only caches one last session anyway, other
+	 * implementations may work that way too.
+	 */
+	memcpy(tls->session_id_replaced, tls->session_id, tls->session_id_size);
+	tls->session_id_size_replaced = tls->session_id_size;
+
+	tls->session_id_size = 0;
+	tls->session_id_new = false;
+	l_free(l_steal_ptr(tls->session_peer_identity));
+}
+
 static void tls_handle_client_hello(struct l_tls *tls,
 					const uint8_t *buf, size_t len)
 {
@@ -1835,6 +2001,10 @@ static void tls_handle_client_hello(struct l_tls *tls,
 	int i;
 	struct l_queue *extensions_offered = NULL;
 	enum l_tls_alert_desc alert_desc = TLS_ALERT_HANDSHAKE_FAIL;
+	bool resuming = false;
+	_auto_(l_free) char *session_id_str = NULL;
+	struct tls_cipher_suite *backup_suite = NULL;
+	struct tls_compression_method *backup_cm = NULL;
 
 	/* Do we have enough for ProtocolVersion + Random + SessionID size? */
 	if (len < 2 + 32 + 1)
@@ -1844,6 +2014,9 @@ static void tls_handle_client_hello(struct l_tls *tls,
 	session_id_size = buf[34];
 	len -= 35;
 
+	if (unlikely(session_id_size > 32))
+		goto decode_error;
+
 	/*
 	 * Do we have enough to hold the actual session ID + 2 byte field for
 	 * cipher_suite len + minimum of a single cipher suite identifier
@@ -1876,6 +2049,24 @@ static void tls_handle_client_hello(struct l_tls *tls,
 
 	len -= compression_methods_size;
 
+	if (session_id_size && tls->session_settings &&
+			tls_load_cached_server_session(tls, buf + 35,
+							session_id_size)) {
+		/*
+		 * Attempt a session resumption but don't skip parsing Hello
+		 * extensions just yet because we may decide to start a new
+		 * session instead after our cipher suite and compression
+		 * method checks below and in that case we will need to
+		 * handle the extensions and include them in the Server Hello.
+		 */
+		resuming = true;
+		session_id_str = l_util_hexstring(tls->session_id,
+							tls->session_id_size);
+	}
+
+	if (tls->pending_destroy)
+		return;
+
 	extensions_offered = l_queue_new();
 
 	if (!tls_handle_hello_extensions(tls, compression_methods +
@@ -1883,13 +2074,6 @@ static void tls_handle_client_hello(struct l_tls *tls,
 					len, extensions_offered))
 		goto cleanup;
 
-	/*
-	 * Note: if the client is supplying a SessionID we know it is false
-	 * because our server implementation never generates any SessionIDs
-	 * yet so either the client is attempting something strange or was
-	 * trying to connect somewhere else.  We might want to throw an error.
-	 */
-
 	/* Save client_version for Premaster Secret verification */
 	tls->client_version = l_get_be16(buf);
 
@@ -1944,6 +2128,16 @@ static void tls_handle_client_hello(struct l_tls *tls,
 			alert_desc = TLS_ALERT_INSUFFICIENT_SECURITY;
 			TLS_DEBUG("non-fatal: Cipher suite %s disallowed "
 					"by config", suite->name);
+		} else if (resuming && memcmp(tls->session_cipher_suite_id,
+						suite->id, 2)) {
+			/*
+			 * For now skip this cipher suite because we're trying
+			 * to find the one from the cached session state.  But
+			 * keep it as a backup in case we end up starting a new
+			 * session.
+			 */
+			if (!backup_suite)
+				backup_suite = suite;
 		} else {
 			tls->pending.cipher_suite = suite;
 			break;
@@ -1953,7 +2147,15 @@ static void tls_handle_client_hello(struct l_tls *tls,
 		cipher_suites_size -= 2;
 	}
 
-	if (!cipher_suites_size) {
+	if (unlikely(!cipher_suites_size && backup_suite)) {
+		TLS_DEBUG("Cached session %s's cipher suite %04x "
+				"unavailable, will start a new session",
+				session_id_str,
+				l_get_be16(tls->session_cipher_suite_id));
+		tls->pending.cipher_suite = backup_suite;
+		resuming = false;
+		tls_server_resume_error(tls);
+	} else if (unlikely(!cipher_suites_size)) {
 		TLS_DISCONNECT(alert_desc, 0,
 				"No common cipher suites matching negotiated "
 				"TLS version and our certificate's key type");
@@ -1966,35 +2168,88 @@ static void tls_handle_client_hello(struct l_tls *tls,
 		goto cleanup;
 	}
 
-	TLS_DEBUG("Negotiated %s", tls->pending.cipher_suite->name);
-
 	/* Select a compression method */
 
 	/* CompressionMethod.null must be present in the vector */
 	while (compression_methods_size) {
-		tls->pending.compression_method =
+		struct tls_compression_method *cm =
 			tls_find_compression_method(*compression_methods);
 
-		if (tls->pending.compression_method)
+		if (!cm)
+			TLS_DEBUG("non-fatal: Compression %02x unknown",
+					*compression_methods);
+		else if (resuming && *compression_methods !=
+				tls->session_compression_method_id) {
+			/*
+			 * For now skip this compression method because we're
+			 * trying to find the one from the cached session state.
+			 * But keep it as a backup in case we end up starting
+			 * a new * session.
+			 */
+			if (!backup_cm)
+				backup_cm = cm;
+		} else {
+			tls->pending.compression_method = cm;
 			break;
+		}
 
 		compression_methods++;
 		compression_methods_size--;
 	}
 
-	if (!compression_methods_size) {
+	if (unlikely(!compression_methods_size && backup_cm)) {
+		TLS_DEBUG("Cached session %s's compression method %02x "
+				"unavailable, will start a new session",
+				session_id_str,
+				tls->session_compression_method_id);
+		tls->pending.compression_method = backup_cm;
+
+		if (backup_suite)
+			tls->pending.cipher_suite = backup_suite;
+
+		resuming = false;
+		tls_server_resume_error(tls);
+	} else if (unlikely(!compression_methods_size)) {
 		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
 				"No common compression methods");
 		goto cleanup;
 	}
 
+	if (resuming)
+		TLS_DEBUG("Negotiated resumption of cached session %s",
+				session_id_str);
+
+	TLS_DEBUG("Negotiated %s", tls->pending.cipher_suite->name);
 	TLS_DEBUG("Negotiated %s", tls->pending.compression_method->name);
 
-	if (!tls_send_server_hello(tls, extensions_offered))
+	if (!resuming && tls->session_settings) {
+		tls->session_id_new = true;
+		tls->session_id_size = 32;
+		l_getrandom(tls->session_id, 32);
+	}
+
+	if (!tls_send_server_hello(tls, resuming ? extensions_offered : NULL))
 		goto cleanup;
 
 	l_queue_destroy(extensions_offered, NULL);
 
+	if (resuming) {
+		const char *error;
+
+		tls_update_key_block(tls);
+		tls_send_change_cipher_spec(tls);
+
+		if (!tls_change_cipher_spec(tls, 1, &error)) {
+			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+					"change_cipher_spec: %s", error);
+			return;
+		}
+
+		tls_send_finished(tls);
+		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC);
+		return;
+	}
+
 	if (tls->pending.cipher_suite->signature && tls->cert)
 		if (!tls_send_certificate(tls))
 			return;
@@ -2675,7 +2930,7 @@ static void tls_finished(struct l_tls *tls)
 	} else if (tls->peer_authenticated && resuming)
 		peer_identity = tls->session_peer_identity;
 
-	if (!tls->server && tls->session_settings && tls->session_id_new) {
+	if (tls->session_settings && tls->session_id_new) {
 		_auto_(l_free) char *session_id_str =
 			l_util_hexstring(tls->session_id, tls->session_id_size);
 		uint64_t expiry = tls->session_lifetime ?
@@ -2729,6 +2984,14 @@ static void tls_finished(struct l_tls *tls)
 
 		TLS_DEBUG("Saving new session %s to cache", session_id_str);
 		session_update = true;
+
+		if (tls->session_id_size_replaced) {
+			tls_forget_cached_session(tls, NULL,
+						tls->session_id_replaced,
+						tls->session_id_size_replaced,
+						false);
+			tls->session_id_size_replaced = 0;
+		}
 	}
 
 	/* Free up the resources used in the handshake */
@@ -2947,7 +3210,7 @@ static void tls_handle_handshake(struct l_tls *tls, int type,
 
 		resuming = tls->session_id_size && !tls->session_id_new;
 
-		if (tls->server || (!tls->server && resuming)) {
+		if ((tls->server && !resuming) || (!tls->server && resuming)) {
 			const char *error;
 
 			tls_send_change_cipher_spec(tls);
@@ -2990,11 +3253,11 @@ static void tls_handle_handshake(struct l_tls *tls, int type,
 		 *      pair.
 		 *
 		 * If we're resuming a cached session, we have authenticated
-		 * this server before and the successful decryption of this
-		 * message confirms the server identity hasn't changed.
+		 * this peer before and the successful decryption of this
+		 * message confirms their identity hasn't changed.
 		 */
-		if (!tls->server && tls->cipher_suite[0]->signature &&
-				((!resuming && tls->ca_certs) ||
+		if (tls->cipher_suite[0]->signature &&
+				((!tls->server && !resuming && tls->ca_certs) ||
 				 (resuming && tls->session_peer_identity)))
 			tls->peer_authenticated = true;
 
-- 
2.34.1

