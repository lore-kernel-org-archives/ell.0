Content-Type: multipart/mixed; boundary="===============7858628480086999345=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/5] unit: Test l_certchain_verify with no-keyid certificates
Date: Thu, 09 Apr 2020 01:37:22 +0200
Message-ID: <20200408233724.25721-3-andrew.zaborowski@intel.com>
In-Reply-To: <20200408233724.25721-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7858628480086999345==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In test-tls slightly refactor test_certificates() to avoid having so
many variables and add new asserts to check that l_certchain_verify()
can load a self-signed CA certificate with no SKID or AKID extension
(the kernel has a problem with these certificates) and also that it can
be looked up when verifying a leaf certificate pointing to that CA only
by name+serial combination.
---
 unit/test-tls.c | 81 +++++++++++++++++++++++++++++++------------------
 1 file changed, 52 insertions(+), 29 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 3519376..92747b4 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -230,9 +230,6 @@ static void test_certificates(const void *data)
 	struct l_queue *wrongca;
 	struct l_queue *twocas;
 	struct l_certchain *chain;
-	struct l_certchain *chain2;
-	struct l_certchain *chain3;
-	struct l_certchain *chain4;
 =

 	cacert =3D l_pem_load_certificate_list(CERTDIR "cert-ca.pem");
 	assert(cacert && !l_queue_isempty(cacert));
@@ -251,46 +248,72 @@ static void test_certificates(const void *data)
 	assert(l_certchain_verify(chain, NULL, NULL));
 	assert(l_certchain_verify(chain, twocas, NULL));
 =

-	chain2 =3D l_pem_load_certificate_chain(CERTDIR "cert-chain.pem");
-	assert(chain2);
+	l_certchain_free(chain);
+
+	chain =3D l_pem_load_certificate_chain(CERTDIR "cert-chain.pem");
+	assert(chain);
 =

-	assert(!l_certchain_verify(chain2, wrongca, NULL));
-	assert(l_certchain_verify(chain2, cacert, NULL));
-	assert(l_certchain_verify(chain2, NULL, NULL));
-	assert(l_certchain_verify(chain2, twocas, NULL));
+	assert(!l_certchain_verify(chain, wrongca, NULL));
+	assert(l_certchain_verify(chain, cacert, NULL));
+	assert(l_certchain_verify(chain, NULL, NULL));
+	assert(l_certchain_verify(chain, twocas, NULL));
+
+	l_certchain_free(chain);
 =

-	chain3 =3D certchain_new_from_leaf(
+	chain =3D certchain_new_from_leaf(
 			load_cert_file(CERTDIR "cert-server.pem"));
-	certchain_link_issuer(chain3,
+	certchain_link_issuer(chain,
 			load_cert_file(CERTDIR "cert-entity-int.pem"));
-	certchain_link_issuer(chain3,
+	certchain_link_issuer(chain,
 			load_cert_file(CERTDIR "cert-intca.pem"));
-	certchain_link_issuer(chain3,
+	certchain_link_issuer(chain,
 			load_cert_file(CERTDIR "cert-ca.pem"));
-	assert(chain3);
+	assert(chain);
+
+	assert(!l_certchain_verify(chain, wrongca, NULL));
+	assert(!l_certchain_verify(chain, cacert, NULL));
+	assert(!l_certchain_verify(chain, NULL, NULL));
+	assert(!l_certchain_verify(chain, twocas, NULL));
 =

-	assert(!l_certchain_verify(chain3, wrongca, NULL));
-	assert(!l_certchain_verify(chain3, cacert, NULL));
-	assert(!l_certchain_verify(chain3, NULL, NULL));
-	assert(!l_certchain_verify(chain3, twocas, NULL));
+	l_certchain_free(chain);
 =

-	chain4 =3D certchain_new_from_leaf(
+	chain =3D certchain_new_from_leaf(
 			load_cert_file(CERTDIR "cert-entity-int.pem"));
-	certchain_link_issuer(chain4,
+	certchain_link_issuer(chain,
 			load_cert_file(CERTDIR "cert-intca.pem"));
-	certchain_link_issuer(chain4,
+	certchain_link_issuer(chain,
 			load_cert_file(CERTDIR "cert-ca.pem"));
-	assert(chain4);
+	assert(chain);
+
+	assert(!l_certchain_verify(chain, wrongca, NULL));
+	assert(l_certchain_verify(chain, cacert, NULL));
+	assert(l_certchain_verify(chain, NULL, NULL));
+	assert(l_certchain_verify(chain, twocas, NULL));
+
+	l_certchain_free(chain);
+	l_queue_destroy(cacert, (l_queue_destroy_func_t) l_cert_free);
+
+	cacert =3D l_pem_load_certificate_list(CERTDIR "cert-ca2.pem");
+	assert(cacert && !l_queue_isempty(cacert));
+
+	chain =3D certchain_new_from_leaf(
+			load_cert_file(CERTDIR "cert-no-keyid.pem"));
+	assert(chain);
 =

-	assert(!l_certchain_verify(chain4, wrongca, NULL));
-	assert(l_certchain_verify(chain4, cacert, NULL));
-	assert(l_certchain_verify(chain4, NULL, NULL));
-	assert(l_certchain_verify(chain4, twocas, NULL));
+	assert(!l_certchain_verify(chain, wrongca, NULL));
+	assert(l_certchain_verify(chain, cacert, NULL));
+	assert(l_certchain_verify(chain, NULL, NULL));
+	assert(!l_certchain_verify(chain, twocas, NULL));
+
+	certchain_link_issuer(chain,
+			load_cert_file(CERTDIR "cert-ca2.pem"));
+
+	assert(!l_certchain_verify(chain, wrongca, NULL));
+	assert(l_certchain_verify(chain, cacert, NULL));
+	assert(l_certchain_verify(chain, NULL, NULL));
+	assert(!l_certchain_verify(chain, twocas, NULL));
 =

 	l_certchain_free(chain);
-	l_certchain_free(chain2);
-	l_certchain_free(chain3);
-	l_certchain_free(chain4);
 	l_queue_destroy(cacert, (l_queue_destroy_func_t) l_cert_free);
 	l_queue_destroy(wrongca, (l_queue_destroy_func_t) l_cert_free);
 	l_queue_destroy(twocas, (l_queue_destroy_func_t) l_cert_free);
-- =

2.20.1

--===============7858628480086999345==--

