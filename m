Content-Type: multipart/mixed; boundary="===============5063040184918147645=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/4] tls: Handle CertificateRequest using common code
Date: Fri, 08 Feb 2019 16:31:45 +0100
Message-ID: <20190208153147.30969-2-andrew.zaborowski@intel.com>
In-Reply-To: <20190208153147.30969-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5063040184918147645==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use the new, more complete code added for the Signature Algorithms
extensions to parse and generate the signature algorithms data in the
Certificate Request messages.  Get rid of a few TODOs this way.

The signature algorithms data in both messages serves mostly the same
purpose.
---
 ell/tls-extensions.c |   8 +--
 ell/tls-private.h    |   5 ++
 ell/tls-suites.c     |   2 +-
 ell/tls.c            | 138 +++++++++++++------------------------------
 4 files changed, 52 insertions(+), 101 deletions(-)

diff --git a/ell/tls-extensions.c b/ell/tls-extensions.c
index 7b20e17..2e2d9da 100644
--- a/ell/tls-extensions.c
+++ b/ell/tls-extensions.c
@@ -602,8 +602,8 @@ static ssize_t tls_ec_point_formats_server_write(struct=
 l_tls *tls,
  * with the hash algorithms we can use for signature verification,
  * i.e. those in the tls_handshake_hash_data table.
  */
-static ssize_t tls_write_signature_algorithms(struct l_tls *tls,
-						uint8_t *buf, size_t len)
+ssize_t tls_write_signature_algorithms(struct l_tls *tls,
+					uint8_t *buf, size_t len)
 {
 	uint8_t *ptr =3D buf;
 	unsigned int i, j;
@@ -669,8 +669,8 @@ static ssize_t tls_write_signature_algorithms(struct l_=
tls *tls,
 	return ptr - buf;
 }
 =

-static ssize_t tls_parse_signature_algorithms(struct l_tls *tls,
-						const uint8_t *buf, size_t len)
+ssize_t tls_parse_signature_algorithms(struct l_tls *tls,
+					const uint8_t *buf, size_t len)
 {
 	const uint8_t *ptr =3D buf;
 	enum handshake_hash_type first_supported, hash;
diff --git a/ell/tls-private.h b/ell/tls-private.h
index 2d1424e..bf9e2ec 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -325,6 +325,11 @@ const struct tls_named_group *tls_find_ff_group(const =
uint8_t *prime,
 						const uint8_t *generator,
 						size_t generator_len);
 =

+ssize_t tls_write_signature_algorithms(struct l_tls *tls,
+					uint8_t *buf, size_t len);
+ssize_t tls_parse_signature_algorithms(struct l_tls *tls,
+					const uint8_t *buf, size_t len);
+
 int tls_parse_certificate_list(const void *data, size_t len,
 				struct l_certchain **out_certchain);
 =

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index c11c28d..18ac366 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -213,7 +213,7 @@ static bool tls_rsa_verify(struct l_tls *tls, const uin=
t8_t *in, size_t in_len,
 }
 =

 static struct tls_signature_algorithm tls_rsa_signature =3D {
-	.id =3D 1, /* RSA_sign */
+	.id =3D 1, /* SignatureAlgorithm.rsa */
 	.validate_cert_key_type =3D tls_rsa_validate_cert_key,
 	.sign =3D tls_rsa_sign,
 	.verify =3D tls_rsa_verify,
diff --git a/ell/tls.c b/ell/tls.c
index fd898f6..27f291a 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -951,7 +951,7 @@ static bool tls_send_certificate(struct l_tls *tls)
 	/*
 	 * TODO: check that the certificate is compatible with hash and
 	 * signature algorithms lists supplied to us in the Client Hello
-	 * extensions (if we're a server) or in the Certificate Request
+	 * extensions (if we're a 1.2+ server) or in the Certificate Request
 	 * (if we act as a 1.2+ client).
 	 *
 	 *  - for the hash and signature_algorithms list, check all
@@ -988,26 +988,20 @@ static bool tls_send_certificate(struct l_tls *tls)
 	return true;
 }
 =

+/*
+ * Note: ClientCertificateType.rsa_sign value coincides with the
+ * SignatureAlgorithm.rsa value but other values in those enum are
+ * different so we don't mix them, can't extract them from
+ * tls->pending.cipher_suite->signature.
+ */
 static uint8_t tls_cert_type_pref[] =3D {
 	1, /* RSA_sign */
 };
 =

-struct tls_signature_hash_algorithms {
-	uint8_t hash_id;
-	uint8_t signature_id;
-};
-
-static struct tls_signature_hash_algorithms tls_signature_hash_pref[] =3D {
-	{ 6, 1 }, /* SHA512 + RSA */
-	{ 5, 1 }, /* SHA384 + RSA */
-	{ 4, 1 }, /* SHA256 + RSA */
-	{ 2, 1 }, /* SHA1 + RSA */
-	{ 1, 1 }, /* MD5 + RSA */
-};
-
 static bool tls_send_certificate_request(struct l_tls *tls)
 {
-	uint8_t *buf, *ptr, *dn_ptr, *signature_hash_ptr;
+	uint8_t *buf, *ptr, *dn_ptr;
+	size_t len;
 	const struct l_queue_entry *entry;
 	unsigned int i;
 	size_t dn_total =3D 0;
@@ -1021,9 +1015,8 @@ static bool tls_send_certificate_request(struct l_tls=
 *tls)
 			dn_total +=3D 10 + dn_size;
 	}
 =

-	buf =3D l_malloc(128 + L_ARRAY_SIZE(tls_cert_type_pref) +
-			2 * L_ARRAY_SIZE(tls_signature_hash_pref) +
-			dn_total);
+	len =3D 256 + L_ARRAY_SIZE(tls_cert_type_pref) + dn_total;
+	buf =3D l_malloc(len);
 	ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
 =

 	/* Fill in the Certificate Request body */
@@ -1032,27 +1025,19 @@ static bool tls_send_certificate_request(struct l_t=
ls *tls)
 	for (i =3D 0; i < L_ARRAY_SIZE(tls_cert_type_pref); i++)
 		*ptr++ =3D tls_cert_type_pref[i];
 =

-	/*
-	 * This only makes sense as a variable-length field, assume there's
-	 * a typo in RFC5246 7.4.4 here.
-	 *
-	 * TODO: we support the full list of hash algorithms when used
-	 * in the client certificate chain but we can only verify the
-	 * Certificate Verify signature when the hash algorithm matches
-	 * one of HANDSHAKE_HASH_*.  The values we include here will
-	 * affect both of these steps so revisit which set we're passing
-	 * here.
-	 */
 	if (tls->negotiated_version >=3D L_TLS_V12) {
-		signature_hash_ptr =3D ptr;
-		ptr +=3D 2;
+		ssize_t ret =3D tls_write_signature_algorithms(tls, ptr,
+							buf + len - ptr);
 =

-		for (i =3D 0; i < L_ARRAY_SIZE(tls_signature_hash_pref); i++) {
-			*ptr++ =3D tls_signature_hash_pref[i].hash_id;
-			*ptr++ =3D tls_signature_hash_pref[i].signature_id;
+		if (ret < 0) {
+			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+					"tls_write_signature_algorithms: %s",
+					strerror(-ret));
+			l_free(buf);
+			return false;
 		}
 =

-		l_put_be16(ptr - (signature_hash_ptr + 2), signature_hash_ptr);
+		ptr +=3D ret;
 	}
 =

 	dn_ptr =3D ptr;
@@ -1857,18 +1842,24 @@ done:
 static void tls_handle_certificate_request(struct l_tls *tls,
 						const uint8_t *buf, size_t len)
 {
-	int cert_type_len, signature_hash_len, dn_len, i;
-	enum handshake_hash_type first_supported, hash;
-	const uint8_t *signature_hash_data;
-	uint8_t hash_id;
+	unsigned int cert_type_len, dn_len, i;
 =

 	tls->cert_requested =3D 1;
 =

 	cert_type_len =3D *buf++;
-	if (len < (size_t) 1 + cert_type_len + 2)
+	if (len < 1 + cert_type_len + 2)
 		goto decode_error;
 =

-	/* Skip certificate_types */
+	for (i =3D 0; i < sizeof(tls_cert_type_pref); i++)
+		if (memchr(buf, tls_cert_type_pref[i], cert_type_len))
+			break;
+
+	if (i =3D=3D sizeof(tls_cert_type_pref)) {
+		TLS_DISCONNECT(TLS_ALERT_UNSUPPORTED_CERT, 0,
+				"Requested certificate types not supported");
+		return;
+	}
+
 	buf +=3D cert_type_len;
 	len -=3D 1 + cert_type_len;
 =

@@ -1879,66 +1870,21 @@ static void tls_handle_certificate_request(struct l=
_tls *tls,
 	 */
 =

 	if (tls->negotiated_version >=3D L_TLS_V12) {
-		/*
-		 * This only makes sense as a variable-length field, assume
-		 * there's a typo in RFC5246 7.4.4 here.
-		 */
-		signature_hash_len =3D l_get_be16(buf);
-		signature_hash_data =3D buf + 2;
-
-		if (len < (size_t) 2 + signature_hash_len + 2 ||
-				(signature_hash_len & 1))
-			goto decode_error;
-
-		len -=3D 2 + signature_hash_len;
-		buf +=3D 2 + signature_hash_len;
-
-		/*
-		 * In 1.2 SHA256 is the default because that is most likely
-		 * to be supported in all the scenarios and optimal because
-		 * SHA256 is required independently for the Finished hash
-		 * meaning that we'll just need one hash type instead of
-		 * two.  If not available fall back to the first common
-		 * hash algorithm.
-		 */
-		first_supported =3D -1;
-
-		for (i =3D 0; i < signature_hash_len; i +=3D 2) {
-			hash_id =3D signature_hash_data[i + 0];
-
-			/* Ignore hash types for signatures other than ours */
-			if (signature_hash_data[i + 1] !=3D
-					tls->pending.cipher_suite->
-						signature->id)
-				continue;
-
-			if (hash_id =3D=3D tls_handshake_hash_data[
-						HANDSHAKE_HASH_SHA256].tls_id)
-				break;
-
-			if ((int) first_supported !=3D -1)
-				continue;
-
-			for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
-				if (hash_id =3D=3D tls_handshake_hash_data[hash].
-						tls_id &&
-						tls->handshake_hash[hash]) {
-					first_supported =3D hash;
-					break;
-				}
-		}
+		enum handshake_hash_type hash;
+		ssize_t ret =3D tls_parse_signature_algorithms(tls, buf, len);
 =

-		if (i < signature_hash_len)
-			tls->signature_hash =3D HANDSHAKE_HASH_SHA256;
-		else if ((int) first_supported !=3D -1)
-			tls->signature_hash =3D first_supported;
-		else {
+		if (ret =3D=3D -ENOTSUP) {
 			TLS_DISCONNECT(TLS_ALERT_UNSUPPORTED_CERT, 0,
 					"No supported signature hash type");
-
 			return;
 		}
 =

+		if (ret < 0)
+			goto decode_error;
+
+		len -=3D ret;
+		buf +=3D ret;
+
 		/*
 		 * We can now safely stop maintaining handshake message
 		 * hashes other than the PRF hash and the one selected for
@@ -1951,7 +1897,7 @@ static void tls_handle_certificate_request(struct l_t=
ls *tls,
 	}
 =

 	dn_len =3D l_get_be16(buf);
-	if ((size_t) 2 + dn_len !=3D len)
+	if (2 + dn_len !=3D len)
 		goto decode_error;
 =

 	return;
-- =

2.19.1


--===============5063040184918147645==--

