Content-Type: multipart/mixed; boundary="===============6811912941782997618=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 01/12] tls: Add Hello extension sending support
Date: Fri, 04 Jan 2019 02:26:29 +0100
Message-ID: <20190104012640.4022-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6811912941782997618==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Declare a struct for ServerHello/ClientHello extensions with write and
handle callbacks, modify our ServerHello and ClientHello message
builders to append the extensions to the messages.
---
 ell/tls-private.h |  18 +++++++
 ell/tls.c         | 125 +++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 136 insertions(+), 7 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 0908b9c..5ea8208 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -99,6 +99,24 @@ struct tls_compression_method {
 	const char *name;
 };
 =

+struct tls_hello_extension {
+	const char *name;
+	const char *short_name;
+	uint16_t id;
+	ssize_t (*client_write)(struct l_tls *tls, uint8_t *buf, size_t len);
+	/* Handle a Client Hello extension (on server), can't be NULL */
+	bool (*client_handle)(struct l_tls *tls,
+				const uint8_t *buf, size_t len);
+	/* Handle a Client Hello extension's absence (on server) */
+	bool (*client_handle_absent)(struct l_tls *tls);
+	ssize_t (*server_write)(struct l_tls *tls, uint8_t *buf, size_t len);
+	/* Handle a Server Hello extension (on client) */
+	bool (*server_handle)(struct l_tls *tls,
+				const uint8_t *buf, size_t len);
+	/* Handle a Server Hello extension's absence (on client) */
+	bool (*server_handle_absent)(struct l_tls *tls);
+};
+
 enum tls_handshake_state {
 	TLS_HANDSHAKE_WAIT_START,
 	TLS_HANDSHAKE_WAIT_HELLO,
diff --git a/ell/tls.c b/ell/tls.c
index f4cd94c..c44003a 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -709,6 +709,8 @@ static const struct tls_hash_algorithm *tls_set_prf_hma=
c(struct l_tls *tls)
 	return NULL;
 }
 =

+static const struct tls_hello_extension tls_extensions[] =3D {{}};
+
 enum tls_handshake_type {
 	TLS_HELLO_REQUEST	=3D 0,
 	TLS_CLIENT_HELLO	=3D 1,
@@ -810,13 +812,101 @@ static void tls_tx_handshake(struct l_tls *tls, int =
type, uint8_t *buf,
 	tls_tx_record(tls, TLS_CT_HANDSHAKE, buf, length);
 }
 =

+static ssize_t tls_append_hello_extensions(struct l_tls *tls,
+						struct l_queue *extensions,
+						uint8_t *buf, size_t len)
+{
+	uint8_t *ptr =3D buf;
+	uint8_t *extensions_len_ptr =3D ptr;
+	bool client_hello =3D !tls->server;
+	unsigned int i =3D 0;
+	const struct l_queue_entry *entry =3D l_queue_get_entries(extensions);
+
+	if (len < 2)
+		return -ENOSPC;
+
+	ptr +=3D 2;
+	len -=3D 2;
+
+	while (1) {
+		const struct tls_hello_extension *extension;
+		ssize_t ext_len;
+		ssize_t (*ext_write)(struct l_tls *tls,
+					uint8_t *buf, size_t len);
+
+		if (client_hello) {
+			extension =3D &tls_extensions[i++];
+			if (!extension->name)
+				break;
+
+			ext_write =3D extension->client_write;
+		} else  {
+			uint16_t ext_id;
+
+			if (!entry)
+				break;
+
+			ext_id =3D L_PTR_TO_UINT(entry->data);
+			entry =3D entry->next;
+
+			for (i =3D 0; tls_extensions[i].name; i++)
+				if (tls_extensions[i].id =3D=3D ext_id)
+					break;
+
+			extension =3D &tls_extensions[i];
+			if (!extension->name)
+				continue;
+
+			ext_write =3D extension->server_write;
+		}
+
+		/*
+		 * Note: could handle NULL client_write with non-NULL
+		 * server_handle or server_handle_absent as "server-oriented"
+		 * extension (7.4.1.4) and write empty extension_data and
+		 * simliarly require empty extension_data in
+		 * tls_handle_client_hello if client_handle NULL.
+		 */
+		if (!ext_write)
+			continue;
+
+		if (len < 4)
+			return -ENOSPC;
+
+		ext_len =3D ext_write(tls, ptr + 4, len - 4);
+		if (ext_len =3D=3D -ENOMSG)
+			continue;
+
+		if (ext_len < 0) {
+			TLS_DEBUG("%s extension's %s_write: %s",
+					extension->name,
+					client_hello ? "client" : "server",
+					strerror(-ext_len));
+			return ext_len;
+		}
+
+		l_put_be16(extension->id, ptr + 0);
+		l_put_be16(ext_len, ptr + 2);
+		ptr +=3D 4 + ext_len;
+		len -=3D 4 + ext_len;
+	}
+
+	if (ptr > extensions_len_ptr + 2)
+		l_put_be16(ptr - (extensions_len_ptr + 2), extensions_len_ptr);
+	else /* Skip the length if no extensions */
+		ptr =3D extensions_len_ptr;
+
+	return ptr - buf;
+}
+
 static bool tls_send_client_hello(struct l_tls *tls)
 {
-	uint8_t buf[128 + L_ARRAY_SIZE(tls_compression_pref) +
+	uint8_t buf[1024 + L_ARRAY_SIZE(tls_compression_pref) +
 			2 * L_ARRAY_SIZE(tls_cipher_suite_pref)];
 	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
 	uint8_t *len_ptr;
-	int i;
+	unsigned int i;
+	ssize_t r;
 =

 	/* Fill in the Client Hello body */
 =

@@ -832,7 +922,7 @@ static bool tls_send_client_hello(struct l_tls *tls)
 	len_ptr =3D ptr;
 	ptr +=3D 2;
 =

-	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_cipher_suite_pref); i++) {
+	for (i =3D 0; i < L_ARRAY_SIZE(tls_cipher_suite_pref); i++) {
 		if (!tls_cipher_suite_is_compatible(tls,
 						&tls_cipher_suite_pref[i],
 						NULL))
@@ -850,17 +940,25 @@ static bool tls_send_client_hello(struct l_tls *tls)
 	l_put_be16((ptr - len_ptr - 2), len_ptr);
 	*ptr++ =3D L_ARRAY_SIZE(tls_compression_pref);
 =

-	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_compression_pref); i++)
+	for (i =3D 0; i < L_ARRAY_SIZE(tls_compression_pref); i++)
 		*ptr++ =3D tls_compression_pref[i].id;
 =

+	r =3D tls_append_hello_extensions(tls, NULL,
+					ptr, buf + sizeof(buf) - ptr);
+	if (r < 0)
+		return false;
+
+	ptr +=3D r;
+
 	tls_tx_handshake(tls, TLS_CLIENT_HELLO, buf, ptr - buf);
 	return true;
 }
 =

-static void tls_send_server_hello(struct l_tls *tls)
+static bool tls_send_server_hello(struct l_tls *tls, struct l_queue *exten=
sions)
 {
-	uint8_t buf[128];
+	uint8_t buf[1024];
 	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
+	ssize_t r;
 =

 	/* Fill in the Server Hello body */
 =

@@ -878,7 +976,19 @@ static void tls_send_server_hello(struct l_tls *tls)
 =

 	*ptr++ =3D tls->pending.compression_method->id;
 =

+	r =3D tls_append_hello_extensions(tls, extensions,
+					ptr, buf + sizeof(buf) - ptr);
+	if (r < 0) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Error appending extensions: %s",
+				strerror(-r));
+		return false;
+	}
+
+	ptr +=3D r;
+
 	tls_tx_handshake(tls, TLS_SERVER_HELLO, buf, ptr - buf);
+	return true;
 }
 =

 static bool tls_cert_list_add_size(struct l_cert *cert, void *user_data)
@@ -1644,7 +1754,8 @@ static void tls_handle_client_hello(struct l_tls *tls,
 =

 	TLS_DEBUG("Negotiated %s", tls->pending.compression_method->name);
 =

-	tls_send_server_hello(tls);
+	if (!tls_send_server_hello(tls, NULL))
+		return;
 =

 	if (tls->pending.cipher_suite->key_xchg->certificate_check && tls->cert)
 		if (!tls_send_certificate(tls))
-- =

2.19.1


--===============6811912941782997618==--

