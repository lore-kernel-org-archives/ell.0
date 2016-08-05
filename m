Content-Type: multipart/mixed; boundary="===============6072782955445673425=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/6] tls: Convert encrypt and verify to l_key crypto
Date: Fri, 05 Aug 2016 13:53:17 -0700
Message-ID: <20160805205321.1427-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160805205321.1427-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6072782955445673425==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Keep track of the peer public key as a struct l_key (loaded in the
kernel), and use that key in encrypt and verify crypto operations.
---
 ell/tls-private.h |   3 +-
 ell/tls.c         | 131 ++++++++++++++++----------------------------------=
----
 2 files changed, 39 insertions(+), 95 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 1a47970..516d3db 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -164,8 +164,7 @@ struct l_tls {
 	bool cert_requested, cert_sent;
 	bool peer_authenticated;
 	struct tls_cert *peer_cert;
-	uint8_t *peer_pubkey;
-	size_t peer_pubkey_length;
+	struct l_key *peer_pubkey;
 	enum handshake_hash_type signature_hash;
 =

 	/* SecurityParameters current and pending */
diff --git a/ell/tls.c b/ell/tls.c
index 18e5fae..627b57d 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -36,6 +36,7 @@
 #include "pem.h"
 #include "tls-private.h"
 #include "cipher-private.h"
+#include "key.h"
 =

 void tls10_prf(const uint8_t *secret, size_t secret_len,
 		const char *label,
@@ -142,6 +143,7 @@ static void tls_reset_handshake(struct l_tls *tls)
 =

 	if (tls->peer_cert) {
 		l_free(tls->peer_cert);
+		l_key_free(tls->peer_pubkey);
 =

 		tls->peer_cert =3D NULL;
 		tls->peer_pubkey =3D NULL;
@@ -860,9 +862,9 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls *=
tls)
 	uint8_t buf[1024 + 32];
 	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
 	uint8_t pre_master_secret[48];
-	struct l_asymmetric_cipher *rsa_server_pubkey;
-	int key_size;
+	size_t key_size;
 	ssize_t bytes_encrypted;
+	bool is_public;
 =

 	if (!tls->peer_pubkey) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
@@ -874,37 +876,29 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls=
 *tls)
 	pre_master_secret[1] =3D (uint8_t) (TLS_VERSION >> 0);
 	l_getrandom(pre_master_secret + 2, 46);
 =

-	/* Fill in the RSA Client Key Exchange body */
-
-	rsa_server_pubkey =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_V1_5,
-							tls->peer_pubkey,
-							tls->peer_pubkey_length,
-							true);
-	if (!rsa_server_pubkey) {
+	if (!l_key_get_info(tls->peer_pubkey, L_CIPHER_RSA_PKCS1_V1_5,
+					L_CHECKSUM_NONE, &key_size,
+					&is_public)) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
 =

 		return false;
 	}
-
-	key_size =3D l_asymmetric_cipher_get_key_size(rsa_server_pubkey);
+	key_size /=3D 8;
 =

 	if (key_size + 32 > (int) sizeof(buf)) {
-		l_asymmetric_cipher_free(rsa_server_pubkey);
-
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
 =

 		return false;
 	}
 =

 	l_put_be16(key_size, ptr);
-	bytes_encrypted =3D l_asymmetric_cipher_encrypt(rsa_server_pubkey,
-							pre_master_secret,
-							ptr + 2, 48, key_size);
+	bytes_encrypted =3D l_key_encrypt(tls->peer_pubkey,
+					L_CIPHER_RSA_PKCS1_V1_5,
+					L_CHECKSUM_NONE, pre_master_secret,
+					ptr + 2, 48, key_size);
 	ptr +=3D key_size + 2;
 =

-	l_asymmetric_cipher_free(rsa_server_pubkey);
-
-	if (bytes_encrypted !=3D key_size) {
+	if (bytes_encrypted !=3D (ssize_t) key_size) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
 =

 		return false;
@@ -1006,16 +1000,15 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint=
8_t *out, size_t len,
 static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t le=
n,
 				tls_get_hash_t get_hash)
 {
-	struct l_asymmetric_cipher *rsa_client_pubkey;
 	size_t key_size;
-	ssize_t verify_bytes;
 	uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
 	size_t hash_len;
 	enum l_checksum_type hash_type;
 	uint8_t expected[HANDSHAKE_HASH_MAX_SIZE * 2 + 32];
 	size_t expected_len;
-	uint8_t *digest_info;
 	unsigned int offset;
+	bool is_public;
+	bool success;
 =

 	/* 2 bytes for SignatureAndHashAlgorithm if version >=3D 1.2 */
 	offset =3D 2;
@@ -1029,23 +1022,18 @@ static bool tls_rsa_verify(struct l_tls *tls, const=
 uint8_t *in, size_t len,
 		return false;
 	}
 =

-	rsa_client_pubkey =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_V1_5,
-							tls->peer_pubkey,
-							tls->peer_pubkey_length,
-							true);
-	if (!rsa_client_pubkey) {
+	if (!l_key_get_info(tls->peer_pubkey, L_CIPHER_RSA_PKCS1_V1_5,
+					L_CHECKSUM_NONE, &key_size,
+					&is_public)) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
-
-		return false;
 	}
-
-	key_size =3D l_asymmetric_cipher_get_key_size(rsa_client_pubkey);
+	key_size /=3D 8;
 =

 	/* Only the default hash type supported */
 	if (len !=3D offset + 2 + key_size) {
 		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
 =

-		goto err_free_rsa;
+		return false;
 	}
 =

 	if (tls->negotiated_version >=3D TLS_V12) {
@@ -1053,13 +1041,13 @@ static bool tls_rsa_verify(struct l_tls *tls, const=
 uint8_t *in, size_t len,
 		if (in[1] !=3D 1 /* RSA_sign */) {
 			tls_disconnect(tls, TLS_ALERT_DECRYPT_ERROR, 0);
 =

-			goto err_free_rsa;
+			return false;
 		}
 =

 		if (!get_hash(tls, in[0], hash, &hash_len, &hash_type)) {
 			tls_disconnect(tls, TLS_ALERT_DECRYPT_ERROR, 0);
 =

-			goto err_free_rsa;
+			return false;
 		}
 =

 		/*
@@ -1091,27 +1079,14 @@ static bool tls_rsa_verify(struct l_tls *tls, const=
 uint8_t *in, size_t len,
 		 */
 	}
 =

-	digest_info =3D alloca(expected_len);
-
-	verify_bytes =3D l_asymmetric_cipher_verify(rsa_client_pubkey, in + 4,
-							digest_info, key_size,
-							expected_len);
+	success =3D l_key_verify(tls->peer_pubkey, L_CIPHER_RSA_PKCS1_V1_5,
+				L_CHECKSUM_NONE, expected, in + 4,
+				expected_len, key_size);
 =

-	l_asymmetric_cipher_free(rsa_client_pubkey);
-
-	if (verify_bytes !=3D (ssize_t)expected_len ||
-		memcmp(digest_info, expected, expected_len)) {
+	if (!success)
 		tls_disconnect(tls, TLS_ALERT_DECRYPT_ERROR, 0);
 =

-		return false;
-	}
-
-	return true;
-
-err_free_rsa:
-	l_asymmetric_cipher_free(rsa_client_pubkey);
-
-	return false;
+	return success;
 }
 =

 static void tls_get_handshake_hash(struct l_tls *tls,
@@ -1496,10 +1471,9 @@ decode_error:
 static void tls_handle_certificate(struct l_tls *tls,
 					const uint8_t *buf, size_t len)
 {
-	int total, cert_len, pubkey_len;
+	int total, cert_len;
 	struct tls_cert *certchain =3D NULL, **tail =3D &certchain;
 	struct tls_cert *ca_cert =3D NULL;
-	uint8_t *pubkey;
 =

 	/* Length checks */
 =

@@ -1582,26 +1556,19 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
 		goto done;
 	}
 =

-	/*
-	 * Save the public key from the certificate for use in premaster
-	 * secret encryption.
-	 */
-	pubkey =3D tls_cert_find_pubkey(certchain, &pubkey_len);
-	if (!pubkey) {
-		tls_disconnect(tls, TLS_ALERT_UNSUPPORTED_CERT, 0);
+	/* Save the end-entity cert and free the rest of the chain */
+	tls->peer_cert =3D certchain;
+	tls_cert_free_certchain(certchain->issuer);
+	certchain->issuer =3D NULL;
+	certchain =3D NULL;
 =

-		goto done;
-	}
+	tls->peer_pubkey =3D l_key_new(L_KEY_RSA, tls->peer_cert->asn1,
+					tls->peer_cert->size);
 =

-	if (pubkey) {
-		/* Save the end-entity cert and free the rest of the chain */
-		tls->peer_cert =3D certchain;
-		tls_cert_free_certchain(certchain->issuer);
-		certchain->issuer =3D NULL;
-		certchain =3D NULL;
+	if (!tls->peer_pubkey) {
+		tls_disconnect(tls, TLS_ALERT_UNSUPPORTED_CERT, 0);
 =

-		tls->peer_pubkey =3D pubkey;
-		tls->peer_pubkey_length =3D pubkey_len;
+		goto done;
 	}
 =

 	if (tls->server)
@@ -2505,28 +2472,6 @@ void tls_cert_free_certchain(struct tls_cert *cert)
 	}
 }
 =

-uint8_t *tls_cert_find_pubkey(struct tls_cert *cert, int *pubkey_len)
-{
-	uint8_t *key;
-	size_t len;
-
-	key =3D der_find_elem_by_path(cert->asn1, cert->size, ASN1_ID_BIT_STRING,
-					&len,
-					X509_CERTIFICATE_POS,
-					X509_TBSCERTIFICATE_POS,
-					X509_TBSCERT_SUBJECT_KEY_POS,
-					X509_SUBJECT_KEY_VALUE_POS, -1);
-	if (!key || len < 10)
-		return NULL;
-
-	/* Skip the BIT STRING metadata byte */
-	key +=3D 1;
-	len -=3D 1;
-
-	*pubkey_len =3D len;
-	return key;
-}
-
 enum tls_cert_key_type tls_cert_get_pubkey_type(struct tls_cert *cert)
 {
 	uint8_t *key_type;
-- =

2.9.2


--===============6072782955445673425==--

