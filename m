Received: from mail-wr1-f44.google.com (mail-wr1-f44.google.com [209.85.221.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3CB041374
	for <ell@lists.linux.dev>; Wed, 26 Oct 2022 13:16:16 +0000 (UTC)
Received: by mail-wr1-f44.google.com with SMTP id o4so18052395wrq.6
        for <ell@lists.linux.dev>; Wed, 26 Oct 2022 06:16:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=u/c0c4puocy1FszDQqGmN35WqiiO/iDH8JLJVap6IN0=;
        b=rZQb/Se9RMJiE1nXxaFKpZI5ZEwyKnb+4VSAn/fQPeitXSduHpJD2l9sN0qh8s/8sI
         SqckkaIyQ3UOI6+QwgkYm5jE8tbXb5Tu6i2SJHHztMgT5bmDTTY+0AUMEQGayzMAQjHL
         BbBKevY5POvmWwCXdaP4Ps8RSLne3Eo7YbGQZKozamAw1vyf6y8oyPr5A5Ohpg8tygsg
         in8zrJvCubJJphMd78hGaUv1Ubkla2L4C/uR+s2aH10VmJnvFxPPWqjySqN4LlsD9paz
         XWLOdB1rmhHvoB13q8DuxXxItPwQ2ki/ziAn4rpV5q88mfbBreM0Z8WTXSjtnExxs3tB
         dslw==
X-Gm-Message-State: ACrzQf06Y5Pcv3tFngoqaYH3c7PAof+wCfqYRJzIPEuoFPQhF8to8RcM
	X+P+Qyw1BVLqaiCaVpNIUYy0iMVgjLE=
X-Google-Smtp-Source: AMsMyM6annlkG3ChMqahIPR+XEb0IsitsKRHoe6+fhNAkNL0zLmaWf3iCoS90ieqTV3Zw6/UN1p6yw==
X-Received: by 2002:a05:6000:1a85:b0:230:f67b:da03 with SMTP id f5-20020a0560001a8500b00230f67bda03mr30227433wry.296.1666790173708;
        Wed, 26 Oct 2022 06:16:13 -0700 (PDT)
Received: from localhost.localdomain ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id x23-20020a05600c21d700b003a83ca67f73sm1934771wmj.3.2022.10.26.06.16.12
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 26 Oct 2022 06:16:12 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 4/6] tls: Add support for caching client session states
Date: Wed, 26 Oct 2022 15:15:56 +0200
Message-Id: <20221026131558.2393488-4-andrew.zaborowski@intel.com>
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

If a session cache is configured using l_tls_set_session_cache(), save
session states to a set of 7 key/value pairs in a given l_settings
object, in a given group.  This only implements the client side as the
semantics on the server side will be different.
---
 ell/ell.sym       |   1 +
 ell/tls-private.h |  10 +++
 ell/tls.c         | 192 +++++++++++++++++++++++++++++++++++++++++++++-
 ell/tls.h         |   7 ++
 4 files changed, 208 insertions(+), 2 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 5fe8d6e..6c836e1 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -518,6 +518,7 @@ global:
 	l_tls_set_auth_data;
 	l_tls_set_version_range;
 	l_tls_set_domain_mask;
+	l_tls_set_session_cache;
 	l_tls_alert_to_str;
 	l_tls_set_debug;
 	l_tls_set_cert_dump_path;
diff --git a/ell/tls-private.h b/ell/tls-private.h
index 8941e90..6f09f6a 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -218,6 +218,12 @@ struct l_tls {
 
 	struct tls_cipher_suite **cipher_suite_pref_list;
 
+	struct l_settings *session_settings;
+	char *session_group;
+	uint64_t session_lifetime;
+	l_tls_session_update_cb_t session_update_cb;
+	void *session_update_user_data;
+
 	bool in_callback;
 	bool pending_destroy;
 
@@ -251,6 +257,10 @@ struct l_tls {
 	const struct tls_named_group *negotiated_curve;
 	const struct tls_named_group *negotiated_ff_group;
 
+	uint8_t session_id[32];
+	size_t session_id_size;
+	bool session_id_new;
+
 	/* SecurityParameters current and pending */
 
 	struct {
diff --git a/ell/tls.c b/ell/tls.c
index fa3df5d..ff4fa5b 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -46,6 +46,9 @@
 #include "strv.h"
 #include "missing.h"
 #include "string.h"
+#include "settings.h"
+#include "time.h"
+#include "time-private.h"
 
 bool tls10_prf(const void *secret, size_t secret_len,
 		const char *label,
@@ -204,6 +207,9 @@ static void tls_reset_handshake(struct l_tls *tls)
 	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_START);
 	tls->cert_requested = 0;
 	tls->cert_sent = 0;
+
+	tls->session_id_size = 0;
+	tls->session_id_new = false;
 }
 
 static void tls_cleanup_handshake(struct l_tls *tls)
@@ -820,6 +826,31 @@ parse_error:
 	return false;
 }
 
+static void tls_forget_cached_client_session(struct l_tls *tls)
+{
+	/* Note: might want to l_settings_remove_group() instead. */
+	l_settings_remove_key(tls->session_settings, tls->session_group,
+				"TLSSessionID");
+	l_settings_remove_key(tls->session_settings, tls->session_group,
+				"TLSSessionMasterSecret");
+	l_settings_remove_key(tls->session_settings, tls->session_group,
+				"TLSSessionVersion");
+	l_settings_remove_key(tls->session_settings, tls->session_group,
+				"TLSSessionCipherSuite");
+	l_settings_remove_key(tls->session_settings, tls->session_group,
+				"TLSSessionCompressionMethod");
+	l_settings_remove_key(tls->session_settings, tls->session_group,
+				"TLSSessionExpiryTime");
+	l_settings_remove_key(tls->session_settings, tls->session_group,
+				"TLSSessionPeerIdentity");
+
+	if (tls->session_update_cb) {
+		tls->in_callback = true;
+		tls->session_update_cb(tls->session_update_user_data);
+		tls->in_callback = false;
+	}
+}
+
 #define SWITCH_ENUM_TO_STR(val) \
 	case (val):		\
 		return L_STRINGIFY(val);
@@ -868,6 +899,28 @@ static void tls_send_alert(struct l_tls *tls, bool fatal,
 void tls_disconnect(struct l_tls *tls, enum l_tls_alert_desc desc,
 			enum l_tls_alert_desc local_desc)
 {
+	bool forget_session = false;
+
+	if (!tls->server && (desc || local_desc) &&
+			tls->session_settings && tls->session_id_size &&
+			!tls->session_id_new)
+		/*
+		 * RFC5246 Section 7.2: "Alert messages with a level of fatal
+		 * result in the immediate termination of the connection.  In
+		 * this case, other connections corresponding to the session
+		 * may continue, but the session identifier MUST be
+		 * invalidated, preventing the failed session from being used
+		 * to establish new connections."
+		 *
+		 * and 7.2.1: "Note that as of TLS 1.1, failure to properly
+		 * close a connection no longer requires that a session not
+		 * be resumed."
+		 *
+		 * I.e. we need to remove the session from the cache here but
+		 * not on l_tls_close().
+		 */
+		forget_session = true;
+
 	tls_send_alert(tls, true, desc);
 
 	tls_reset_handshake(tls);
@@ -879,6 +932,13 @@ void tls_disconnect(struct l_tls *tls, enum l_tls_alert_desc desc,
 	tls->negotiated_version = 0;
 	tls->ready = false;
 
+	if (forget_session) {
+		tls_forget_cached_client_session(tls);
+
+		if (tls->pending_destroy)
+			return;
+	}
+
 	tls->disconnected(local_desc ?: desc, local_desc && !desc,
 				tls->user_data);
 }
@@ -1814,6 +1874,15 @@ static void tls_handle_server_hello(struct l_tls *tls,
 	compression_method_id = buf[35 + session_id_size + 2];
 	len -= session_id_size + 2 + 1;
 
+	if (session_id_size > 32)
+		goto decode_error;
+
+	if (session_id_size && tls->session_settings) {
+		tls->session_id_new = true;
+		tls->session_id_size = session_id_size;
+		memcpy(tls->session_id, buf + 35, session_id_size);
+	}
+
 	extensions_seen = l_queue_new();
 	result = tls_handle_hello_extensions(tls, buf + 38 + session_id_size,
 						len, extensions_seen);
@@ -2350,7 +2419,9 @@ error:
 
 static void tls_finished(struct l_tls *tls)
 {
-	char *peer_identity = NULL;
+	_auto_(l_free) char *peer_identity = NULL;
+	uint64_t peer_cert_expiry;
+	bool session_update = false;
 
 	if (tls->peer_authenticated) {
 		peer_identity = tls_get_peer_identity_str(tls->peer_cert);
@@ -2359,6 +2430,65 @@ static void tls_finished(struct l_tls *tls)
 					"tls_get_peer_identity_str failed");
 			return;
 		}
+
+		if (tls->session_id_new &&
+				!l_cert_get_valid_times(tls->peer_cert, NULL,
+							&peer_cert_expiry)) {
+			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+					"l_cert_get_valid_times failed");
+			return;
+		}
+	}
+
+	if (!tls->server && tls->session_settings && tls->session_id_new) {
+		_auto_(l_free) char *session_id_str =
+			l_util_hexstring(tls->session_id, tls->session_id_size);
+		uint64_t expiry = tls->session_lifetime ?
+			time_realtime_now() + tls->session_lifetime : 0;
+
+		if (tls->peer_authenticated &&
+				(!expiry || peer_cert_expiry < expiry))
+			expiry = peer_cert_expiry;
+
+		l_settings_set_bytes(tls->session_settings, tls->session_group,
+					"TLSSessionID", tls->session_id,
+					tls->session_id_size);
+		l_settings_set_bytes(tls->session_settings, tls->session_group,
+					"TLSSessionMasterSecret",
+					tls->pending.master_secret, 48);
+		l_settings_set_int(tls->session_settings, tls->session_group,
+					"TLSSessionVersion",
+					tls->negotiated_version);
+		l_settings_set_bytes(tls->session_settings, tls->session_group,
+					"TLSSessionCipherSuite",
+					tls->pending.cipher_suite->id, 2);
+		l_settings_set_uint(tls->session_settings, tls->session_group,
+					"TLSSessionCompressionMethod",
+					tls->pending.compression_method->id);
+
+		if (expiry)
+			l_settings_set_uint64(tls->session_settings,
+						tls->session_group,
+						"TLSSessionExpiryTime", expiry);
+		else
+			/* We may be overwriting an older session's data */
+			l_settings_remove_key(tls->session_settings,
+						tls->session_group,
+						"TLSSessionExpiryTime");
+
+		if (tls->peer_authenticated)
+			l_settings_set_string(tls->session_settings,
+						tls->session_group,
+						"TLSSessionPeerIdentity",
+						peer_identity);
+		else
+			/* We may be overwriting an older session's data */
+			l_settings_remove_key(tls->session_settings,
+						tls->session_group,
+						"TLSSessionPeerIdentity");
+
+		TLS_DEBUG("Saving new session %s to cache", session_id_str);
+		session_update = true;
 	}
 
 	/* Free up the resources used in the handshake */
@@ -2367,10 +2497,18 @@ static void tls_finished(struct l_tls *tls)
 	TLS_SET_STATE(TLS_HANDSHAKE_DONE);
 	tls->ready = true;
 
+	if (session_update && tls->session_update_cb) {
+		tls->in_callback = true;
+		tls->session_update_cb(tls->session_update_user_data);
+		tls->in_callback = false;
+
+		if (tls->pending_destroy)
+			return;
+	}
+
 	tls->in_callback = true;
 	tls->ready_handle(peer_identity, tls->user_data);
 	tls->in_callback = false;
-	l_free(peer_identity);
 
 	tls_cleanup_handshake(tls);
 }
@@ -2643,6 +2781,7 @@ LIB_EXPORT struct l_tls *l_tls_new(bool server,
 	tls->cipher_suite_pref_list = tls_cipher_suite_pref;
 	tls->min_version = TLS_MIN_VERSION;
 	tls->max_version = TLS_MAX_VERSION;
+	tls->session_lifetime = 24 * 3600 * L_USEC_PER_SEC;
 
 	/* If we're the server wait for the Client Hello already */
 	if (tls->server)
@@ -2669,6 +2808,7 @@ LIB_EXPORT void l_tls_free(struct l_tls *tls)
 	l_tls_set_auth_data(tls, NULL, NULL);
 	l_tls_set_domain_mask(tls, NULL);
 	l_tls_set_cert_dump_path(tls, NULL);
+	l_tls_set_session_cache(tls, NULL, NULL, 0, NULL, NULL);
 
 	tls_reset_handshake(tls);
 	tls_cleanup_handshake(tls);
@@ -3042,6 +3182,54 @@ LIB_EXPORT void l_tls_set_domain_mask(struct l_tls *tls, char **mask)
 	tls->subject_mask = l_strv_copy(mask);
 }
 
+/**
+ * l_tls_set_session_cache:
+ * @tls: TLS object being configured
+ * @settings: l_settings object to read and write session data from/to or
+ *   NULL to disable caching session states.  The object must remain valid
+ *   until this method is called with a different value.
+ * @group: group name inside @settings
+ * @lifetime: a CLOCK_REALTIME-based microsecond resolution lifetime for
+ *   cached sessions.  The RFC recommends 24 hours.
+ * @update_cb: a callback to be invoked whenever the settings in @settings
+ *   have been updated and may need to be written to persistent storage if
+ *   desired, or NULL.
+ * @user_data: user data pointer to pass to @update_cb.
+ *
+ * Enables caching and resuming session states as described in RFC 5246 for
+ * faster setup.  l_tls will maintain the required session state data in
+ * @settings including removing expired or erroneous sessions.
+ *
+ * A client's cache contains at most one session state since the client
+ * must request one specific Session ID from the server when resuming a
+ * session.  The resumption will only work while the state is cached by
+ * both the server and the client so clients should keep separate @settings
+ * objects or use separate groups inside one object for every discrete
+ * server they may want to connect to.
+ *
+ * Multiple l_tls clients connecting to the same server can share one cache
+ * to allow reusing an established session that is still active (actual
+ * concurrency is not supported as there's no locking.)
+ */
+LIB_EXPORT void l_tls_set_session_cache(struct l_tls *tls,
+					struct l_settings *settings,
+					const char *group_name,
+					uint64_t lifetime,
+					l_tls_session_update_cb_t update_cb,
+					void *user_data)
+{
+	if (unlikely(!tls))
+		return;
+
+	tls->session_settings = settings;
+	tls->session_lifetime = lifetime;
+	tls->session_update_cb = update_cb;
+	tls->session_update_user_data = user_data;
+
+	l_free(tls->session_group);
+	tls->session_group = l_strdup(group_name);
+}
+
 LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls_alert_desc desc)
 {
 	switch (desc) {
diff --git a/ell/tls.h b/ell/tls.h
index a4fd414..92d8b9e 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -36,6 +36,7 @@ struct l_tls;
 struct l_key;
 struct l_certchain;
 struct l_queue;
+struct l_settings;
 
 enum l_tls_alert_desc {
 	TLS_ALERT_CLOSE_NOTIFY		= 0,
@@ -72,6 +73,7 @@ typedef void (*l_tls_disconnect_cb_t)(enum l_tls_alert_desc reason,
 					bool remote, void *user_data);
 typedef void (*l_tls_debug_cb_t)(const char *str, void *user_data);
 typedef void (*l_tls_destroy_cb_t)(void *user_data);
+typedef void (*l_tls_session_update_cb_t)(void *user_data);
 
 /*
  * app_data_handler gets called with newly received decrypted data.
@@ -127,6 +129,11 @@ void l_tls_set_version_range(struct l_tls *tls,
 
 void l_tls_set_domain_mask(struct l_tls *tls, char **mask);
 
+void l_tls_set_session_cache(struct l_tls *tls, struct l_settings *settings,
+				const char *group_name, uint64_t lifetime,
+				l_tls_session_update_cb_t update_cb,
+				void *user_data);
+
 const char *l_tls_alert_to_str(enum l_tls_alert_desc desc);
 
 enum l_checksum_type;
-- 
2.34.1

