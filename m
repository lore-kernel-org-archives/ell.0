Received: from mail-ej1-f54.google.com (mail-ej1-f54.google.com [209.85.218.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D16C33E3
	for <ell@lists.linux.dev>; Mon,  7 Nov 2022 11:30:20 +0000 (UTC)
Received: by mail-ej1-f54.google.com with SMTP id sc25so29137159ejc.12
        for <ell@lists.linux.dev>; Mon, 07 Nov 2022 03:30:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=N854ROCAdyMTo277+vqKzK0+1V/JUa3UVJMdyz9uLLY=;
        b=JETvZ+eRx++lwIA4L/aIefC/D6G7vYwHcHXVz5qVXILhcM+a5Nl31dwYjF3ipL38Yv
         a+QB5jEDxgBoaKTo4eogznSnHuIQnJXSjdvGsxTnenVC3oBSsYsrJ8Gzoz4DUmpTju/3
         Sv5lrbaIFYen1SGWhgh1LDxXzdaMXHlKB8tSw57kDgHbksZmwNBRTbNZcevJpbF8ShAT
         upQpvFiiXZCxGhIxthLwg6Fn2sGIjnHpdC7xdZ+OeHN7GZEEX9GollTci7va8ROfNCsN
         j7xXNZr2x+BHxt6tgfX8lSeeDbc9yfeQDRcEteRlf2T40w0L33Pik+5TqzWxjQu2Ulci
         LgDA==
X-Gm-Message-State: ACrzQf3v/pixVe/T2n7JLi9saNYNun+9JAFnObbuFEvNCXPVZUiiQqbK
	h90GjfSUZsJqB1pZPe44tobldmimPiY=
X-Google-Smtp-Source: AMsMyM6If3DYRMQlhqlHEmeERo4LRXTzqUvZfcQQKMnT5kGdjCI8DkiHs3WWVSNUMWkE2/457+sKQw==
X-Received: by 2002:a17:907:2bd1:b0:7ae:41e1:cdfa with SMTP id gv17-20020a1709072bd100b007ae41e1cdfamr13611183ejc.618.1667820617559;
        Mon, 07 Nov 2022 03:30:17 -0800 (PST)
Received: from iss.ger.corp.intel.com ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id x16-20020a170906135000b007ae32daf4b9sm3259769ejb.106.2022.11.07.03.30.16
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 07 Nov 2022 03:30:16 -0800 (PST)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 1/3] tls: Refactor session storage for server mode
Date: Mon,  7 Nov 2022 12:30:10 +0100
Message-Id: <20221107113012.328918-1-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

In TLS server mode we will need to store multiple session states in the
session cache instead of only one like on the client.  While the
l_tls_set_session_cache() method is new use to opportunity to make
incompatible changes: add the cache size limit parameter and strip "TLS"
prefix from the setting names in the cache's l_settings object since the
group name can include this part of the context without duplicating it
across settings.  Rename the group_name parameter to group_prefix since
in server mode there will be a settings group per session cached so that
we can use identical keys for each session.  When removing a session
remove the whole group rather than individual settings potentially
leaving an empty group.  Factor out the session loading code common to
client and server into a function.  When saving a server side session
state skip the SessionID setting since the session ID is in the group
name as the primary index.  Add a boolean parameter to
tls_forget_cached_session() to suppress the update_cb callback if
needed, to allow the caller to make a single callback after multiple
changes are made in the session cache instead of calling back after each
individual change.
---
 ell/tls-private.h |   3 +-
 ell/tls.c         | 228 ++++++++++++++++++++++++++--------------------
 ell/tls.h         |   3 +-
 3 files changed, 133 insertions(+), 101 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 7156666..ce69553 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -219,8 +219,9 @@ struct l_tls {
 	struct tls_cipher_suite **cipher_suite_pref_list;
 
 	struct l_settings *session_settings;
-	char *session_group;
+	char *session_prefix;
 	uint64_t session_lifetime;
+	unsigned int session_count_max;
 	l_tls_session_update_cb_t session_update_cb;
 	void *session_update_user_data;
 
diff --git a/ell/tls.c b/ell/tls.c
index 88ac3d7..a28a455 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -827,47 +827,44 @@ parse_error:
 	return false;
 }
 
-static void tls_forget_cached_client_session(struct l_tls *tls)
-{
-	/* Note: might want to l_settings_remove_group() instead. */
-	l_settings_remove_key(tls->session_settings, tls->session_group,
-				"TLSSessionID");
-	l_settings_remove_key(tls->session_settings, tls->session_group,
-				"TLSSessionMasterSecret");
-	l_settings_remove_key(tls->session_settings, tls->session_group,
-				"TLSSessionVersion");
-	l_settings_remove_key(tls->session_settings, tls->session_group,
-				"TLSSessionCipherSuite");
-	l_settings_remove_key(tls->session_settings, tls->session_group,
-				"TLSSessionCompressionMethod");
-	l_settings_remove_key(tls->session_settings, tls->session_group,
-				"TLSSessionExpiryTime");
-	l_settings_remove_key(tls->session_settings, tls->session_group,
-				"TLSSessionPeerIdentity");
-
-	if (tls->session_update_cb) {
+static const char *tls_get_cache_group_name(struct l_tls *tls,
+						const uint8_t *session_id,
+						size_t session_id_size)
+{
+	_auto_(l_free) char *session_id_str = NULL;
+	static char group_name[256];
+
+	if (!tls->server)
+		return tls->session_prefix;
+
+	session_id_str = l_util_hexstring(session_id, session_id_size);
+	snprintf(group_name, sizeof(group_name), "%s-%s",
+			tls->session_prefix, session_id_str);
+	return group_name;
+}
+
+static void tls_forget_cached_session(struct l_tls *tls, const char *group_name,
+					const uint8_t *session_id,
+					size_t session_id_size, bool call_back)
+{
+	if (!group_name)
+		group_name = tls_get_cache_group_name(tls, session_id,
+							session_id_size);
+
+	l_settings_remove_group(tls->session_settings, group_name);
+
+	if (call_back && tls->session_update_cb) {
 		tls->in_callback = true;
 		tls->session_update_cb(tls->session_update_user_data);
 		tls->in_callback = false;
 	}
 }
 
-static bool tls_load_cached_client_session(struct l_tls *tls)
+static bool tls_load_cached_session(struct l_tls *tls, const char *group_name,
+					const uint8_t *session_id,
+					size_t session_id_size,
+					const char *session_id_str)
 {
-	/*
-	 * The following settings are required:
-	 *   TLSSessionID,
-	 *   TLSSessionMasterSecret,
-	 *   TLSSessionVersion,
-	 *   TLSSessionCipherSuite,
-	 *   TLSSessionCompressionMethod,
-	 * and these two are optional:
-	 *   TLSSessionExpiryTime,
-	 *   TLSSessionPeerIdentity.
-	 */
-	_auto_(l_free) uint8_t *session_id = NULL;
-	size_t session_id_size;
-	_auto_(l_free) char *session_id_str = NULL;
 	_auto_(l_free) uint8_t *master_secret = NULL;
 	int version;
 	_auto_(l_free) uint8_t *cipher_suite_id = NULL;
@@ -877,34 +874,13 @@ static bool tls_load_cached_client_session(struct l_tls *tls)
 	size_t size;
 	const char *error;
 
-	tls->session_id_size = 0;
-	tls->session_id_new = false;
-
-	if (!tls->session_settings ||
-			!l_settings_has_key(tls->session_settings,
-						tls->session_group,
-						"TLSSessionID"))
-		/* No session cached, no error */
-		return false;
-
-	session_id = l_settings_get_bytes(tls->session_settings,
-						tls->session_group,
-						"TLSSessionID",
-						&session_id_size);
-	if (unlikely(!session_id ||
-			session_id_size < 1 || session_id_size > 32))
-		goto warn_corrupt;
-
-	session_id_str =
-		l_util_hexstring(tls->session_id, tls->session_id_size);
-
-	if (l_settings_has_key(tls->session_settings, tls->session_group,
-				"TLSSessionExpiryTime")) {
+	if (l_settings_has_key(tls->session_settings, group_name,
+				"SessionExpiryTime")) {
 		uint64_t expiry_time;
 
 		if (unlikely(!l_settings_get_uint64(tls->session_settings,
-							tls->session_group,
-							"TLSSessionExpiryTime",
+							group_name,
+							"SessionExpiryTime",
 							&expiry_time)))
 			goto warn_corrupt;
 
@@ -917,22 +893,22 @@ static bool tls_load_cached_client_session(struct l_tls *tls)
 	}
 
 	if (unlikely(!l_settings_get_int(tls->session_settings,
-						tls->session_group,
-						"TLSSessionVersion",
+						group_name,
+						"SessionVersion",
 						&version) ||
 			version < TLS_MIN_VERSION || version > TLS_MAX_VERSION))
 		goto warn_corrupt;
 
 	master_secret = l_settings_get_bytes(tls->session_settings,
-						tls->session_group,
-						"TLSSessionMasterSecret",
+						group_name,
+						"SessionMasterSecret",
 						&size);
 	if (unlikely(!master_secret || size != 48))
 		goto warn_corrupt;
 
 	cipher_suite_id = l_settings_get_bytes(tls->session_settings,
-						tls->session_group,
-						"TLSSessionCipherSuite",
+						group_name,
+						"SessionCipherSuite",
 						&size);
 	if (unlikely(!cipher_suite_id || size != 2 ||
 			!(cipher_suite =
@@ -964,18 +940,17 @@ static bool tls_load_cached_client_session(struct l_tls *tls)
 		goto forget;
 	}
 
-	if (unlikely(!l_settings_get_uint(tls->session_settings,
-						tls->session_group,
-						"TLSSessionCompressionMethod",
+	if (unlikely(!l_settings_get_uint(tls->session_settings, group_name,
+						"SessionCompressionMethod",
 						&compression_method_id) ||
 			!tls_find_compression_method(compression_method_id)))
 		goto warn_corrupt;
 
-	if (l_settings_has_key(tls->session_settings, tls->session_group,
-				"TLSSessionPeerIdentity")) {
+	if (l_settings_has_key(tls->session_settings, group_name,
+				"SessionPeerIdentity")) {
 		peer_identity = l_settings_get_string(tls->session_settings,
-						tls->session_group,
-						"TLSSessionPeerIdentity");
+						group_name,
+						"SessionPeerIdentity");
 		if (unlikely(!peer_identity || !cipher_suite->signature))
 			goto warn_corrupt;
 	}
@@ -994,13 +969,56 @@ static bool tls_load_cached_client_session(struct l_tls *tls)
 warn_corrupt:
 	TLS_DEBUG("Cached session %s data is corrupt or has unsupported "
 			"parameters, removing it, will start a new session",
-			session_id_str ?: "<unknonwn>");
+			session_id_str);
 
 forget:
-	tls_forget_cached_client_session(tls);
+	tls_forget_cached_session(tls, group_name, session_id, session_id_size,
+					true);
 	return false;
 }
 
+static bool tls_load_cached_client_session(struct l_tls *tls)
+{
+	/*
+	 * The following settings are required:
+	 *   SessionID,
+	 *   SessionMasterSecret,
+	 *   SessionVersion,
+	 *   SessionCipherSuite,
+	 *   SessionCompressionMethod,
+	 * and these two are optional:
+	 *   SessionExpiryTime,
+	 *   SessionPeerIdentity.
+	 */
+	_auto_(l_free) uint8_t *session_id = NULL;
+	size_t session_id_size;
+	_auto_(l_free) char *session_id_str = NULL;
+	const char *group_name = tls_get_cache_group_name(tls, NULL, 0);
+
+	tls->session_id_size = 0;
+	tls->session_id_new = false;
+
+	if (!tls->session_settings ||
+			!l_settings_has_key(tls->session_settings, group_name,
+						"SessionID"))
+		/* No session cached, no error */
+		return false;
+
+	session_id = l_settings_get_bytes(tls->session_settings, group_name,
+						"SessionID", &session_id_size);
+	if (unlikely(!session_id ||
+			session_id_size < 1 || session_id_size > 32)) {
+		TLS_DEBUG("Bad cached session ID format");
+		tls_forget_cached_session(tls, group_name, NULL, 0, true);
+		return false;
+	}
+
+	session_id_str = l_util_hexstring(session_id, session_id_size);
+
+	return tls_load_cached_session(tls, group_name, session_id,
+					session_id_size, session_id_str);
+}
+
 #define SWITCH_ENUM_TO_STR(val) \
 	case (val):		\
 		return L_STRINGIFY(val);
@@ -1083,7 +1101,8 @@ void tls_disconnect(struct l_tls *tls, enum l_tls_alert_desc desc,
 	tls->ready = false;
 
 	if (forget_session) {
-		tls_forget_cached_client_session(tls);
+		tls_forget_cached_session(tls, NULL, tls->session_id,
+						session_id_size, true);
 
 		if (tls->pending_destroy)
 			return;
@@ -2661,47 +2680,52 @@ static void tls_finished(struct l_tls *tls)
 			l_util_hexstring(tls->session_id, tls->session_id_size);
 		uint64_t expiry = tls->session_lifetime ?
 			time_realtime_now() + tls->session_lifetime : 0;
+		const char *group_name =
+			tls_get_cache_group_name(tls, tls->session_id,
+							tls->session_id_size);
 
 		if (tls->peer_authenticated &&
 				(!expiry || peer_cert_expiry < expiry))
 			expiry = peer_cert_expiry;
 
-		l_settings_set_bytes(tls->session_settings, tls->session_group,
-					"TLSSessionID", tls->session_id,
-					tls->session_id_size);
-		l_settings_set_bytes(tls->session_settings, tls->session_group,
-					"TLSSessionMasterSecret",
+		if (!tls->server)
+			l_settings_set_bytes(tls->session_settings, group_name,
+						"SessionID", tls->session_id,
+						tls->session_id_size);
+
+		l_settings_set_bytes(tls->session_settings, group_name,
+					"SessionMasterSecret",
 					tls->pending.master_secret, 48);
-		l_settings_set_int(tls->session_settings, tls->session_group,
-					"TLSSessionVersion",
+		l_settings_set_int(tls->session_settings, group_name,
+					"SessionVersion",
 					tls->negotiated_version);
-		l_settings_set_bytes(tls->session_settings, tls->session_group,
-					"TLSSessionCipherSuite",
+		l_settings_set_bytes(tls->session_settings, group_name,
+					"SessionCipherSuite",
 					tls->pending.cipher_suite->id, 2);
-		l_settings_set_uint(tls->session_settings, tls->session_group,
-					"TLSSessionCompressionMethod",
+		l_settings_set_uint(tls->session_settings, group_name,
+					"SessionCompressionMethod",
 					tls->pending.compression_method->id);
 
 		if (expiry)
 			l_settings_set_uint64(tls->session_settings,
-						tls->session_group,
-						"TLSSessionExpiryTime", expiry);
+						group_name,
+						"SessionExpiryTime", expiry);
 		else
 			/* We may be overwriting an older session's data */
 			l_settings_remove_key(tls->session_settings,
-						tls->session_group,
-						"TLSSessionExpiryTime");
+						group_name,
+						"SessionExpiryTime");
 
 		if (tls->peer_authenticated)
 			l_settings_set_string(tls->session_settings,
-						tls->session_group,
-						"TLSSessionPeerIdentity",
+						group_name,
+						"SessionPeerIdentity",
 						peer_identity);
 		else
 			/* We may be overwriting an older session's data */
 			l_settings_remove_key(tls->session_settings,
-						tls->session_group,
-						"TLSSessionPeerIdentity");
+						group_name,
+						"SessionPeerIdentity");
 
 		TLS_DEBUG("Saving new session %s to cache", session_id_str);
 		session_update = true;
@@ -3033,7 +3057,7 @@ LIB_EXPORT void l_tls_free(struct l_tls *tls)
 	l_tls_set_auth_data(tls, NULL, NULL);
 	l_tls_set_domain_mask(tls, NULL);
 	l_tls_set_cert_dump_path(tls, NULL);
-	l_tls_set_session_cache(tls, NULL, NULL, 0, NULL, NULL);
+	l_tls_set_session_cache(tls, NULL, NULL, 0, 0, NULL, NULL);
 
 	tls_reset_handshake(tls);
 	tls_cleanup_handshake(tls);
@@ -3434,9 +3458,13 @@ LIB_EXPORT void l_tls_set_domain_mask(struct l_tls *tls, char **mask)
  * @settings: l_settings object to read and write session data from/to or
  *   NULL to disable caching session states.  The object must remain valid
  *   until this method is called with a different value.
- * @group: group name inside @settings
+ * @group_prefix: prefix to build group names inside @settings.  Note:
+ *   existing settings in groups starting with the prefix may be
+ *   overwritten or removed.
  * @lifetime: a CLOCK_REALTIME-based microsecond resolution lifetime for
  *   cached sessions.  The RFC recommends 24 hours.
+ * @max_sessions: limit on the number of sessions in the cache, or 0 for
+ *   unlimited.  Ignored in client mode.
  * @update_cb: a callback to be invoked whenever the settings in @settings
  *   have been updated and may need to be written to persistent storage if
  *   desired, or NULL.
@@ -3459,8 +3487,9 @@ LIB_EXPORT void l_tls_set_domain_mask(struct l_tls *tls, char **mask)
  */
 LIB_EXPORT void l_tls_set_session_cache(struct l_tls *tls,
 					struct l_settings *settings,
-					const char *group_name,
+					const char *group_prefix,
 					uint64_t lifetime,
+					unsigned int max_sessions,
 					l_tls_session_update_cb_t update_cb,
 					void *user_data)
 {
@@ -3469,11 +3498,12 @@ LIB_EXPORT void l_tls_set_session_cache(struct l_tls *tls,
 
 	tls->session_settings = settings;
 	tls->session_lifetime = lifetime;
+	tls->session_count_max = max_sessions;
 	tls->session_update_cb = update_cb;
 	tls->session_update_user_data = user_data;
 
-	l_free(tls->session_group);
-	tls->session_group = l_strdup(group_name);
+	l_free(tls->session_prefix);
+	tls->session_prefix = l_strdup(group_prefix);
 }
 
 LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls_alert_desc desc)
diff --git a/ell/tls.h b/ell/tls.h
index 92d8b9e..e688c7c 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -130,7 +130,8 @@ void l_tls_set_version_range(struct l_tls *tls,
 void l_tls_set_domain_mask(struct l_tls *tls, char **mask);
 
 void l_tls_set_session_cache(struct l_tls *tls, struct l_settings *settings,
-				const char *group_name, uint64_t lifetime,
+				const char *group_prefix, uint64_t lifetime,
+				unsigned int max_sessions,
 				l_tls_session_update_cb_t update_cb,
 				void *user_data);
 
-- 
2.34.1

