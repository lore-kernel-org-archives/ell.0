Content-Type: multipart/mixed; boundary="===============6166750643382406347=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 02/11] tls: Add Hello extension sending support
Date: Sat, 22 Dec 2018 05:16:26 +0100
Message-ID: <20181222041635.6533-2-andrew.zaborowski@intel.com>
In-Reply-To: <20181222041635.6533-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6166750643382406347==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Declare a struct for ServerHello/ClientHello extensions with write and
handle callbacks, modify our ServerHello and ClientHello message
builders to append the extensions to the messages.
---
 ell/tls-private.h |  18 +++++++++
 ell/tls.c         | 101 ++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 112 insertions(+), 7 deletions(-)

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
index f4cd94c..ffa09e1 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -709,6 +709,8 @@ static const struct tls_hash_algorithm *tls_set_prf_hma=
c(struct l_tls *tls)
 	return NULL;
 }
 =

+static const struct tls_hello_extension tls_extensions[] =3D {};
+
 enum tls_handshake_type {
 	TLS_HELLO_REQUEST	=3D 0,
 	TLS_CLIENT_HELLO	=3D 1,
@@ -812,11 +814,12 @@ static void tls_tx_handshake(struct l_tls *tls, int t=
ype, uint8_t *buf,
 =

 static bool tls_send_client_hello(struct l_tls *tls)
 {
-	uint8_t buf[128 + L_ARRAY_SIZE(tls_compression_pref) +
+	uint8_t buf[1024 + L_ARRAY_SIZE(tls_compression_pref) +
 			2 * L_ARRAY_SIZE(tls_cipher_suite_pref)];
 	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
 	uint8_t *len_ptr;
-	int i;
+	unsigned int i;
+	uint8_t *extensions_len_ptr;
 =

 	/* Fill in the Client Hello body */
 =

@@ -832,7 +835,7 @@ static bool tls_send_client_hello(struct l_tls *tls)
 	len_ptr =3D ptr;
 	ptr +=3D 2;
 =

-	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_cipher_suite_pref); i++) {
+	for (i =3D 0; i < L_ARRAY_SIZE(tls_cipher_suite_pref); i++) {
 		if (!tls_cipher_suite_is_compatible(tls,
 						&tls_cipher_suite_pref[i],
 						NULL))
@@ -850,17 +853,58 @@ static bool tls_send_client_hello(struct l_tls *tls)
 	l_put_be16((ptr - len_ptr - 2), len_ptr);
 	*ptr++ =3D L_ARRAY_SIZE(tls_compression_pref);
 =

-	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_compression_pref); i++)
+	for (i =3D 0; i < L_ARRAY_SIZE(tls_compression_pref); i++)
 		*ptr++ =3D tls_compression_pref[i].id;
 =

+	extensions_len_ptr =3D ptr;
+	ptr +=3D 2;
+
+	for (i =3D 0; tls_extensions[i].name; i++) {
+		const struct tls_hello_extension *extension =3D
+			&tls_extensions[i];
+		ssize_t ext_len;
+
+		/*
+		 * Note: could handle NULL client_write with non-NULL
+		 * server_handle or server_handle_absent as "server-oriented"
+		 * extension (7.4.1.4) and write empty extension_data and
+		 * simliarly require empty extension_data in
+		 * tls_handle_client_hello if client_handle NULL.
+		 */
+		if (!extension->client_write)
+			continue;
+
+		ext_len =3D extension->client_write(tls, ptr + 4,
+						buf + sizeof(buf) - (ptr + 4));
+		if (ext_len =3D=3D -ENOMSG)
+			continue;
+
+		if (ext_len < 0) {
+			TLS_DEBUG("%s extension's client_write: %s",
+					extension->name, strerror(-ext_len));
+			return false;
+		}
+
+		l_put_be16(extension->id, ptr + 0);
+		l_put_be16(ext_len, ptr + 2);
+		ptr +=3D 4 + ext_len;
+	}
+
+	if (ptr > extensions_len_ptr + 2)
+		l_put_be16(ptr - (extensions_len_ptr + 2), extensions_len_ptr);
+	else /* Skip the length if no extensions */
+		ptr =3D extensions_len_ptr;
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
+	uint8_t *extensions_len_ptr;
+	const struct l_queue_entry *entry;
 =

 	/* Fill in the Server Hello body */
 =

@@ -878,7 +922,49 @@ static void tls_send_server_hello(struct l_tls *tls)
 =

 	*ptr++ =3D tls->pending.compression_method->id;
 =

+	extensions_len_ptr =3D ptr;
+	ptr +=3D 2;
+
+	for (entry =3D l_queue_get_entries(extensions); entry;
+			entry =3D entry->next) {
+		uint16_t ext_id =3D L_PTR_TO_UINT(entry->data);
+		const struct tls_hello_extension *extension =3D NULL;
+		unsigned int i;
+		ssize_t ext_len;
+
+		for (i =3D 0; tls_extensions[i].name; i++)
+			if (tls_extensions[i].id =3D=3D ext_id) {
+				extension =3D &tls_extensions[i];
+				break;
+			}
+
+		if (!extension || !extension->server_write)
+			continue;
+
+		ext_len =3D extension->server_write(tls, ptr + 4,
+						buf + sizeof(buf) - (ptr + 4));
+		if (ext_len =3D=3D -ENOMSG)
+			continue;
+
+		if (ext_len < 0) {
+			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+					"%s extension's server_write: %s",
+					extension->name, strerror(-ext_len));
+			return false;
+		}
+
+		l_put_be16(ext_id, ptr + 0);
+		l_put_be16(ext_len, ptr + 2);
+		ptr +=3D 4 + ext_len;
+	}
+
+	if (ptr > extensions_len_ptr + 2)
+		l_put_be16(ptr - (extensions_len_ptr + 2), extensions_len_ptr);
+	else /* Skip the length if no extensions */
+		ptr =3D extensions_len_ptr;
+
 	tls_tx_handshake(tls, TLS_SERVER_HELLO, buf, ptr - buf);
+	return true;
 }
 =

 static bool tls_cert_list_add_size(struct l_cert *cert, void *user_data)
@@ -1644,7 +1730,8 @@ static void tls_handle_client_hello(struct l_tls *tls,
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


--===============6166750643382406347==--

