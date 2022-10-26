Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 911CC1374
	for <ell@lists.linux.dev>; Wed, 26 Oct 2022 13:16:18 +0000 (UTC)
Received: by mail-wr1-f47.google.com with SMTP id l14so19032093wrw.2
        for <ell@lists.linux.dev>; Wed, 26 Oct 2022 06:16:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=RzTXWYyobpbjiiAQ23xO4q3lkLXqdizZqO06sm+S0wA=;
        b=bwEM+gbm9nAch7eacvEasS1SNg+0xLvVz3atQnVzmRirdIJyL4fIBOBsN4J4D93EyJ
         DFsbBwVYRLh296EXyzXkutGMm4kBWMkPsmnEYxk1S6KoLFlEIH1/tJPl0Vp+ltX3ufkU
         /MfN54t66NYPnyA5+p8EeKHvh2biGo5meEj0GaNlgEh5IKgtkOPQGfx0AJBnHxoqqJI4
         IW7PLCDGprYEyBWB7LMK3R1pE1TPLU6Om1CLXbYQYAxoQjPm83ZsqeeJL2F6WLzqYce0
         dc9Wnzt+au+kFYYfAuVqpJTMbP9oVAdqi9d5gCFuTQXdAzxoEMeHm7fVUkA+bpaEqjub
         LYHg==
X-Gm-Message-State: ACrzQf0sOXZsSP5jv/yuNUpeoiOr+jte7G4VGaqtg7vyBakRtTqeYxy1
	3Yl1e11LhRhHTYnhjxBN4n51/c2DYDc=
X-Google-Smtp-Source: AMsMyM7sqRrt1KYHvLWs+MXqflw3hrymX3f9qh78drSols7wdn+RbQYf2DNGcUYliq9GrgPMjDNN+Q==
X-Received: by 2002:a05:6000:1b85:b0:230:3652:335 with SMTP id r5-20020a0560001b8500b0023036520335mr28404114wru.467.1666790175410;
        Wed, 26 Oct 2022 06:16:15 -0700 (PDT)
Received: from localhost.localdomain ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id x23-20020a05600c21d700b003a83ca67f73sm1934771wmj.3.2022.10.26.06.16.13
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 26 Oct 2022 06:16:14 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 5/6] tls: Client session resumption
Date: Wed, 26 Oct 2022 15:15:57 +0200
Message-Id: <20221026131558.2393488-5-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20221026131558.2393488-1-andrew.zaborowski@intel.com>
References: <20221026131558.2393488-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

In client mode load a stored session state from the cache in l_tls_start
and attempt to resume that session.
---
 ell/tls-private.h |   3 +
 ell/tls-suites.c  |   4 +-
 ell/tls.c         | 316 +++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 286 insertions(+), 37 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 6f09f6a..7156666 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -260,6 +260,9 @@ struct l_tls {
 	uint8_t session_id[32];
 	size_t session_id_size;
 	bool session_id_new;
+	uint8_t session_cipher_suite_id[2];
+	uint8_t session_compression_method_id;
+	char *session_peer_identity;
 
 	/* SecurityParameters current and pending */
 
diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index ee4e7ee..8cbcb63 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -352,8 +352,8 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls *tls)
 	}
 
 	/* Must match the version in tls_send_client_hello */
-	pre_master_secret[0] = (uint8_t) (tls->max_version >> 8);
-	pre_master_secret[1] = (uint8_t) (tls->max_version >> 0);
+	pre_master_secret[0] = (uint8_t) (tls->client_version >> 8);
+	pre_master_secret[1] = (uint8_t) (tls->client_version >> 0);
 
 	l_getrandom(pre_master_secret + 2, 46);
 
diff --git a/ell/tls.c b/ell/tls.c
index ff4fa5b..88ac3d7 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -210,6 +210,7 @@ static void tls_reset_handshake(struct l_tls *tls)
 
 	tls->session_id_size = 0;
 	tls->session_id_new = false;
+	l_free(l_steal_ptr(tls->session_peer_identity));
 }
 
 static void tls_cleanup_handshake(struct l_tls *tls)
@@ -851,6 +852,155 @@ static void tls_forget_cached_client_session(struct l_tls *tls)
 	}
 }
 
+static bool tls_load_cached_client_session(struct l_tls *tls)
+{
+	/*
+	 * The following settings are required:
+	 *   TLSSessionID,
+	 *   TLSSessionMasterSecret,
+	 *   TLSSessionVersion,
+	 *   TLSSessionCipherSuite,
+	 *   TLSSessionCompressionMethod,
+	 * and these two are optional:
+	 *   TLSSessionExpiryTime,
+	 *   TLSSessionPeerIdentity.
+	 */
+	_auto_(l_free) uint8_t *session_id = NULL;
+	size_t session_id_size;
+	_auto_(l_free) char *session_id_str = NULL;
+	_auto_(l_free) uint8_t *master_secret = NULL;
+	int version;
+	_auto_(l_free) uint8_t *cipher_suite_id = NULL;
+	struct tls_cipher_suite *cipher_suite;
+	unsigned int compression_method_id;
+	_auto_(l_free) char *peer_identity = NULL;
+	size_t size;
+	const char *error;
+
+	tls->session_id_size = 0;
+	tls->session_id_new = false;
+
+	if (!tls->session_settings ||
+			!l_settings_has_key(tls->session_settings,
+						tls->session_group,
+						"TLSSessionID"))
+		/* No session cached, no error */
+		return false;
+
+	session_id = l_settings_get_bytes(tls->session_settings,
+						tls->session_group,
+						"TLSSessionID",
+						&session_id_size);
+	if (unlikely(!session_id ||
+			session_id_size < 1 || session_id_size > 32))
+		goto warn_corrupt;
+
+	session_id_str =
+		l_util_hexstring(tls->session_id, tls->session_id_size);
+
+	if (l_settings_has_key(tls->session_settings, tls->session_group,
+				"TLSSessionExpiryTime")) {
+		uint64_t expiry_time;
+
+		if (unlikely(!l_settings_get_uint64(tls->session_settings,
+							tls->session_group,
+							"TLSSessionExpiryTime",
+							&expiry_time)))
+			goto warn_corrupt;
+
+		if (time_realtime_now() > expiry_time) {
+			TLS_DEBUG("Cached session %s is expired, removing it, "
+					"will start a new session",
+					session_id_str);
+			goto forget;
+		}
+	}
+
+	if (unlikely(!l_settings_get_int(tls->session_settings,
+						tls->session_group,
+						"TLSSessionVersion",
+						&version) ||
+			version < TLS_MIN_VERSION || version > TLS_MAX_VERSION))
+		goto warn_corrupt;
+
+	master_secret = l_settings_get_bytes(tls->session_settings,
+						tls->session_group,
+						"TLSSessionMasterSecret",
+						&size);
+	if (unlikely(!master_secret || size != 48))
+		goto warn_corrupt;
+
+	cipher_suite_id = l_settings_get_bytes(tls->session_settings,
+						tls->session_group,
+						"TLSSessionCipherSuite",
+						&size);
+	if (unlikely(!cipher_suite_id || size != 2 ||
+			!(cipher_suite =
+			  tls_find_cipher_suite(cipher_suite_id))))
+		goto warn_corrupt;
+
+	/*
+	 * While we could attempt to resume a session even though we're now
+	 * configured with, say, a different certificate type than what we
+	 * had when we cached that session, that is too questionable of a
+	 * scenario to support it.  We don't specifically check that all of
+	 * the authentication data is the same, e.g. we don't save the
+	 * certificate serial number or path, but ensure the cached cipher
+	 * suite is compatible with current authentication data.
+	 *
+	 * We filter the cipher suites in our Client Hello to only offer the
+	 * ones compatible with current configuration so if we also include
+	 * a Session ID from a session who's cipher suite is not one of those
+	 * listed in that same Client Hello, the server is likely to notice
+	 * and either start a new session or send a fatal Alert.
+	 *
+	 * It is up to the user to keep multiple cache instances if it needs
+	 * to save multiple sessions.
+	 */
+	if (unlikely(!tls_cipher_suite_is_compatible(tls, cipher_suite,
+							&error))) {
+		TLS_DEBUG("Cached session %s cipher suite not compatible: %s",
+				session_id_str, error);
+		goto forget;
+	}
+
+	if (unlikely(!l_settings_get_uint(tls->session_settings,
+						tls->session_group,
+						"TLSSessionCompressionMethod",
+						&compression_method_id) ||
+			!tls_find_compression_method(compression_method_id)))
+		goto warn_corrupt;
+
+	if (l_settings_has_key(tls->session_settings, tls->session_group,
+				"TLSSessionPeerIdentity")) {
+		peer_identity = l_settings_get_string(tls->session_settings,
+						tls->session_group,
+						"TLSSessionPeerIdentity");
+		if (unlikely(!peer_identity || !cipher_suite->signature))
+			goto warn_corrupt;
+	}
+
+	tls->session_id_size = session_id_size;
+	memcpy(tls->session_id, session_id, session_id_size);
+	tls->session_id_new = false;
+	tls->client_version = version;
+	memcpy(tls->pending.master_secret, master_secret, 48);
+	memcpy(tls->session_cipher_suite_id, cipher_suite_id, 2);
+	tls->session_compression_method_id = compression_method_id;
+	l_free(tls->session_peer_identity);
+	tls->session_peer_identity = l_steal_ptr(peer_identity);
+	return true;
+
+warn_corrupt:
+	TLS_DEBUG("Cached session %s data is corrupt or has unsupported "
+			"parameters, removing it, will start a new session",
+			session_id_str ?: "<unknonwn>");
+
+forget:
+	tls_forget_cached_client_session(tls);
+	return false;
+}
+
 #define SWITCH_ENUM_TO_STR(val) \
 	case (val):		\
 		return L_STRINGIFY(val);
@@ -1063,14 +1213,19 @@ static bool tls_send_client_hello(struct l_tls *tls)
 
 	/* Fill in the Client Hello body */
 
-	*ptr++ = (uint8_t) (tls->max_version >> 8);
-	*ptr++ = (uint8_t) (tls->max_version >> 0);
+	*ptr++ = (uint8_t) (tls->client_version >> 8);
+	*ptr++ = (uint8_t) (tls->client_version >> 0);
 
 	tls_write_random(tls->pending.client_random);
 	memcpy(ptr, tls->pending.client_random, 32);
 	ptr += 32;
 
-	*ptr++ = 0; /* No SessionID */
+	if (tls->session_id_size) {
+		*ptr++ = tls->session_id_size;
+		memcpy(ptr, tls->session_id, tls->session_id_size);
+		ptr += tls->session_id_size;
+	} else
+		*ptr++ = 0;
 
 	len_ptr = ptr;
 	ptr += 2;
@@ -1317,22 +1472,10 @@ static void tls_send_server_hello_done(struct l_tls *tls)
 				TLS_HANDSHAKE_HEADER_SIZE);
 }
 
-void tls_generate_master_secret(struct l_tls *tls,
-				const uint8_t *pre_master_secret,
-				int pre_master_secret_len)
+static void tls_update_key_block(struct l_tls *tls)
 {
 	uint8_t seed[64];
-	int key_block_size;
-
-	memcpy(seed +  0, tls->pending.client_random, 32);
-	memcpy(seed + 32, tls->pending.server_random, 32);
-
-	tls_prf_get_bytes(tls, pre_master_secret, pre_master_secret_len,
-				"master secret", seed, 64,
-				tls->pending.master_secret, 48);
-
-	/* Directly generate the key block while we're at it */
-	key_block_size = 0;
+	int key_block_size = 0;
 
 	if (tls->pending.cipher_suite->encryption)
 		key_block_size += 2 *
@@ -1360,8 +1503,25 @@ void tls_generate_master_secret(struct l_tls *tls,
 	tls_prf_get_bytes(tls, tls->pending.master_secret, 48,
 				"key expansion", seed, 64,
 				tls->pending.key_block, key_block_size);
+	explicit_bzero(seed, 64);
+}
 
+void tls_generate_master_secret(struct l_tls *tls,
+				const uint8_t *pre_master_secret,
+				int pre_master_secret_len)
+{
+	uint8_t seed[64];
+
+	memcpy(seed +  0, tls->pending.client_random, 32);
+	memcpy(seed + 32, tls->pending.server_random, 32);
+
+	tls_prf_get_bytes(tls, pre_master_secret, pre_master_secret_len,
+				"master secret", seed, 64,
+				tls->pending.master_secret, 48);
 	explicit_bzero(seed, 64);
+
+	/* Directly generate the key block while we're at it */
+	tls_update_key_block(tls);
 }
 
 static void tls_get_handshake_hash(struct l_tls *tls,
@@ -1856,11 +2016,14 @@ static void tls_handle_server_hello(struct l_tls *tls,
 	int i;
 	struct l_queue *extensions_seen;
 	bool result;
+	uint16_t version;
+	bool resuming = false;
 
 	/* Do we have enough for ProtocolVersion + Random + SessionID len ? */
 	if (len < 2 + 32 + 1)
 		goto decode_error;
 
+	version = l_get_be16(buf);
 	memcpy(tls->pending.server_random, buf + 2, 32);
 	session_id_size = buf[34];
 	len -= 35;
@@ -1877,6 +2040,32 @@ static void tls_handle_server_hello(struct l_tls *tls,
 	if (session_id_size > 32)
 		goto decode_error;
 
+	if (tls->session_id_size) {
+		_auto_(l_free) char *session_id_str =
+			l_util_hexstring(tls->session_id, tls->session_id_size);
+
+		if (session_id_size == tls->session_id_size &&
+				!memcmp(buf + 35, tls->session_id,
+					session_id_size)) {
+			TLS_DEBUG("Negotiated resumption of cached session %s",
+					session_id_str);
+			resuming = true;
+
+			/*
+			 * Skip parsing extensions as none of the ones we
+			 * support are used in session resumption.  We could
+			 * as well signal an error if the ServerHello has any
+			 * extensions, for now ignore them.
+			 */
+			goto check_version;
+		}
+
+		TLS_DEBUG("Server decided not to resume cached session %s, "
+				"sent %s session ID", session_id_str,
+				session_id_size ? "a new" : "no");
+		tls->session_id_size = 0;
+	}
+
 	if (session_id_size && tls->session_settings) {
 		tls->session_id_new = true;
 		tls->session_id_size = session_id_size;
@@ -1891,18 +2080,17 @@ static void tls_handle_server_hello(struct l_tls *tls,
 	if (!result)
 		return;
 
-	tls->negotiated_version = l_get_be16(buf);
-
-	if (tls->negotiated_version < tls->min_version ||
-			tls->negotiated_version > tls->max_version) {
-		TLS_DISCONNECT(tls->negotiated_version < tls->min_version ?
+check_version:
+	if (version < tls->min_version || version > tls->max_version) {
+		TLS_DISCONNECT(version < tls->min_version ?
 				TLS_ALERT_PROTOCOL_VERSION :
 				TLS_ALERT_ILLEGAL_PARAM, 0,
-				"Unsupported version %02x",
-				tls->negotiated_version);
+				"Unsupported version %02x", version);
 		return;
 	}
 
+	tls->negotiated_version = version;
+
 	/* Stop maintaining handshake message hashes other than MD1 and SHA. */
 	if (tls->negotiated_version < L_TLS_V12)
 		for (i = 0; i < __HANDSHAKE_HASH_COUNT; i++)
@@ -1958,7 +2146,30 @@ static void tls_handle_server_hello(struct l_tls *tls,
 
 	TLS_DEBUG("Negotiated %s", tls->pending.compression_method->name);
 
-	if (tls->pending.cipher_suite->signature)
+	if (resuming) {
+		/*
+		 * Now that we've validated the Server Hello parameters and
+		 * know that they're supported by this version of ell and
+		 * consistent with the current configuration, ensure that
+		 * they're identical with the ones in the cached session
+		 * being resumed.  This serves as a sanity check for
+		 * rare situations like a corrupt session cache file or
+		 * a file written by a newer ell version.
+		 */
+		if (tls->negotiated_version != tls->client_version ||
+				memcmp(cipher_suite_id,
+					tls->session_cipher_suite_id, 2) ||
+				compression_method_id !=
+				tls->session_compression_method_id) {
+			TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+					"Session parameters don't match");
+			return;
+		}
+
+		tls_update_key_block(tls);
+
+		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC);
+	} else if (tls->pending.cipher_suite->signature)
 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CERTIFICATE);
 	else
 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_KEY_EXCHANGE);
@@ -2419,18 +2630,22 @@ error:
 
 static void tls_finished(struct l_tls *tls)
 {
-	_auto_(l_free) char *peer_identity = NULL;
+	_auto_(l_free) char *peer_cert_identity = NULL;
+	char *peer_identity = NULL;
 	uint64_t peer_cert_expiry;
+	bool resuming = tls->session_id_size && !tls->session_id_new;
 	bool session_update = false;
 
-	if (tls->peer_authenticated) {
-		peer_identity = tls_get_peer_identity_str(tls->peer_cert);
-		if (!peer_identity) {
+	if (tls->peer_authenticated && !resuming) {
+		peer_cert_identity = tls_get_peer_identity_str(tls->peer_cert);
+		if (!peer_cert_identity) {
 			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
 					"tls_get_peer_identity_str failed");
 			return;
 		}
 
+		peer_identity = peer_cert_identity;
+
 		if (tls->session_id_new &&
 				!l_cert_get_valid_times(tls->peer_cert, NULL,
 							&peer_cert_expiry)) {
@@ -2438,7 +2653,8 @@ static void tls_finished(struct l_tls *tls)
 					"l_cert_get_valid_times failed");
 			return;
 		}
-	}
+	} else if (tls->peer_authenticated && resuming)
+		peer_identity = tls->session_peer_identity;
 
 	if (!tls->server && tls->session_settings && tls->session_id_new) {
 		_auto_(l_free) char *session_id_str =
@@ -2516,6 +2732,8 @@ static void tls_finished(struct l_tls *tls)
 static void tls_handle_handshake(struct l_tls *tls, int type,
 					const uint8_t *buf, size_t len)
 {
+	bool resuming;
+
 	TLS_DEBUG("Handling a %s of %zi bytes",
 			tls_handshake_type_to_str(type), len);
 
@@ -2703,7 +2921,9 @@ static void tls_handle_handshake(struct l_tls *tls, int type,
 		if (!tls_verify_finished(tls, buf, len))
 			break;
 
-		if (tls->server) {
+		resuming = tls->session_id_size && !tls->session_id_new;
+
+		if (tls->server || (!tls->server && resuming)) {
 			const char *error;
 
 			tls_send_change_cipher_spec(tls);
@@ -2717,9 +2937,9 @@ static void tls_handle_handshake(struct l_tls *tls, int type,
 		}
 
 		/*
-		 * On the client, the server's certificate is now verified
-		 * regardless of the key exchange method, based on the
-		 * following logic:
+		 * When starting a new session on the client, the server's
+		 * certificate is now verified regardless of the key exchange
+		 * method, based on the following logic:
 		 *
 		 *  - tls->ca_certs is non-NULL so tls_handle_certificate
 		 *    (always called on the client) must have veritifed the
@@ -2744,9 +2964,14 @@ static void tls_handle_handshake(struct l_tls *tls, int type,
 		 *      able to sign the client random together with the
 		 *      ServerKeyExchange parameters using its certified key
 		 *      pair.
+		 *
+		 * If we're resuming a cached session, we have authenticated
+		 * this server before and the successful decryption of this
+		 * message confirms the server identity hasn't changed.
 		 */
 		if (!tls->server && tls->cipher_suite[0]->signature &&
-				tls->ca_certs)
+				((!resuming && tls->ca_certs) ||
+				 (resuming && tls->session_peer_identity)))
 			tls->peer_authenticated = true;
 
 		tls_finished(tls);
@@ -3010,6 +3235,27 @@ LIB_EXPORT bool l_tls_start(struct l_tls *tls)
 	if (!tls_init_handshake_hash(tls))
 		return false;
 
+	/*
+	 * If we're going to try resuming a cached session, send the Client
+	 * Hello with the version we think is supported.
+	 *
+	 * RFC5246 Appendix E.1:
+	 * "Whenever a client already knows the highest protocol version known
+	 * to a server (for example, when resuming a session), it SHOULD
+	 * initiate the connection in that native protocol."
+	 *
+	 * Don't directly set tls->{min,max}_version as that would make the
+	 * handshake fail if the server decides to start a new session with
+	 * a new version instead of resuming, which it is allowed to do.
+	 */
+	tls->client_version = tls->max_version;
+	tls_load_cached_client_session(tls);
+
+	if (tls->pending_destroy) {
+		l_tls_free(tls);
+		return false;
+	}
+
 	if (!tls_send_client_hello(tls))
 		return false;
 
-- 
2.34.1

