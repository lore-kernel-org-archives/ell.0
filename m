Content-Type: multipart/mixed; boundary="===============0985851640796190803=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/5] unit: More TLS certificate tests
Date: Fri, 23 Nov 2018 10:44:29 +0100
Message-ID: <20181123094429.7190-5-andrew.zaborowski@intel.com>
In-Reply-To: <20181123094429.7190-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0985851640796190803==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a few more certificate chain checks including some using
the stricter l_certchain_verify properties.
---
 unit/test-tls.c | 58 +++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 51 insertions(+), 7 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 8f00736..5103bef 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -212,14 +212,13 @@ static void test_tls12_prf(const void *data)
 =

 static void test_certificates(const void *data)
 {
-	struct l_cert *cert;
 	struct l_queue *cacert;
 	struct l_queue *wrongca;
+	struct l_queue *twocas;
 	struct l_certchain *chain;
-
-	cert =3D tls_cert_load_file(CERTDIR "cert-server.pem");
-	assert(cert);
-	chain =3D certchain_new_from_leaf(cert);
+	struct l_certchain *chain2;
+	struct l_certchain *chain3;
+	struct l_certchain *chain4;
 =

 	cacert =3D l_pem_load_certificate_list(CERTDIR "cert-ca.pem");
 	assert(cacert && !l_queue_isempty(cacert));
@@ -227,15 +226,60 @@ static void test_certificates(const void *data)
 	wrongca =3D l_pem_load_certificate_list(CERTDIR "cert-intca.pem");
 	assert(wrongca && !l_queue_isempty(wrongca));
 =

-	assert(!l_certchain_verify(chain, wrongca));
+	twocas =3D l_pem_load_certificate_list(CERTDIR "cert-chain.pem");
+	assert(twocas);
 =

-	assert(l_certchain_verify(chain, cacert));
+	chain =3D l_pem_load_certificate_chain(CERTDIR "cert-server.pem");
+	assert(chain);
 =

+	assert(!l_certchain_verify(chain, wrongca));
+	assert(l_certchain_verify(chain, cacert));
 	assert(l_certchain_verify(chain, NULL));
+	assert(l_certchain_verify(chain, twocas));
+
+	chain2 =3D l_pem_load_certificate_chain(CERTDIR "cert-chain.pem");
+	assert(chain2);
+
+	assert(!l_certchain_verify(chain2, wrongca));
+	assert(l_certchain_verify(chain2, cacert));
+	assert(l_certchain_verify(chain2, NULL));
+	assert(l_certchain_verify(chain2, twocas));
+
+	chain3 =3D certchain_new_from_leaf(
+			tls_cert_load_file(CERTDIR "cert-server.pem"));
+	certchain_link_issuer(chain3,
+			tls_cert_load_file(CERTDIR "cert-entity-int.pem"));
+	certchain_link_issuer(chain3,
+			tls_cert_load_file(CERTDIR "cert-intca.pem"));
+	certchain_link_issuer(chain3,
+			tls_cert_load_file(CERTDIR "cert-ca.pem"));
+	assert(chain3);
+
+	assert(!l_certchain_verify(chain3, wrongca));
+	assert(!l_certchain_verify(chain3, cacert));
+	assert(!l_certchain_verify(chain3, NULL));
+	assert(!l_certchain_verify(chain3, twocas));
+
+	chain4 =3D certchain_new_from_leaf(
+			tls_cert_load_file(CERTDIR "cert-entity-int.pem"));
+	certchain_link_issuer(chain4,
+			tls_cert_load_file(CERTDIR "cert-intca.pem"));
+	certchain_link_issuer(chain4,
+			tls_cert_load_file(CERTDIR "cert-ca.pem"));
+	assert(chain4);
+
+	assert(!l_certchain_verify(chain4, wrongca));
+	assert(l_certchain_verify(chain4, cacert));
+	assert(l_certchain_verify(chain4, NULL));
+	assert(l_certchain_verify(chain4, twocas));
 =

 	l_certchain_free(chain);
+	l_certchain_free(chain2);
+	l_certchain_free(chain3);
+	l_certchain_free(chain4);
 	l_queue_destroy(cacert, (l_queue_destroy_func_t) l_cert_free);
 	l_queue_destroy(wrongca, (l_queue_destroy_func_t) l_cert_free);
+	l_queue_destroy(twocas, (l_queue_destroy_func_t) l_cert_free);
 }
 =

 struct tls_conn_test {
-- =

2.19.1


--===============0985851640796190803==--

