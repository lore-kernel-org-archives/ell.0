Content-Type: multipart/mixed; boundary="===============3924861271279087554=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 10/13] build: Add more test certificates in various formats
Date: Thu, 10 Dec 2020 20:32:21 +0100
Message-ID: <20201210193224.526513-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3924861271279087554==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a binary X.509 test certificate and PKCS#12 files using various
cipher combinations.
---
 Makefile.am | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/Makefile.am b/Makefile.am
index 28082aa..66c08c1 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -213,6 +213,7 @@ cert_files =3D unit/cert-chain.pem \
 			unit/cert-server.pem \
 			unit/cert-server-key-pkcs8.pem \
 			unit/cert-client.pem \
+			unit/cert-client.crt \
 			unit/cert-client-key-pkcs1.pem \
 			unit/cert-client-key-pkcs1-des.pem \
 			unit/cert-client-key-pkcs1-des3.pem \
@@ -226,6 +227,12 @@ cert_files =3D unit/cert-chain.pem \
 			unit/cert-client-key-pkcs8-v2-des-ede3.pem \
 			unit/cert-client-key-pkcs8-v2-aes128.pem \
 			unit/cert-client-key-pkcs8-v2-aes256.pem \
+			unit/cert-entity-pkcs12-nomac.p12 \
+			unit/cert-entity-pkcs12-rc2-sha1.p12 \
+			unit/cert-entity-pkcs12-des-sha256.p12 \
+			unit/cert-entity-pkcs12-rc4-sha384.p12 \
+			unit/cert-entity-pkcs12-pkcs5-sha512.p12 \
+			unit/cert-entity-combined.pem \
 			unit/cert-no-keyid.pem
 =

 cert_checks =3D unit/cert-intca \
@@ -484,6 +491,9 @@ unit/cert-client.pem: unit/cert-client.csr unit/cert-ca=
.pem unit/gencerts.cnf
 unit/cert-client: unit/cert-client.pem unit/cert-ca.pem
 	$(AM_V_GEN)openssl verify -CAfile $(builddir)/unit/cert-ca.pem $<
 =

+unit/cert-client.crt: unit/cert-client.pem
+	$(AM_V_GEN)openssl x509 -in $< -out $@ -outform der
+
 unit/cert-intca-key.pem:
 	$(AM_V_GEN)openssl genrsa -out $@ $($(AM_V_P)_redirect_openssl)
 =

@@ -550,6 +560,24 @@ unit/cert-no-keyid.pem: unit/cert-no-keyid.csr unit/ce=
rt-ca2.pem unit/gencerts.c
 unit/cert-no-keyid: unit/cert-no-keyid.pem unit/cert-ca2.pem
 	$(AM_V_GEN)openssl verify -CAfile $(builddir)/unit/cert-ca2.pem $<
 =

+unit/cert-entity-pkcs12-nomac.p12: unit/cert-entity-int-key.pem unit/cert-=
entity-int.pem
+	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.=
pem -out $@ -export -passout pass:abc -nomac # defaut ciphers
+
+unit/cert-entity-pkcs12-rc2-sha1.p12: unit/cert-entity-int-key.pem unit/ce=
rt-entity-int.pem unit/cert-chain.pem
+	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.=
pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pass=
:abc -certpbe PBE-SHA1-RC2-40 -keypbe PBE-SHA1-RC2-128 -macalg sha1
+
+unit/cert-entity-pkcs12-des-sha256.p12: unit/cert-entity-int-key.pem unit/=
cert-entity-int.pem unit/cert-chain.pem
+	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.=
pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pass=
:abc -certpbe PBE-SHA1-3DES -keypbe PBE-SHA1-2DES -macalg sha256
+
+unit/cert-entity-pkcs12-rc4-sha384.p12: unit/cert-entity-int-key.pem unit/=
cert-entity-int.pem unit/cert-chain.pem
+	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.=
pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pass=
:abc -certpbe PBE-SHA1-RC4-128 -keypbe PBE-SHA1-RC2-40 -macalg sha384
+
+unit/cert-entity-pkcs12-pkcs5-sha512.p12: unit/cert-entity-int-key.pem uni=
t/cert-entity-int.pem unit/cert-chain.pem
+	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.=
pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pass=
:abc -certpbe des-cbc -keypbe des-cbc -macalg sha512
+
+unit/cert-entity-combined.pem: unit/cert-entity-pkcs12-rc2-sha1.p12
+	$(AM_V_GEN)openssl pkcs12 -in $< -out $@ -passin pass:abc -passout pass:a=
bc
+
 unit/key-plaintext.h: unit/plaintext.txt
 	$(AM_V_GEN)xxd -i < $< > $@
 =

-- =

2.27.0

--===============3924861271279087554==--

