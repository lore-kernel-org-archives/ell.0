Content-Type: multipart/mixed; boundary="===============2635949453022543549=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 7/7] unit: Update tests to new certificate API
Date: Mon, 19 Nov 2018 19:23:48 +0100
Message-ID: <20181119182348.4562-7-andrew.zaborowski@intel.com>
In-Reply-To: <20181119182348.4562-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2635949453022543549==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 76 ++++++++++++++++++++++---------------------------
 unit/test-tls.c | 27 +++++++++---------
 2 files changed, 48 insertions(+), 55 deletions(-)

diff --git a/unit/test-key.c b/unit/test-key.c
index afe4103..ba27e19 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -28,6 +28,8 @@
 =

 #include <ell/ell.h>
 =

+#include "ell/tls-private.h"
+
 #define KEY1_STR "This key has exactly _32_ bytes!"
 #define KEY1_LEN (strlen(KEY1_STR))
 #define KEY2_STR "This key is longer than 32 bytes, just to be different."
@@ -394,23 +396,20 @@ static void test_trusted_keyring(const void *data)
 {
 	struct l_keyring *ring;
 	struct l_keyring *trust;
-	uint8_t *cacert;
-	size_t cacertlen;
-	uint8_t *cert;
-	size_t certlen;
+	struct l_cert *cacert;
+	struct l_cert *cert;
 	struct l_key *cakey;
 	struct l_key *key;
 	bool success;
 =

-	cacert =3D l_pem_load_certificate(CERTDIR "cert-ca.pem", &cacertlen);
+	cacert =3D tls_cert_load_file(CERTDIR "cert-ca.pem");
 	assert(cacert);
-	cert =3D l_pem_load_certificate(CERTDIR "cert-server.pem",
-					&certlen);
+	cert =3D tls_cert_load_file(CERTDIR "cert-server.pem");
 	assert(cert);
 =

-	cakey =3D l_key_new(L_KEY_RSA, cacert, cacertlen);
+	cakey =3D l_cert_get_pubkey(cacert);
 	assert(cakey);
-	key =3D l_key_new(L_KEY_RSA, cert, certlen);
+	key =3D l_cert_get_pubkey(cert);
 	assert(key);
 =

 	trust =3D l_keyring_new();
@@ -431,39 +430,34 @@ static void test_trusted_keyring(const void *data)
 	l_keyring_free(ring);
 	l_key_free(cakey);
 	l_key_free(key);
-	l_free(cacert);
-	l_free(cert);
+	l_cert_free(cacert);
+	l_cert_free(cert);
 }
 =

 static void test_trust_chain(const void *data)
 {
 	struct l_keyring *ring;
 	struct l_keyring *trust;
-	uint8_t *cacert;
-	size_t cacertlen;
-	uint8_t *intcert;
-	size_t intcertlen;
-	uint8_t *cert;
-	size_t certlen;
+	struct l_cert *cacert;
+	struct l_cert *intcert;
+	struct l_cert *cert;
 	struct l_key *cakey;
 	struct l_key *intkey;
 	struct l_key *key;
 	bool success;
 =

-	cacert =3D l_pem_load_certificate(CERTDIR "cert-ca.pem", &cacertlen);
+	cacert =3D tls_cert_load_file(CERTDIR "cert-ca.pem");
 	assert(cacert);
-	intcert =3D l_pem_load_certificate(CERTDIR "cert-intca.pem",
-						&intcertlen);
+	intcert =3D tls_cert_load_file(CERTDIR "cert-intca.pem");
 	assert(intcert);
-	cert =3D l_pem_load_certificate(CERTDIR "cert-entity-int.pem",
-					&certlen);
+	cert =3D tls_cert_load_file(CERTDIR "cert-entity-int.pem");
 	assert(cert);
 =

-	cakey =3D l_key_new(L_KEY_RSA, cacert, cacertlen);
+	cakey =3D l_cert_get_pubkey(cacert);
 	assert(cakey);
-	intkey =3D l_key_new(L_KEY_RSA, intcert, intcertlen);
+	intkey =3D l_cert_get_pubkey(intcert);
 	assert(intkey);
-	key =3D l_key_new(L_KEY_RSA, cert, certlen);
+	key =3D l_cert_get_pubkey(cert);
 	assert(key);
 =

 	trust =3D l_keyring_new();
@@ -492,17 +486,16 @@ static void test_trust_chain(const void *data)
 	l_key_free(cakey);
 	l_key_free(intkey);
 	l_key_free(key);
-	l_free(cacert);
-	l_free(intcert);
-	l_free(cert);
+	l_cert_free(cacert);
+	l_cert_free(intcert);
+	l_cert_free(cert);
 }
 =

 static void test_key_crypto(const void *data)
 {
-	uint8_t *cert;
-	size_t certlen;
-	uint8_t *pubcert;
-	size_t pubcertlen;
+	uint8_t *privkey;
+	size_t privkeylen;
+	struct l_cert *cert;
 	struct l_key *key;
 	struct l_key *pubkey;
 	bool is_public;
@@ -514,18 +507,17 @@ static void test_key_crypto(const void *data)
 	int hash =3D L_CHECKSUM_NONE;
 	int rsa =3D L_KEY_RSA_PKCS1_V1_5;
 =

-	cert =3D l_pem_load_private_key(CERTDIR "cert-client-key-pkcs8.pem",
-					NULL, NULL, &certlen);
+	privkey =3D l_pem_load_private_key(CERTDIR "cert-client-key-pkcs8.pem",
+						NULL, NULL, &privkeylen);
+	assert(privkey);
+	cert =3D tls_cert_load_file(CERTDIR "cert-client.pem");
 	assert(cert);
-	pubcert =3D l_pem_load_certificate(CERTDIR "cert-client.pem",
-						&pubcertlen);
-	assert(pubcert);
 =

-	key =3D l_key_new(L_KEY_RSA, cert, certlen);
-	assert(key);
-	pubkey =3D l_key_new(L_KEY_RSA, pubcert, pubcertlen);
+	pubkey =3D l_cert_get_pubkey(cert);
 	assert(pubkey);
 =

+	key =3D l_key_new(L_KEY_RSA, privkey, privkeylen);
+	assert(key);
 	success =3D l_key_get_info(key, rsa, hash, &keybits, &is_public);
 	assert(success);
 	assert(keybits =3D=3D 2048);
@@ -606,8 +598,8 @@ static void test_key_crypto(const void *data)
 =

 	l_key_free(key);
 	l_key_free(pubkey);
-	l_free(cert);
-	l_free(pubcert);
+	l_free(privkey);
+	l_cert_free(cert);
 }
 =

 int main(int argc, char *argv[])
diff --git a/unit/test-tls.c b/unit/test-tls.c
index 4ac7162..a3a8905 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -29,9 +29,8 @@
 =

 #include <ell/ell.h>
 =

-#include "ell/cipher.h"
-#include "ell/checksum.h"
 #include "ell/tls-private.h"
+#include "ell/cert-private.h"
 =

 static void test_tls10_prf(const void *data)
 {
@@ -213,12 +212,14 @@ static void test_tls12_prf(const void *data)
 =

 static void test_certificates(const void *data)
 {
-	struct tls_cert *cert;
-	struct tls_cert *cacert;
-	struct tls_cert *wrongca;
+	struct l_cert *cert;
+	struct l_cert *cacert;
+	struct l_cert *wrongca;
+	struct l_certchain *chain;
 =

 	cert =3D tls_cert_load_file(CERTDIR "cert-server.pem");
 	assert(cert);
+	chain =3D certchain_new_from_leaf(cert);
 =

 	cacert =3D tls_cert_load_file(CERTDIR "cert-ca.pem");
 	assert(cacert);
@@ -226,15 +227,15 @@ static void test_certificates(const void *data)
 	wrongca =3D tls_cert_load_file(CERTDIR "cert-intca.pem");
 	assert(wrongca);
 =

-	assert(!tls_cert_verify_certchain(cert, wrongca));
+	assert(!l_certchain_verify(chain, wrongca));
 =

-	assert(tls_cert_verify_certchain(cert, cacert));
+	assert(l_certchain_verify(chain, cacert));
 =

-	assert(tls_cert_verify_certchain(cert, NULL));
+	assert(l_certchain_verify(chain, NULL));
 =

-	l_free(cert);
-	l_free(cacert);
-	l_free(wrongca);
+	l_certchain_free(chain);
+	l_cert_free(cacert);
+	l_cert_free(wrongca);
 }
 =

 struct tls_conn_test {
@@ -418,8 +419,8 @@ static void test_tls_test(const void *data)
 					test->client_key_path,
 					test->client_key_passphrase);
 	assert(auth_ok);
-	l_tls_set_cacert(s[0].tls, test->server_ca_cert_path);
-	l_tls_set_cacert(s[1].tls, test->client_ca_cert_path);
+	assert(l_tls_set_cacert(s[0].tls, test->server_ca_cert_path));
+	assert(l_tls_set_cacert(s[1].tls, test->client_ca_cert_path));
 =

 	while (1) {
 		if (s[0].raw_buf_len) {
-- =

2.19.1


--===============2635949453022543549==--

