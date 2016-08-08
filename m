Content-Type: multipart/mixed; boundary="===============3614762818836312636=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 3/6] tls: Use l_key crypto for decrypt and sign
Date: Mon, 08 Aug 2016 10:25:42 -0700
Message-ID: <20160808172545.6648-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160808172545.6648-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3614762818836312636==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Store the private key in a struct l_key when auth is configured so the
key doesn't need to be reloaded for each use. The key path and password
are no longer needed in memory once the key is configured.

l_asymmetric_cipher is no longer used by TLS.
---
 ell/tls-private.h |   4 +-
 ell/tls.c         | 142 +++++++++++++++++++-------------------------------=
----
 ell/tls.h         |   2 +-
 3 files changed, 53 insertions(+), 95 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 516d3db..31f45b9 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -139,8 +139,8 @@ struct l_tls {
 =

 	char *ca_cert_path;
 	char *cert_path;
-	char *priv_key_path;
-	char *priv_key_passphrase;
+	struct l_key *priv_key;
+	size_t priv_key_size;
 =

 	/* Record layer */
 =

diff --git a/ell/tls.c b/ell/tls.c
index da3832c..516d855 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -119,12 +119,6 @@ static void tls_write_random(uint8_t *buf)
 	l_getrandom(buf + 4, 28);
 }
 =

-static void tls_free_key(uint8_t *key, size_t size)
-{
-	memset(key, 0, size);
-	l_free(key);
-}
-
 static void tls_drop_handshake_hash(struct l_tls *tls,
 					enum handshake_hash_type hash)
 {
@@ -916,9 +910,6 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls *=
tls)
 static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t *out, size_t len,
 				tls_get_hash_t get_hash)
 {
-	struct l_asymmetric_cipher *rsa_privkey;
-	uint8_t *privkey;
-	size_t key_size;
 	ssize_t result;
 	const struct tls_hash_algorithm *hash_type;
 	uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
@@ -927,35 +918,14 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_=
t *out, size_t len,
 	bool prepend_hash_type =3D false;
 	size_t expected_bytes;
 =

-	if (!tls->priv_key_path) {
+	if (!tls->priv_key || !tls->priv_key_size) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
 				TLS_ALERT_BAD_CERT);
 =

 		return -ENOKEY;
 	}
 =

-	privkey =3D l_pem_load_private_key(tls->priv_key_path,
-						tls->priv_key_passphrase,
-						&key_size);
-	if (!privkey) {
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
-				TLS_ALERT_BAD_CERT);
-
-		return -ENOKEY;
-	}
-
-	rsa_privkey =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_V1_5,
-						privkey, key_size, false);
-	tls_free_key(privkey, key_size);
-
-	if (!rsa_privkey) {
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
-
-		return -ENOKEY;
-	}
-
-	key_size =3D l_asymmetric_cipher_get_key_size(rsa_privkey);
-	expected_bytes =3D key_size + 2;
+	expected_bytes =3D tls->priv_key_size + 2;
 =

 	if (tls->negotiated_version >=3D TLS_V12) {
 		hash_type =3D &tls_handshake_hash_data[tls->signature_hash];
@@ -981,17 +951,15 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_=
t *out, size_t len,
 			*out++ =3D 1;	/* RSA_sign */
 		}
 =

-		l_put_be16(key_size, out);
-		result =3D l_asymmetric_cipher_sign(rsa_privkey, sign_input,
-							out + 2, sign_input_len,
-							key_size);
+		l_put_be16(tls->priv_key_size, out);
+		result =3D l_key_sign(tls->priv_key, L_CIPHER_RSA_PKCS1_V1_5,
+					L_CHECKSUM_NONE, sign_input, out + 2,
+					sign_input_len, tls->priv_key_size);
 =

-		if (result =3D=3D (ssize_t) key_size)
+		if (result =3D=3D (ssize_t) tls->priv_key_size)
 			result =3D expected_bytes;
 	}
 =

-	l_asymmetric_cipher_free(rsa_privkey);
-
 	if (result < 0)
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
 =

@@ -1730,44 +1698,16 @@ static void tls_handle_rsa_client_key_xchg(struct l=
_tls *tls,
 						const uint8_t *buf, size_t len)
 {
 	uint8_t pre_master_secret[48], random_secret[46];
-	struct l_asymmetric_cipher *rsa_server_privkey;
-	uint8_t *privkey;
-	size_t key_size;
 	ssize_t bytes_decrypted;
 =

-	if (!tls->priv_key_path) {
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
-				TLS_ALERT_BAD_CERT);
-
-		return;
-	}
-
-	privkey =3D l_pem_load_private_key(tls->priv_key_path,
-						tls->priv_key_passphrase,
-						&key_size);
-	if (!privkey) {
+	if (!tls->priv_key || !tls->priv_key_size) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
 				TLS_ALERT_BAD_CERT);
 =

 		return;
 	}
 =

-	rsa_server_privkey =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_V1_5,
-							privkey, key_size,
-							false);
-	tls_free_key(privkey, key_size);
-
-	if (!rsa_server_privkey) {
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
-
-		return;
-	}
-
-	key_size =3D l_asymmetric_cipher_get_key_size(rsa_server_privkey);
-
-	if (len !=3D key_size + 2) {
-		l_asymmetric_cipher_free(rsa_server_privkey);
-
+	if (len !=3D tls->priv_key_size + 2) {
 		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
 =

 		return;
@@ -1775,19 +1715,16 @@ static void tls_handle_rsa_client_key_xchg(struct l=
_tls *tls,
 =

 	len =3D l_get_be16(buf);
 =

-	if (len !=3D key_size) {
-		l_asymmetric_cipher_free(rsa_server_privkey);
-
+	if (len !=3D tls->priv_key_size) {
 		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
 =

 		return;
 	}
 =

-	bytes_decrypted =3D l_asymmetric_cipher_decrypt(rsa_server_privkey,
-							buf + 2,
-							pre_master_secret,
-							key_size, 48);
-	l_asymmetric_cipher_free(rsa_server_privkey);
+	bytes_decrypted =3D l_key_decrypt(tls->priv_key, L_CIPHER_RSA_PKCS1_V1_5,
+					L_CHECKSUM_NONE, buf + 2,
+					pre_master_secret, tls->priv_key_size,
+					48);
 =

 	/*
 	 * Assume correct premaster secret client version which according
@@ -2279,31 +2216,52 @@ LIB_EXPORT void l_tls_set_cacert(struct l_tls *tls,=
 const char *ca_cert_path)
 		tls->ca_cert_path =3D l_strdup(ca_cert_path);
 }
 =

-LIB_EXPORT void l_tls_set_auth_data(struct l_tls *tls, const char *cert_pa=
th,
-				const char *priv_key_path,
-				const char *priv_key_passphrase)
+LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls, const char *cert_pa=
th,
+					const char *priv_key_path,
+					const char *priv_key_passphrase)
 {
+	uint8_t *priv_key =3D NULL;
+	bool is_public =3D true;
+
 	if (tls->cert_path) {
 		l_free(tls->cert_path);
-		l_free(tls->priv_key_path);
 		tls->cert_path =3D NULL;
-		tls->priv_key_path =3D NULL;
 	}
 =

-	if (cert_path) {
-		tls->cert_path =3D l_strdup(cert_path);
-		tls->priv_key_path =3D l_strdup(priv_key_path);
+	if (tls->priv_key) {
+		l_key_free(tls->priv_key);
+		tls->priv_key =3D NULL;
+		tls->priv_key_size =3D 0;
 	}
 =

-	if (tls->priv_key_passphrase) {
-		memset(tls->priv_key_passphrase, 0,
-				strlen(tls->priv_key_passphrase));
-		l_free(tls->priv_key_passphrase);
-		tls->priv_key_passphrase =3D NULL;
+	if (priv_key_path) {
+		priv_key =3D l_pem_load_private_key(priv_key_path,
+							priv_key_passphrase,
+							&tls->priv_key_size);
+
+		tls->priv_key =3D l_key_new(L_KEY_RSA, priv_key,
+						tls->priv_key_size);
+		if (priv_key) {
+			memset(priv_key, 0, tls->priv_key_size);
+			l_free(priv_key);
+		}
+
+		if (!l_key_get_info(tls->priv_key, L_CIPHER_RSA_PKCS1_V1_5,
+					L_CHECKSUM_NONE, &tls->priv_key_size,
+					&is_public) || is_public) {
+			l_key_free(tls->priv_key);
+			tls->priv_key =3D NULL;
+			tls->priv_key_size =3D 0;
+			return false;
+		}
+
+		tls->priv_key_size /=3D 8;
 	}
 =

-	if (priv_key_passphrase)
-		tls->priv_key_passphrase =3D l_strdup(priv_key_passphrase);
+	if (cert_path)
+		tls->cert_path =3D l_strdup(cert_path);
+
+	return true;
 }
 =

 LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls_alert_desc desc)
diff --git a/ell/tls.h b/ell/tls.h
index a3f3a28..0a7c920 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -97,7 +97,7 @@ void l_tls_set_cacert(struct l_tls *tls, const char *ca_c=
ert_path);
  * one certificate of each type so they can be used depending on which
  * is compatible with the negotiated parameters.
  */
-void l_tls_set_auth_data(struct l_tls *tls, const char *cert_path,
+bool l_tls_set_auth_data(struct l_tls *tls, const char *cert_path,
 				const char *priv_key_path,
 				const char *priv_key_passphrase);
 =

-- =

2.9.2


--===============3614762818836312636==--

