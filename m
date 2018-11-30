Content-Type: multipart/mixed; boundary="===============5266460146766065845=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/6] unit: Update test-tls to new l_certchain_verify params
Date: Fri, 30 Nov 2018 13:05:49 +0100
Message-ID: <20181130120550.8866-5-andrew.zaborowski@intel.com>
In-Reply-To: <20181130120550.8866-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5266460146766065845==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index e8c18f0..84dd950 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -232,18 +232,18 @@ static void test_certificates(const void *data)
 	chain =3D l_pem_load_certificate_chain(CERTDIR "cert-server.pem");
 	assert(chain);
 =

-	assert(!l_certchain_verify(chain, wrongca));
-	assert(l_certchain_verify(chain, cacert));
-	assert(l_certchain_verify(chain, NULL));
-	assert(l_certchain_verify(chain, twocas));
+	assert(!l_certchain_verify(chain, wrongca, NULL));
+	assert(l_certchain_verify(chain, cacert, NULL));
+	assert(l_certchain_verify(chain, NULL, NULL));
+	assert(l_certchain_verify(chain, twocas, NULL));
 =

 	chain2 =3D l_pem_load_certificate_chain(CERTDIR "cert-chain.pem");
 	assert(chain2);
 =

-	assert(!l_certchain_verify(chain2, wrongca));
-	assert(l_certchain_verify(chain2, cacert));
-	assert(l_certchain_verify(chain2, NULL));
-	assert(l_certchain_verify(chain2, twocas));
+	assert(!l_certchain_verify(chain2, wrongca, NULL));
+	assert(l_certchain_verify(chain2, cacert, NULL));
+	assert(l_certchain_verify(chain2, NULL, NULL));
+	assert(l_certchain_verify(chain2, twocas, NULL));
 =

 	chain3 =3D certchain_new_from_leaf(
 			tls_cert_load_file(CERTDIR "cert-server.pem"));
@@ -255,10 +255,10 @@ static void test_certificates(const void *data)
 			tls_cert_load_file(CERTDIR "cert-ca.pem"));
 	assert(chain3);
 =

-	assert(!l_certchain_verify(chain3, wrongca));
-	assert(!l_certchain_verify(chain3, cacert));
-	assert(!l_certchain_verify(chain3, NULL));
-	assert(!l_certchain_verify(chain3, twocas));
+	assert(!l_certchain_verify(chain3, wrongca, NULL));
+	assert(!l_certchain_verify(chain3, cacert, NULL));
+	assert(!l_certchain_verify(chain3, NULL, NULL));
+	assert(!l_certchain_verify(chain3, twocas, NULL));
 =

 	chain4 =3D certchain_new_from_leaf(
 			tls_cert_load_file(CERTDIR "cert-entity-int.pem"));
@@ -268,10 +268,10 @@ static void test_certificates(const void *data)
 			tls_cert_load_file(CERTDIR "cert-ca.pem"));
 	assert(chain4);
 =

-	assert(!l_certchain_verify(chain4, wrongca));
-	assert(l_certchain_verify(chain4, cacert));
-	assert(l_certchain_verify(chain4, NULL));
-	assert(l_certchain_verify(chain4, twocas));
+	assert(!l_certchain_verify(chain4, wrongca, NULL));
+	assert(l_certchain_verify(chain4, cacert, NULL));
+	assert(l_certchain_verify(chain4, NULL, NULL));
+	assert(l_certchain_verify(chain4, twocas, NULL));
 =

 	l_certchain_free(chain);
 	l_certchain_free(chain2);
-- =

2.19.1


--===============5266460146766065845==--

