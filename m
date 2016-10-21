Content-Type: multipart/mixed; boundary="===============4163776165502797045=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/4] unit: Update certificate generation script
Date: Fri, 21 Oct 2016 13:52:24 -0700
Message-ID: <20161021205226.419-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20161021205226.419-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4163776165502797045==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add an intermediate CA and a certificate signed by the intermediate CA.
---
 unit/gencerts.cnf |  5 +++++
 unit/gencerts.sh  | 15 ++++++++++++++-
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/unit/gencerts.cnf b/unit/gencerts.cnf
index 46eb166..5328734 100644
--- a/unit/gencerts.cnf
+++ b/unit/gencerts.cnf
@@ -8,6 +8,11 @@ basicConstraints =3D CA:TRUE,pathlen:0
 subjectKeyIdentifier =3D hash
 authorityKeyIdentifier =3D keyid:always,issuer:always
 =

+[ int_ext ]
+basicConstraints =3D CA:TRUE
+subjectKeyIdentifier =3D hash
+authorityKeyIdentifier =3D keyid:always,issuer:always
+
 [ cert_ext ]
 basicConstraints =3D CA:FALSE
 subjectKeyIdentifier =3D hash
diff --git a/unit/gencerts.sh b/unit/gencerts.sh
index be186f1..790c715 100755
--- a/unit/gencerts.sh
+++ b/unit/gencerts.sh
@@ -18,4 +18,17 @@ openssl req -new -extensions cert_ext -config ./gencerts=
.cnf -subj '/O=3DBar Examp
 openssl x509 -req -extensions cert_ext -extfile ./gencerts.cnf -in cert-cl=
ient.csr -CA cert-ca.pem -CAkey cert-ca-key.pem -CAcreateserial -sha256 -da=
ys 10000 -out cert-client.pem
 openssl verify -CAfile cert-ca.pem cert-client.pem
 =

-rm cert-ca.srl cert-client.csr cert-server.csr
+echo -e "\n*** Intermediate Certificate ***"
+openssl genrsa -out cert-intca-key.pem
+openssl req -new -extensions int_ext -config ./gencerts.cnf -subj '/O=3DIn=
ternational Union of Example Organizations/CN=3DCertificate issuer guy/emai=
lAddress=3Dca(a)mail.example' -key cert-intca-key.pem -out cert-intca.csr
+openssl x509 -req -extensions int_ext -extfile ./gencerts.cnf -in cert-int=
ca.csr -CA cert-ca.pem -CAkey cert-ca-key.pem -CAcreateserial -sha256 -days=
 10000 -out cert-intca.pem
+openssl verify -CAfile cert-ca.pem cert-intca.pem
+cat cert-intca.pem cert-ca.pem > cert-chain.pem
+
+echo -e "\n*** Intermediate-Signed Certificate ***"
+openssl genrsa -out cert-entity-int-key.pem
+openssl req -new -extensions cert_ext -config ./gencerts.cnf -subj '/O=3DB=
az Example Organization/CN=3DBaz Example Organization/emailAddress=3Dbaz(a)=
mail.example' -key cert-entity-int-key.pem -out cert-entity-int.csr
+openssl x509 -req -extensions cert_ext -extfile ./gencerts.cnf -in cert-en=
tity-int.csr -CA cert-intca.pem -CAkey cert-intca-key.pem -CAcreateserial -=
sha256 -days 10000 -out cert-entity-int.pem
+openssl verify -CAfile cert-chain.pem cert-entity-int.pem
+
+rm cert-ca.srl cert-client.csr cert-server.csr cert-intca.srl cert-intca.c=
sr cert-entity-int.csr cert-entity-int-key.pem cert-intca-key.pem cert-chai=
n.pem
-- =

2.10.1


--===============4163776165502797045==--

