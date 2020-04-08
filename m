Content-Type: multipart/mixed; boundary="===============6589392764511986158=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/5] build: Generate test certs with no AKID / SKID extensions
Date: Thu, 09 Apr 2020 01:37:21 +0200
Message-ID: <20200408233724.25721-2-andrew.zaborowski@intel.com>
In-Reply-To: <20200408233724.25721-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6589392764511986158==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 Makefile.am       | 29 +++++++++++++++++++++++++++--
 unit/gencerts.cnf |  7 +++++++
 2 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index abe0dab..e0841fc 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -209,12 +209,14 @@ cert_files =3D unit/cert-chain.pem \
 			unit/cert-client-key-v2-des.pem \
 			unit/cert-client-key-v2-des-ede3.pem \
 			unit/cert-client-key-v2-aes128.pem \
-			unit/cert-client-key-v2-aes256.pem
+			unit/cert-client-key-v2-aes256.pem \
+			unit/cert-no-keyid.pem
 =

 cert_checks =3D unit/cert-intca \
 			unit/cert-entity-int \
 			unit/cert-server \
-			unit/cert-client
+			unit/cert-client \
+			unit/cert-no-keyid
 =

 if MAINTAINER_MODE
 noinst_PROGRAMS +=3D $(unit_tests) $(dbus_tests) $(cert_tests)
@@ -499,6 +501,29 @@ unit/cert-entity-int.pem: unit/cert-entity-int.csr uni=
t/cert-intca.pem unit/genc
 unit/cert-entity-int: unit/cert-entity-int.pem unit/cert-chain.pem
 	$(AM_V_GEN)openssl verify -CAfile $(builddir)/unit/cert-chain.pem $<
 =

+unit/cert-ca2.pem: unit/cert-ca-key.pem unit/gencerts.cnf
+	$(AM_V_GEN)openssl req -x509 -new -nodes -extensions ca_no_akid_ext \
+			-config $(srcdir)/unit/gencerts.cnf \
+			-subj '/O=3DInternational Union of Example Organizations/CN=3DCertifica=
te issuer guy/emailAddress=3Dca-no-akid(a)mail.example' \
+			-key $< -sha256 -days 10000 -out $@
+
+unit/cert-no-keyid.csr: unit/cert-client-key.pem unit/gencerts.cnf
+	$(AM_V_GEN)openssl req -new \
+			-config $(srcdir)/unit/gencerts.cnf \
+			-subj '/O=3DBaz Example Organization/CN=3DBaz Example Organization/emai=
lAddress=3Dbaz@mail.example' \
+			-key $< -out $@
+
+unit/cert-no-keyid.pem: unit/cert-no-keyid.csr unit/cert-ca2.pem unit/genc=
erts.cnf
+	$(AM_V_GEN)openssl x509 -req -extensions no_keyid_ext \
+			-extfile $(srcdir)/unit/gencerts.cnf \
+			-in $< -CA $(builddir)/unit/cert-ca2.pem \
+			-CAkey $(builddir)/unit/cert-ca-key.pem \
+			-CAserial $(builddir)/unit/cert-ca2.srl \
+			-CAcreateserial -sha256 -days 10000 -out $@ $($(AM_V_P)_redirect_openss=
l)
+
+unit/cert-no-keyid: unit/cert-no-keyid.pem unit/cert-ca2.pem
+	$(AM_V_GEN)openssl verify -CAfile $(builddir)/unit/cert-ca2.pem $<
+
 unit/key-plaintext.h: unit/plaintext.txt
 	$(AM_V_GEN)xxd -i < $< > $@
 =

diff --git a/unit/gencerts.cnf b/unit/gencerts.cnf
index dc469e8..dc4dad2 100644
--- a/unit/gencerts.cnf
+++ b/unit/gencerts.cnf
@@ -23,3 +23,10 @@ basicConstraints =3D CA:FALSE
 subjectKeyIdentifier =3D hash
 authorityKeyIdentifier =3D keyid:always,issuer:always
 subjectAltName =3D DNS:foo.int.example,DNS:foo.int.com
+
+[ ca_no_akid_ext ]
+basicConstraints =3D CA:TRUE
+
+[ no_keyid_ext ]
+basicConstraints =3D CA:FALSE
+authorityKeyIdentifier =3D issuer:always
-- =

2.20.1

--===============6589392764511986158==--

