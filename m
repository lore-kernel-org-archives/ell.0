Content-Type: multipart/mixed; boundary="===============7328709765191511865=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau at linux.intel.com>
To: ell at lists.01.org
Subject: [PATCH] build: Check for openssl legacy provider requirement
Date: Thu, 19 May 2022 15:48:28 -0700
Message-ID: <20220519224828.91435-1-mathew.j.martineau@linux.intel.com>

--===============7328709765191511865==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

OpenSSL 3 introduced some command line incompatibilities and removed
some old algorithms from the defaults. This broke some of the unit test
cert generation commands on distros like Ubuntu 22.04 and Fedora 36.

Detect support of "providers" by the system openssl command and insert
the necessary command line parameters to enable legacy algorithms for
openssl v3, but leave the commands unchanged for older openssl versions.
---

Tested on Ubuntu 22.04, Fedora 36, and Fedora 35.

---
 Makefile.am  | 26 ++++++++++++++++++--------
 configure.ac |  3 +++
 2 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index d8ba99caa47e..df99e0dfc6bc 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -355,6 +355,12 @@ if GLIB
 examples +=3D examples/glib-eventloop
 endif
 =

+if OPENSSL_PROVIDER
+openssl_legacy =3D -provider legacy -provider default
+else
+openssl_legacy =3D
+endif
+
 if MAINTAINER_MODE
 noinst_PROGRAMS +=3D $(examples)
 endif
@@ -444,7 +450,8 @@ unit/cert-client-key-pkcs1.pem:
 	$(AM_V_GEN)openssl genrsa -out $@ $($(AM_V_P)_redirect_openssl)
 =

 unit/cert-client-key-pkcs1-des.pem: unit/cert-client-key-pkcs1.pem
-	$(AM_V_GEN)openssl rsa -in $< -out $@ -des -passout pass:abc
+	$(AM_V_GEN)openssl rsa -in $< -out $@ -des -passout pass:abc \
+			$(openssl_legacy)
 =

 unit/cert-client-key-pkcs1-des3.pem: unit/cert-client-key-pkcs1.pem
 	$(AM_V_GEN)openssl rsa -in $< -out $@ -des3 -passout pass:abc
@@ -463,15 +470,18 @@ unit/cert-client-key-pkcs8.pem: unit/cert-client-key-=
pkcs1.pem
 =

 unit/cert-client-key-pkcs8-md5-des.pem: unit/cert-client-key-pkcs8.pem
 	$(AM_V_GEN)openssl pkcs8 -in $< -out $@ \
-			-topk8 -v1 PBE-MD5-DES -passout pass:abc
+			-topk8 -v1 PBE-MD5-DES -passout pass:abc \
+			$(openssl_legacy)
 =

 unit/cert-client-key-pkcs8-sha1-des.pem: unit/cert-client-key-pkcs8.pem
 	$(AM_V_GEN)openssl pkcs8 -in $< -out $@ \
-			-topk8 -v1 PBE-SHA1-DES -passout pass:abc
+			-topk8 -v1 PBE-SHA1-DES -passout pass:abc \
+			$(openssl_legacy)
 =

 unit/cert-client-key-pkcs8-v2-des.pem: unit/cert-client-key-pkcs8.pem
 	$(AM_V_GEN)openssl pkcs8 -in $< -out $@ \
-			-topk8 -v2 des-cbc -v2prf hmacWithSHA1 -passout pass:abc
+			-topk8 -v2 des-cbc -v2prf hmacWithSHA1 -passout pass:abc \
+			$(openssl_legacy)
 =

 unit/cert-client-key-pkcs8-v2-des-ede3.pem: unit/cert-client-key-pkcs8.pem
 	$(AM_V_GEN)openssl pkcs8 -in $< -out $@ \
@@ -575,19 +585,19 @@ unit/cert-entity-pkcs12-nomac.p12: unit/cert-entity-i=
nt-key.pem unit/cert-entity
 	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.=
pem -out $@ -export -passout pass:abc -nomac # defaut ciphers
 =

 unit/cert-entity-pkcs12-rc2-sha1.p12: unit/cert-entity-int-key.pem unit/ce=
rt-entity-int.pem unit/cert-chain.pem
-	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.=
pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pass=
:abc -certpbe PBE-SHA1-RC2-40 -keypbe PBE-SHA1-RC2-128 -macalg sha1
+	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.=
pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pass=
:abc -certpbe PBE-SHA1-RC2-40 -keypbe PBE-SHA1-RC2-128 -macalg sha1 $(opens=
sl_legacy)
 =

 unit/cert-entity-pkcs12-des-sha256.p12: unit/cert-entity-int-key.pem unit/=
cert-entity-int.pem unit/cert-chain.pem
 	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.=
pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pass=
:abc -certpbe PBE-SHA1-3DES -keypbe PBE-SHA1-2DES -macalg sha256
 =

 unit/cert-entity-pkcs12-rc4-sha384.p12: unit/cert-entity-int-key.pem unit/=
cert-entity-int.pem unit/cert-chain.pem
-	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.=
pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pass=
:abc -certpbe PBE-SHA1-RC4-128 -keypbe PBE-SHA1-RC2-40 -macalg sha384
+	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.=
pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pass=
:abc -certpbe PBE-SHA1-RC4-128 -keypbe PBE-SHA1-RC2-40 -macalg sha384 $(ope=
nssl_legacy)
 =

 unit/cert-entity-pkcs12-pkcs5-sha512.p12: unit/cert-entity-int-key.pem uni=
t/cert-entity-int.pem unit/cert-chain.pem
-	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.=
pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pass=
:abc -certpbe des-cbc -keypbe des-cbc -macalg sha512
+	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.=
pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pass=
:abc -certpbe des-cbc -keypbe des-cbc -macalg sha512 $(openssl_legacy)
 =

 unit/cert-entity-combined.pem: unit/cert-entity-pkcs12-rc2-sha1.p12
-	$(AM_V_GEN)openssl pkcs12 -in $< -out $@ -passin pass:abc -passout pass:a=
bc
+	$(AM_V_GEN)openssl pkcs12 -in $< -out $@ -passin pass:abc -passout pass:a=
bc $(openssl_legacy)
 =

 unit/key-plaintext.h: unit/plaintext.txt
 	$(AM_V_GEN)xxd -i < $< > $@
diff --git a/configure.ac b/configure.ac
index 62338079bc50..87894dba8a6b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -131,6 +131,9 @@ fi
 =

 AM_CONDITIONAL(DBUS_TESTS, test "${little_endian}" =3D "yes")
 AM_CONDITIONAL(CERT_TESTS, test "${have_openssl}" =3D "yes")
+AM_CONDITIONAL(OPENSSL_PROVIDER, test "${have_openssl}" =3D "yes" &&
+		openssl list -providers > /dev/null 2>&1 )
+AC_SUBST(OPENSSL_PROVIDER)
 =

 AC_CONFIG_FILES(Makefile ell/ell.pc)
 =

-- =

2.36.1

--===============7328709765191511865==--

