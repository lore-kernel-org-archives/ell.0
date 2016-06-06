Content-Type: multipart/mixed; boundary="===============4922693468863096988=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 04/11] unit: Script and config file for creating test
 certificates
Date: Mon, 06 Jun 2016 13:54:43 -0700
Message-ID: <20160606205450.23615-4-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160606205450.23615-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4922693468863096988==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/gencerts.cnf | 14 ++++++++++++++
 unit/gencerts.sh  | 19 +++++++++++++++++++
 2 files changed, 33 insertions(+)
 create mode 100644 unit/gencerts.cnf
 create mode 100755 unit/gencerts.sh

diff --git a/unit/gencerts.cnf b/unit/gencerts.cnf
new file mode 100644
index 0000000..46eb166
--- /dev/null
+++ b/unit/gencerts.cnf
@@ -0,0 +1,14 @@
+[ req ]
+distinguished_name =3D req_distinguished_name
+
+[ req_distinguished_name ]
+
+[ ca_ext ]
+basicConstraints =3D CA:TRUE,pathlen:0
+subjectKeyIdentifier =3D hash
+authorityKeyIdentifier =3D keyid:always,issuer:always
+
+[ cert_ext ]
+basicConstraints =3D CA:FALSE
+subjectKeyIdentifier =3D hash
+authorityKeyIdentifier =3D keyid:always,issuer:always
diff --git a/unit/gencerts.sh b/unit/gencerts.sh
new file mode 100755
index 0000000..fb305d7
--- /dev/null
+++ b/unit/gencerts.sh
@@ -0,0 +1,19 @@
+#!/usr/bin/sh
+
+echo "*** CA Certificate ***"
+openssl genrsa -out cert-ca-key.pem 2048
+openssl req -x509 -new -nodes -extensions ca_ext -config ./gencerts.cnf -s=
ubj '/O=3DInternational Union of Example Organizations/CN=3DCertificate iss=
uer guy/emailAddress=3Dca(a)mail.example' -key cert-ca-key.pem -sha256 -day=
s 10000 -out cert-ca.pem
+
+echo -e "\n*** Server Certificate ***"
+openssl genrsa -out cert-server-key.pem
+openssl req -new -extensions cert_ext -config ./gencerts.cnf -subj '/O=3DF=
oo Example Organization/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)=
mail.example' -key cert-server-key.pem -out cert-server.csr
+openssl x509 -req -extensions cert_ext -extfile ./gencerts.cnf -in cert-se=
rver.csr -CA cert-ca.pem -CAkey cert-ca-key.pem -CAcreateserial -sha256 -da=
ys 10000 -out cert-server.pem
+openssl verify -CAfile cert-ca.pem cert-server.pem
+
+echo -e "\n*** Client Certificate ***"
+openssl genrsa -out cert-client-key.pem
+openssl req -new -extensions cert_ext -config ./gencerts.cnf -subj '/O=3DB=
ar Example Organization/CN=3DBar Example Organization/emailAddress=3Dbar(a)=
mail.example' -key cert-client-key.pem -out cert-client.csr
+openssl x509 -req -extensions cert_ext -extfile ./gencerts.cnf -in cert-cl=
ient.csr -CA cert-ca.pem -CAkey cert-ca-key.pem -CAcreateserial -sha256 -da=
ys 10000 -out cert-client.pem
+openssl verify -CAfile cert-ca.pem cert-client.pem
+
+rm cert-ca.srl cert-client.csr cert-server.csr
-- =

2.8.3


--===============4922693468863096988==--

