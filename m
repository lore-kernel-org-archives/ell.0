Content-Type: multipart/mixed; boundary="===============8352540512550471845=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/3] unit: Generate encrypted test keys in gencerts.sh
Date: Thu, 17 Aug 2017 11:06:31 +0200
Message-ID: <20170817090631.27630-3-andrew.zaborowski@intel.com>
In-Reply-To: <20170817090631.27630-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8352540512550471845==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/gencerts.sh | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/unit/gencerts.sh b/unit/gencerts.sh
index b0249fb..d4c29a7 100755
--- a/unit/gencerts.sh
+++ b/unit/gencerts.sh
@@ -17,6 +17,12 @@ openssl pkcs8 -topk8 -nocrypt -in cert-client-key.pem -o=
ut cert-client-key-pkcs8
 openssl req -new -extensions cert_ext -config ./gencerts.cnf -subj '/O=3DB=
ar Example Organization/CN=3DBar Example Organization/emailAddress=3Dbar(a)=
mail.example' -key cert-client-key.pem -out cert-client.csr
 openssl x509 -req -extensions cert_ext -extfile ./gencerts.cnf -in cert-cl=
ient.csr -CA cert-ca.pem -CAkey cert-ca-key.pem -CAcreateserial -sha256 -da=
ys 10000 -out cert-client.pem
 openssl verify -CAfile cert-ca.pem cert-client.pem
+openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-md5-des.p=
em -topk8 -v1 PBE-MD5-DES -passout pass:abc
+openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-sha1-des.=
pem -topk8 -v1 PBE-SHA1-DES -passout pass:abc
+openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-des.pe=
m -topk8 -v2 des-cbc -v2prf hmacWithSHA1 -passout pass:abc
+openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-des-ed=
e3.pem -topk8 -v2 des-ede3-cbc -v2prf hmacWithSHA224 -passout pass:abc
+openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-aes128=
.pem -topk8 -v2 aes128 -v2prf hmacWithSHA256 -passout pass:abc
+openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-aes256=
.pem -topk8 -v2 aes256 -v2prf hmacWithSHA512 -passout pass:abc
 =

 echo -e "\n*** Intermediate Certificate ***"
 openssl genrsa -out cert-intca-key.pem
-- =

2.11.0


--===============8352540512550471845==--

