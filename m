Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 057458F77
	for <ell@lists.linux.dev>; Tue,  3 Jan 2023 22:02:56 +0000 (UTC)
Received: from fedora.. (p4ff9ff43.dip0.t-ipconnect.de [79.249.255.67])
	by mail.holtmann.org (Postfix) with ESMTPSA id 70B3DCECF3;
	Tue,  3 Jan 2023 23:02:53 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
To: ell@lists.linux.dev
Cc: andrew.zaborowski@intel.com
Subject: [PATCH 2/3] tls: Add support for l_tls_set_server_name and SNI extension
Date: Tue,  3 Jan 2023 23:02:49 +0100
Message-Id: <20230103220250.717876-2-marcel@holtmann.org>
X-Mailer: git-send-email 2.39.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Add suport for Server Name Indication (SNI) extension and provide API
function to set the server name as part of the TLS connection.
---
 ell/ell.sym          |  1 +
 ell/tls-extensions.c | 28 ++++++++++++++++++++++++++++
 ell/tls-private.h    |  1 +
 ell/tls.c            | 12 ++++++++++++
 ell/tls.h            |  2 ++
 5 files changed, 44 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 4d8596e0b7ae..f8148f257eb1 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -514,6 +514,7 @@ global:
 	l_tls_start;
 	l_tls_close;
 	l_tls_reset;
+	l_tls_set_server_name;
 	l_tls_set_cacert;
 	l_tls_set_auth_data;
 	l_tls_set_version_range;
diff --git a/ell/tls-extensions.c b/ell/tls-extensions.c
index bc8fc3d487b9..75f47f6ba548 100644
--- a/ell/tls-extensions.c
+++ b/ell/tls-extensions.c
@@ -31,6 +31,27 @@
 #include "cert.h"
 #include "tls-private.h"
 
+static ssize_t tls_server_name_client_write(struct l_tls *tls,
+						uint8_t *buf, size_t len)
+{
+	size_t hlen;
+
+	if (!tls->server_name)
+		return -ENOMSG;
+
+	hlen = strlen(tls->server_name);
+
+	if (len < hlen + 5)
+		return -ENOMEM;
+
+	l_put_be16(hlen + 3, buf);
+	l_put_u8(0, buf + 2);
+	l_put_be16(hlen, buf + 3);
+	memcpy(buf + 5, tls->server_name, hlen);
+
+	return hlen + 5;
+}
+
 /* Most extensions are not used when resuming a cached session */
 #define SKIP_ON_RESUMPTION()	\
 	do {	\
@@ -975,6 +996,13 @@ static bool tls_renegotiation_info_absent(struct l_tls *tls)
 }
 
 const struct tls_hello_extension tls_extensions[] = {
+	{
+		"Server Name", "server_name", 0,
+		tls_server_name_client_write,
+		NULL,
+		NULL,
+		NULL, NULL, NULL,
+	},
 	{
 		"Supported Groups", "elliptic_curves", 10,
 		tls_elliptic_curves_client_write,
diff --git a/ell/tls-private.h b/ell/tls-private.h
index bfd20b10cf88..ac477885c5f7 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -217,6 +217,7 @@ struct l_tls {
 	char **subject_mask;
 
 	struct tls_cipher_suite **cipher_suite_pref_list;
+	char *server_name;
 
 	struct l_settings *session_settings;
 	char *session_prefix;
diff --git a/ell/tls.c b/ell/tls.c
index 330ad4841e25..9556efd932bc 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -3420,6 +3420,7 @@ LIB_EXPORT void l_tls_free(struct l_tls *tls)
 	if (tls->cipher_suite_pref_list != tls_cipher_suite_pref)
 		l_free(tls->cipher_suite_pref_list);
 
+	l_free(tls->server_name);
 	l_free(tls);
 }
 
@@ -3656,6 +3657,17 @@ LIB_EXPORT void l_tls_reset(struct l_tls *tls)
 	tls->message_buf_len = 0;
 }
 
+LIB_EXPORT bool l_tls_set_server_name(struct l_tls *tls, const char *name)
+{
+	if (!tls)
+		return false;
+
+	l_free(tls->server_name);
+	tls->server_name = l_strdup(name);
+
+	return true;
+}
+
 LIB_EXPORT bool l_tls_set_cacert(struct l_tls *tls, struct l_queue *ca_certs)
 {
 	if (tls->ca_certs) {
diff --git a/ell/tls.h b/ell/tls.h
index cca8792a3262..c931b5db0a54 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -103,6 +103,8 @@ void l_tls_write(struct l_tls *tls, const uint8_t *data, size_t len);
 /* Submit TLS payload from underlying transport to be decrypted */
 void l_tls_handle_rx(struct l_tls *tls, const uint8_t *data, size_t len);
 
+bool l_tls_set_server_name(struct l_tls *tls, const char *name);
+
 /*
  * If peer is to be authenticated, supply the CA certificates.  On success
  * the l_tls object takes ownership of the queue and the individual l_cert
-- 
2.39.0

