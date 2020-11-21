Content-Type: multipart/mixed; boundary="===============1215053747803867380=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/5] treewide: Rename test private keys to include format
Date: Sat, 21 Nov 2020 03:48:33 +0100
Message-ID: <20201121024834.76213-4-andrew.zaborowski@intel.com>
In-Reply-To: <20201121024834.76213-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1215053747803867380==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Include pkcs1 or pkcs8 in the names of the test client private keys.
---
 Makefile.am     | 39 ++++++++++++++++++++-------------------
 unit/test-pem.c | 17 +++++++++--------
 2 files changed, 29 insertions(+), 27 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index e358546..546a6aa 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -211,15 +211,16 @@ cert_tests =3D unit/test-pem \
 cert_files =3D unit/cert-chain.pem \
 			unit/cert-entity-int.pem \
 			unit/cert-server.pem \
-			unit/cert-client.pem \
 			unit/cert-server-key-pkcs8.pem \
+			unit/cert-client.pem \
+			unit/cert-client-key-pkcs1.pem \
 			unit/cert-client-key-pkcs8.pem \
-			unit/cert-client-key-md5-des.pem \
-			unit/cert-client-key-sha1-des.pem \
-			unit/cert-client-key-v2-des.pem \
-			unit/cert-client-key-v2-des-ede3.pem \
-			unit/cert-client-key-v2-aes128.pem \
-			unit/cert-client-key-v2-aes256.pem \
+			unit/cert-client-key-pkcs8-md5-des.pem \
+			unit/cert-client-key-pkcs8-sha1-des.pem \
+			unit/cert-client-key-pkcs8-v2-des.pem \
+			unit/cert-client-key-pkcs8-v2-des-ede3.pem \
+			unit/cert-client-key-pkcs8-v2-aes128.pem \
+			unit/cert-client-key-pkcs8-v2-aes256.pem \
 			unit/cert-no-keyid.pem
 =

 cert_checks =3D unit/cert-intca \
@@ -416,37 +417,37 @@ unit/cert-server.pem: unit/cert-server.csr unit/cert-=
ca.pem unit/gencerts.cnf
 unit/cert-server: unit/cert-server.pem unit/cert-ca.pem
 	$(AM_V_GEN)openssl verify -CAfile $(builddir)/unit/cert-ca.pem $<
 =

-unit/cert-client-key.pem:
+unit/cert-client-key-pkcs1.pem:
 	$(AM_V_GEN)openssl genrsa -out $@ $($(AM_V_P)_redirect_openssl)
 =

-unit/cert-client-key-pkcs8.pem: unit/cert-client-key.pem
+unit/cert-client-key-pkcs8.pem: unit/cert-client-key-pkcs1.pem
 	$(AM_V_GEN)openssl pkcs8 -topk8 -nocrypt -in $< -out $@
 =

-unit/cert-client-key-md5-des.pem: unit/cert-client-key-pkcs8.pem
+unit/cert-client-key-pkcs8-md5-des.pem: unit/cert-client-key-pkcs8.pem
 	$(AM_V_GEN)openssl pkcs8 -in $< -out $@ \
 			-topk8 -v1 PBE-MD5-DES -passout pass:abc
 =

-unit/cert-client-key-sha1-des.pem: unit/cert-client-key-pkcs8.pem
+unit/cert-client-key-pkcs8-sha1-des.pem: unit/cert-client-key-pkcs8.pem
 	$(AM_V_GEN)openssl pkcs8 -in $< -out $@ \
 			-topk8 -v1 PBE-SHA1-DES -passout pass:abc
 =

-unit/cert-client-key-v2-des.pem: unit/cert-client-key-pkcs8.pem
+unit/cert-client-key-pkcs8-v2-des.pem: unit/cert-client-key-pkcs8.pem
 	$(AM_V_GEN)openssl pkcs8 -in $< -out $@ \
 			-topk8 -v2 des-cbc -v2prf hmacWithSHA1 -passout pass:abc
 =

-unit/cert-client-key-v2-des-ede3.pem: unit/cert-client-key-pkcs8.pem
+unit/cert-client-key-pkcs8-v2-des-ede3.pem: unit/cert-client-key-pkcs8.pem
 	$(AM_V_GEN)openssl pkcs8 -in $< -out $@ \
 			-topk8 -v2 des-ede3-cbc -v2prf hmacWithSHA224 -passout pass:abc
 =

-unit/cert-client-key-v2-aes128.pem: unit/cert-client-key-pkcs8.pem
+unit/cert-client-key-pkcs8-v2-aes128.pem: unit/cert-client-key-pkcs8.pem
 	$(AM_V_GEN)openssl pkcs8 -in $< -out $@ \
 			-topk8 -v2 aes128 -v2prf hmacWithSHA256 -passout pass:abc
 =

-unit/cert-client-key-v2-aes256.pem: unit/cert-client-key-pkcs8.pem
+unit/cert-client-key-pkcs8-v2-aes256.pem: unit/cert-client-key-pkcs8.pem
 	$(AM_V_GEN)openssl pkcs8 -in $< -out $@ \
 			-topk8 -v2 aes256 -v2prf hmacWithSHA512 -passout pass:abc
 =

-unit/cert-client.csr: unit/cert-client-key.pem unit/gencerts.cnf
+unit/cert-client.csr: unit/cert-client-key-pkcs1.pem unit/gencerts.cnf
 	$(AM_V_GEN)openssl req -new -extensions cert_ext \
 			-config $(srcdir)/unit/gencerts.cnf \
 			-subj '/O=3DBar Example Organization/CN=3DBar Example Organization/emai=
lAddress=3Dbar(a)mail.example' \
@@ -512,7 +513,7 @@ unit/cert-ca2.pem: unit/cert-ca-key.pem unit/gencerts.c=
nf
 			-subj '/O=3DInternational Union of Example Organizations/CN=3DCertifica=
te issuer guy/emailAddress=3Dca-no-akid(a)mail.example' \
 			-key $< -sha256 -days 10000 -out $@
 =

-unit/cert-no-keyid.csr: unit/cert-client-key.pem unit/gencerts.cnf
+unit/cert-no-keyid.csr: unit/cert-client-key-pkcs1.pem unit/gencerts.cnf
 	$(AM_V_GEN)openssl req -new \
 			-config $(srcdir)/unit/gencerts.cnf \
 			-subj '/O=3DBaz Example Organization/CN=3DBaz Example Organization/emai=
lAddress=3Dbaz@mail.example' \
@@ -539,9 +540,9 @@ unit/key-ciphertext.dat: unit/plaintext.txt unit/cert-c=
lient.pem
 unit/key-ciphertext.h: unit/key-ciphertext.dat
 	$(AM_V_GEN)xxd -i < $< > $@
 =

-unit/key-signature.dat: unit/plaintext.txt unit/cert-client-key.pem
+unit/key-signature.dat: unit/plaintext.txt unit/cert-client-key-pkcs1.pem
 	$(AM_V_GEN)openssl rsautl -sign -pkcs -in $< \
-			-inkey $(builddir)/unit/cert-client-key.pem -out $@
+			-inkey $(builddir)/unit/cert-client-key-pkcs1.pem -out $@
 =

 unit/key-signature.h: unit/key-signature.dat
 	$(AM_V_GEN)xxd -i < $< > $@
diff --git a/unit/test-pem.c b/unit/test-pem.c
index a1e8110..e81ddde 100644
--- a/unit/test-pem.c
+++ b/unit/test-pem.c
@@ -326,18 +326,19 @@ int main(int argc, char *argv[])
 =

 	l_test_add("pem/v1 MD5AndDES encrypted Private Key",
 			test_encrypted_pkey,
-			CERTDIR "cert-client-key-md5-des.pem");
+			CERTDIR "cert-client-key-pkcs8-md5-des.pem");
 	l_test_add("pem/v1 SHA1AndDES encrypted Private Key",
 			test_encrypted_pkey,
-			CERTDIR "cert-client-key-sha1-des.pem");
+			CERTDIR "cert-client-key-pkcs8-sha1-des.pem");
 	l_test_add("pem/v2 DES encrypted Private Key", test_encrypted_pkey,
-			CERTDIR "cert-client-key-v2-des.pem");
+			CERTDIR "cert-client-key-pkcs8-v2-des.pem");
 =

 	if (l_cipher_is_supported(L_CIPHER_DES3_EDE_CBC) &&
-			l_checksum_is_supported(L_CHECKSUM_SHA224, false))
+			l_checksum_is_supported(L_CHECKSUM_SHA224, false)) {
 		l_test_add("pem/v2 DES EDE3 encrypted Private Key",
-				test_encrypted_pkey,
-				CERTDIR "cert-client-key-v2-des-ede3.pem");
+				test_encrypted_pkey, CERTDIR
+				"cert-client-key-pkcs8-v2-des-ede3.pem");
+	}
 =

 	if (!l_cipher_is_supported(L_CIPHER_AES))
 		goto done;
@@ -345,12 +346,12 @@ int main(int argc, char *argv[])
 	if (l_checksum_is_supported(L_CHECKSUM_SHA256, false))
 		l_test_add("pem/v2 AES128 encrypted Private Key",
 				test_encrypted_pkey,
-				CERTDIR "cert-client-key-v2-aes128.pem");
+				CERTDIR "cert-client-key-pkcs8-v2-aes128.pem");
 =

 	if (l_checksum_is_supported(L_CHECKSUM_SHA512, false))
 		l_test_add("pem/v2 AES256 encrypted Private Key",
 				test_encrypted_pkey,
-				CERTDIR "cert-client-key-v2-aes256.pem");
+				CERTDIR "cert-client-key-pkcs8-v2-aes256.pem");
 =

 done:
 	return l_test_run();
-- =

2.25.1

--===============1215053747803867380==--

