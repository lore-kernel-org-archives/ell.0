Content-Type: multipart/mixed; boundary="===============4140844755497619707=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 03/11] tls: Parse and process received extensions
Date: Sat, 22 Dec 2018 05:16:27 +0100
Message-ID: <20181222041635.6533-3-andrew.zaborowski@intel.com>
In-Reply-To: <20181222041635.6533-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4140844755497619707==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On the server call the .client_handle callbacks for each supported
extension in the received ClientHello and pass the list of extensions
we've handled to the ServerHello builder.  On the client, process the
extension responses in the ServerHello by calling .server_handle
callbacks.
---
 ell/tls.c | 179 ++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 154 insertions(+), 25 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index ffa09e1..f8ba3d0 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1577,6 +1577,135 @@ static bool tls_verify_finished(struct l_tls *tls, =
const uint8_t *received,
 	return true;
 }
 =

+static bool tls_ptr_match(const void *a, const void *b)
+{
+	return a =3D=3D b;
+}
+
+static bool tls_handle_hello_extensions(struct l_tls *tls,
+					const uint8_t *buf, size_t len,
+					struct l_queue *seen)
+{
+	unsigned int i;
+	const struct tls_hello_extension *extension;
+	bool client_hello =3D tls->server;
+	uint16_t extensions_size;
+
+	if (!len)
+		return true;
+
+	if (len < 2 || len > 2 + 65535)
+		goto decode_error;
+
+	extensions_size =3D l_get_be16(buf);
+	len -=3D 2;
+	buf +=3D 2;
+
+	if (len !=3D extensions_size)
+		goto decode_error;
+
+	while (len) {
+		uint16_t ext_id;
+		size_t ext_len;
+		bool (*handler)(struct l_tls *tls,
+				const uint8_t *buf, size_t len);
+
+		if (len < 4)
+			goto decode_error;
+
+		ext_id =3D l_get_be16(buf + 0);
+		ext_len =3D l_get_be16(buf + 2);
+		buf +=3D 4;
+		len -=3D 4;
+
+		if (ext_len > len)
+			goto decode_error;
+
+		/*
+		 * RFC 5246, Section 7.4.1.4: "There MUST NOT be more than
+		 * one extension of the same type."
+		 */
+		if (l_queue_find(seen, tls_ptr_match, L_UINT_TO_PTR(ext_id))) {
+			TLS_DEBUG("Duplicate extension %u", ext_id);
+			goto decode_error;
+		}
+
+		l_queue_push_tail(seen, L_UINT_TO_PTR(ext_id));
+
+		extension =3D NULL;
+
+		for (i =3D 0; tls_extensions[i].name; i++)
+			if (tls_extensions[i].id =3D=3D ext_id) {
+				extension =3D &tls_extensions[i];
+				break;
+			}
+
+		if (!extension)
+			goto next;
+
+		handler =3D client_hello ?
+			extension->client_handle : extension->server_handle;
+
+		/*
+		 * RFC 5246, Section 7.4.1.4: "If a client receives an
+		 * extension type in ServerHello that it did not request in
+		 * the associated ClientHello, it MUST abort the handshake
+		 * with an unsupported_extension fatal alert."
+		 */
+		if (!client_hello && !handler) {
+			TLS_DISCONNECT(TLS_ALERT_UNSUPPORTED_EXTENSION, 0,
+					"%s extension not expected in "
+					"a ServerHello", extension->name);
+			return false;
+		}
+
+		if (!handler(tls, buf, ext_len)) {
+			TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+					"Hello %s extension parse error",
+					extension->name);
+			return false;
+		}
+
+next:
+		buf +=3D ext_len;
+		len -=3D ext_len;
+	}
+
+	/*
+	 * Trigger any actions needed when an extension is missing and its
+	 * handler has not been called yet.
+	 */
+	for (i =3D 0; tls_extensions[i].name; i++) {
+		bool (*handler)(struct l_tls *tls);
+
+		extension =3D &tls_extensions[i];
+		handler =3D client_hello ?
+			extension->client_handle_absent :
+			extension->server_handle_absent;
+
+		if (!handler)
+			continue;
+
+		if (l_queue_find(seen, tls_ptr_match,
+					L_UINT_TO_PTR(extension->id)))
+			continue;
+
+		if (!handler(tls)) {
+			TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+					"Hello %s extension missing",
+					extension->name);
+			return false;
+		}
+	}
+
+	return true;
+
+decode_error:
+	TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+			"Hello extensions decode error");
+	return false;
+}
+
 static void tls_handle_client_hello(struct l_tls *tls,
 					const uint8_t *buf, size_t len)
 {
@@ -1585,6 +1714,7 @@ static void tls_handle_client_hello(struct l_tls *tls,
 	const uint8_t *cipher_suites;
 	const uint8_t *compression_methods;
 	int i;
+	struct l_queue *extensions_offered =3D NULL;
 =

 	/* Do we have enough for ProtocolVersion + Random + SessionID size? */
 	if (len < 2 + 32 + 1)
@@ -1626,22 +1756,12 @@ static void tls_handle_client_hello(struct l_tls *t=
ls,
 =

 	len -=3D compression_methods_size;
 =

-	if (len) {
-		uint16_t extensions_size;
+	extensions_offered =3D l_queue_new();
 =

-		if (len < 2 || len > 2 + 65535)
-			goto decode_error;
-
-		extensions_size =3D l_get_be16(compression_methods +
-						compression_methods_size);
-		len -=3D 2;
-
-		if (len !=3D extensions_size)
-			goto decode_error;
-
-		/* TODO: validate each extension in the vector, 7.4.1.4 */
-		/* TODO: check for duplicates? */
-	}
+	if (!tls_handle_hello_extensions(tls, compression_methods +
+					compression_methods_size,
+					len, extensions_offered))
+		goto cleanup;
 =

 	/*
 	 * Note: if the client is supplying a SessionID we know it is false
@@ -1664,7 +1784,7 @@ static void tls_handle_client_hello(struct l_tls *tls,
 		TLS_DISCONNECT(TLS_ALERT_PROTOCOL_VERSION, 0,
 				"Client version too low: %02x",
 				tls->client_version);
-		return;
+		goto cleanup;
 	}
 =

 	tls->negotiated_version =3D TLS_VERSION < tls->client_version ?
@@ -1697,13 +1817,13 @@ static void tls_handle_client_hello(struct l_tls *t=
ls,
 		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
 				"No common cipher suites matching negotiated "
 				"TLS version and our certificate's key type");
-		return;
+		goto cleanup;
 	}
 =

 	if (!tls_set_prf_hmac(tls)) {
 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
 				"Error selecting the PRF HMAC");
-		return;
+		goto cleanup;
 	}
 =

 	TLS_DEBUG("Negotiated %s", tls->pending.cipher_suite->name);
@@ -1714,7 +1834,7 @@ static void tls_handle_client_hello(struct l_tls *tls,
 	if (!memchr(compression_methods, 0, compression_methods_size)) {
 		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
 				"No common compression methods");
-		return;
+		goto cleanup;
 	}
 =

 	while (compression_methods_size) {
@@ -1730,8 +1850,10 @@ static void tls_handle_client_hello(struct l_tls *tl=
s,
 =

 	TLS_DEBUG("Negotiated %s", tls->pending.compression_method->name);
 =

-	if (!tls_send_server_hello(tls, NULL))
-		return;
+	if (!tls_send_server_hello(tls, extensions_offered))
+		goto cleanup;
+
+	l_queue_destroy(extensions_offered, NULL);
 =

 	if (tls->pending.cipher_suite->key_xchg->certificate_check && tls->cert)
 		if (!tls_send_certificate(tls))
@@ -1756,6 +1878,9 @@ static void tls_handle_client_hello(struct l_tls *tls,
 decode_error:
 	TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
 			"ClientHello decode error");
+
+cleanup:
+	l_queue_destroy(extensions_offered, NULL);
 }
 =

 static void tls_handle_server_hello(struct l_tls *tls,
@@ -1764,6 +1889,8 @@ static void tls_handle_server_hello(struct l_tls *tls,
 	uint8_t session_id_size, cipher_suite_id[2], compression_method_id;
 	const char *error;
 	int i;
+	struct l_queue *extensions_seen;
+	bool result;
 =

 	/* Do we have enough for ProtocolVersion + Random + SessionID len ? */
 	if (len < 2 + 32 + 1)
@@ -1782,11 +1909,13 @@ static void tls_handle_server_hello(struct l_tls *t=
ls,
 	compression_method_id =3D buf[35 + session_id_size + 2];
 	len -=3D session_id_size + 2 + 1;
 =

-	if (len !=3D 0) { /* We know we haven't solicited any extensions */
-		TLS_DISCONNECT(TLS_ALERT_UNSUPPORTED_EXTENSION, 0,
-				"ServerHello contains extensions");
+	extensions_seen =3D l_queue_new();
+	result =3D tls_handle_hello_extensions(tls, buf + 38 + session_id_size,
+						len, extensions_seen);
+	l_queue_destroy(extensions_seen, NULL);
+
+	if (!result)
 		return;
-	}
 =

 	tls->negotiated_version =3D l_get_be16(buf);
 =

-- =

2.19.1


--===============4140844755497619707==--

