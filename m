Content-Type: multipart/mixed; boundary="===============6798046808919063234=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] unit: Generate encrypted keys in gencerts.sh
Date: Wed, 16 Aug 2017 19:08:22 +0200
Message-ID: <20170816170822.4680-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6798046808919063234==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/gencerts.sh | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/unit/gencerts.sh b/unit/gencerts.sh
index 790c715..419afa8 100755
--- a/unit/gencerts.sh
+++ b/unit/gencerts.sh
@@ -17,6 +17,11 @@ openssl pkcs8 -topk8 -nocrypt -in cert-client-key.pem -o=
ut cert-client-key-pkcs8
 openssl req -new -extensions cert_ext -config ./gencerts.cnf -subj '/O=3DB=
ar Example Organization/CN=3DBar Example Organization/emailAddress=3Dbar(a)=
mail.example' -key cert-client-key.pem -out cert-client.csr
 openssl x509 -req -extensions cert_ext -extfile ./gencerts.cnf -in cert-cl=
ient.csr -CA cert-ca.pem -CAkey cert-ca-key.pem -CAcreateserial -sha256 -da=
ys 10000 -out cert-client.pem
 openssl verify -CAfile cert-ca.pem cert-client.pem
+openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-md5-des.p=
em -topk8 -passout pass:abc
+openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-des.pe=
m -topk8 -v2 des-cbc -passout pass:abc
+openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-des-ed=
e3.pem -topk8 -v2 des-ede3-cbc -passout pass:abc
+openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-aes128=
.pem -topk8 -v2 aes128 -passout pass:abc
+openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-aes256=
.pem -topk8 -v2 aes256 -passout pass:abc
 =

 echo -e "\n*** Intermediate Certificate ***"
 openssl genrsa -out cert-intca-key.pem
-- =

2.11.0


--===============6798046808919063234==--

