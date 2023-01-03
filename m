Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 03B398F76
	for <ell@lists.linux.dev>; Tue,  3 Jan 2023 22:02:56 +0000 (UTC)
Received: from fedora.. (p4ff9ff43.dip0.t-ipconnect.de [79.249.255.67])
	by mail.holtmann.org (Postfix) with ESMTPSA id 97953CECF4;
	Tue,  3 Jan 2023 23:02:53 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
To: ell@lists.linux.dev
Cc: andrew.zaborowski@intel.com
Subject: [PATCH 3/3] tls: Add support l_tls_set_alpn_list() and ALPN extension
Date: Tue,  3 Jan 2023 23:02:50 +0100
Message-Id: <20230103220250.717876-3-marcel@holtmann.org>
X-Mailer: git-send-email 2.39.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Add support for application layer protocol negotiation (ALPN) and
provide API for setting the list of client protocols and for getting the
server selected protocol.
---
 ell/ell.sym          |  2 ++
 ell/tls-extensions.c | 73 ++++++++++++++++++++++++++++++++++++++++++++
 ell/tls-private.h    |  2 ++
 ell/tls.c            | 21 +++++++++++++
 ell/tls.h            |  3 ++
 5 files changed, 101 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index f8148f257eb1..81c0cb7f5b94 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -515,6 +515,8 @@ global:
 	l_tls_close;
 	l_tls_reset;
 	l_tls_set_server_name;
+	l_tls_set_alpn_list;
+	l_tls_get_alpn;
 	l_tls_set_cacert;
 	l_tls_set_auth_data;
 	l_tls_set_version_range;
diff --git a/ell/tls-extensions.c b/ell/tls-extensions.c
index 75f47f6ba548..e5a7c7994b7d 100644
--- a/ell/tls-extensions.c
+++ b/ell/tls-extensions.c
@@ -52,6 +52,70 @@ static ssize_t tls_server_name_client_write(struct l_tls *tls,
 	return hlen + 5;
 }
 
+static ssize_t tls_alpn_client_write(struct l_tls *tls,
+						uint8_t *buf, size_t len)
+{
+	uint8_t *ptr = buf + 2;
+	uint16_t ext_len = 0;
+	int i;
+
+	if (!tls->alpn_list)
+		return -ENOMSG;
+
+	if (len < 2)
+		return -ENOMEM;
+
+	for (i = 0; tls->alpn_list[i]; i++) {
+		uint8_t str_len = strlen(tls->alpn_list[i]);
+		l_put_u8(str_len, ptr);
+		memcpy(ptr + 1, tls->alpn_list[i], str_len);
+		ptr += str_len + 1;
+		ext_len += str_len + 1;
+	}
+
+	l_put_be16(ext_len, buf);
+
+	return ext_len + 2;
+}
+
+static bool tls_alpn_server_handle(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	uint16_t ext_len;
+	uint8_t str_len;
+
+	if (len < 2)
+		return false;
+
+	ext_len = l_get_be16(buf);
+	if (ext_len != len - 2)
+		return false;
+
+	str_len = l_get_u8(buf + 2);
+	if (str_len != len - 3)
+		return false;
+
+	l_free(tls->selected_alpn);
+	tls->selected_alpn = l_strndup((const char *) buf + 3, str_len);
+
+	TLS_DEBUG("Negotiated ALPN %s", tls->selected_alpn);
+
+	return true;
+}
+
+static bool tls_alpn_server_absent(struct l_tls *tls)
+{
+	if (!tls->alpn_list)
+		return false;
+
+	l_free(tls->selected_alpn);
+	tls->selected_alpn = NULL;
+
+	TLS_DEBUG("ALPN not supported");
+
+	return true;
+}
+
 /* Most extensions are not used when resuming a cached session */
 #define SKIP_ON_RESUMPTION()	\
 	do {	\
@@ -1025,6 +1089,15 @@ const struct tls_hello_extension tls_extensions[] = {
 		tls_signature_algorithms_client_absent,
 		NULL, NULL, NULL,
 	},
+	{
+		"ALPN", "application_layer_protocol_negotiation", 16,
+		tls_alpn_client_write,
+		NULL,
+		NULL,
+		NULL,
+		tls_alpn_server_handle,
+		tls_alpn_server_absent,
+	},
 	{
 		"Secure Renegotiation", "renegotiation_info", 0xff01,
 		tls_renegotiation_info_client_write,
diff --git a/ell/tls-private.h b/ell/tls-private.h
index ac477885c5f7..dbc5457ef091 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -218,6 +218,8 @@ struct l_tls {
 
 	struct tls_cipher_suite **cipher_suite_pref_list;
 	char *server_name;
+	char **alpn_list;
+	char *selected_alpn;
 
 	struct l_settings *session_settings;
 	char *session_prefix;
diff --git a/ell/tls.c b/ell/tls.c
index 9556efd932bc..8c1c9040ff89 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -3421,6 +3421,8 @@ LIB_EXPORT void l_tls_free(struct l_tls *tls)
 		l_free(tls->cipher_suite_pref_list);
 
 	l_free(tls->server_name);
+	l_strv_free(tls->alpn_list);
+	l_free(tls->selected_alpn);
 	l_free(tls);
 }
 
@@ -3668,6 +3670,25 @@ LIB_EXPORT bool l_tls_set_server_name(struct l_tls *tls, const char *name)
 	return true;
 }
 
+LIB_EXPORT bool l_tls_set_alpn_list(struct l_tls *tls, const char **list)
+{
+	if (!tls)
+		return false;
+
+	l_strv_free(tls->alpn_list);
+	tls->alpn_list = l_strv_copy((char **) list);
+
+	return true;
+}
+
+LIB_EXPORT const char *l_tls_get_alpn(struct l_tls *tls)
+{
+	if (!tls)
+		return NULL;
+
+	return tls->selected_alpn;
+}
+
 LIB_EXPORT bool l_tls_set_cacert(struct l_tls *tls, struct l_queue *ca_certs)
 {
 	if (tls->ca_certs) {
diff --git a/ell/tls.h b/ell/tls.h
index c931b5db0a54..e33f7c070008 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -105,6 +105,9 @@ void l_tls_handle_rx(struct l_tls *tls, const uint8_t *data, size_t len);
 
 bool l_tls_set_server_name(struct l_tls *tls, const char *name);
 
+bool l_tls_set_alpn_list(struct l_tls *tls, const char **list);
+const char *l_tls_get_alpn(struct l_tls *tls);
+
 /*
  * If peer is to be authenticated, supply the CA certificates.  On success
  * the l_tls object takes ownership of the queue and the individual l_cert
-- 
2.39.0

