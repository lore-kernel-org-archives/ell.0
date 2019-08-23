Content-Type: multipart/mixed; boundary="===============6127150313704373060=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 7/8] build: Add DNSNames to the test server cert
Date: Fri, 23 Aug 2019 02:41:37 +0200
Message-ID: <20190823004138.5480-7-andrew.zaborowski@intel.com>
In-Reply-To: <20190823004138.5480-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6127150313704373060==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 Makefile.am       | 2 +-
 unit/gencerts.cnf | 6 ++++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/Makefile.am b/Makefile.am
index 420c839..bcee4e7 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -391,7 +391,7 @@ unit/cert-server.csr: unit/cert-server-key.pem unit/gen=
certs.cnf
 			-key $< -out $@
 =

 unit/cert-server.pem: unit/cert-server.csr unit/cert-ca.pem unit/gencerts.=
cnf
-	$(AM_V_GEN)openssl x509 -req -extensions cert_ext \
+	$(AM_V_GEN)openssl x509 -req -extensions server_ext \
 			-extfile $(srcdir)/unit/gencerts.cnf \
 			-in $< -CA $(builddir)/unit/cert-ca.pem \
 			-CAkey $(builddir)/unit/cert-ca-key.pem \
diff --git a/unit/gencerts.cnf b/unit/gencerts.cnf
index 5328734..dc469e8 100644
--- a/unit/gencerts.cnf
+++ b/unit/gencerts.cnf
@@ -17,3 +17,9 @@ authorityKeyIdentifier =3D keyid:always,issuer:always
 basicConstraints =3D CA:FALSE
 subjectKeyIdentifier =3D hash
 authorityKeyIdentifier =3D keyid:always,issuer:always
+
+[ server_ext ]
+basicConstraints =3D CA:FALSE
+subjectKeyIdentifier =3D hash
+authorityKeyIdentifier =3D keyid:always,issuer:always
+subjectAltName =3D DNS:foo.int.example,DNS:foo.int.com
-- =

2.20.1


--===============6127150313704373060==--

