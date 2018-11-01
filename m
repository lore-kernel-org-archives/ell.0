Content-Type: multipart/mixed; boundary="===============0570850002282753327=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 11/11] unit: More TLS certificate tests
Date: Thu, 01 Nov 2018 12:54:53 +0100
Message-ID: <20181101115453.10373-11-andrew.zaborowski@intel.com>
In-Reply-To: <20181101115453.10373-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0570850002282753327==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a few more certificate chain checks including some using
tls_cert_list_load_file and the stricter tls_cert_verify_certchain.
---
 unit/test-tls.c | 39 ++++++++++++++++++++++++++++++++++++++-
 1 file changed, 38 insertions(+), 1 deletion(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 75f36f0..a134125 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -216,6 +216,9 @@ static void test_certificates(const void *data)
 	struct tls_cert *cert;
 	struct l_queue *cacert;
 	struct l_queue *wrongca;
+	struct l_queue *twocas;
+	struct tls_cert *chain;
+	struct tls_cert *chain2;
 =

 	cert =3D tls_cert_load_file(CERTDIR "cert-server.pem");
 	assert(cert);
@@ -226,15 +229,49 @@ static void test_certificates(const void *data)
 	wrongca =3D tls_cert_list_load_file(CERTDIR "cert-intca.pem");
 	assert(wrongca);
 =

+	twocas =3D tls_cert_list_load_file(CERTDIR "cert-chain.pem");
+	assert(wrongca);
+
 	assert(!tls_cert_verify_certchain(cert, wrongca));
 =

 	assert(tls_cert_verify_certchain(cert, cacert));
 =

 	assert(tls_cert_verify_certchain(cert, NULL));
 =

-	l_free(cert);
+	assert(tls_cert_verify_certchain(cert, twocas));
+
+	chain =3D tls_cert_load_file(CERTDIR "cert-server.pem");
+	assert(chain);
+	chain->issuer =3D tls_cert_load_file(CERTDIR "cert-entity-int.pem");
+	assert(chain->issuer);
+	chain->issuer->issuer =3D tls_cert_load_file(CERTDIR "cert-intca.pem");
+	assert(chain->issuer->issuer);
+	chain->issuer->issuer->issuer =3D
+		tls_cert_load_file(CERTDIR "cert-ca.pem");
+	assert(chain->issuer->issuer->issuer);
+	assert(tls_cert_verify_certchain(chain->issuer, cacert));
+	assert(tls_cert_verify_certchain(chain->issuer, NULL));
+	assert(!tls_cert_verify_certchain(chain->issuer, wrongca));
+	assert(tls_cert_verify_certchain(chain->issuer, twocas));
+	assert(!tls_cert_verify_certchain(chain, cacert));
+	assert(!tls_cert_verify_certchain(chain, NULL));
+	assert(!tls_cert_verify_certchain(chain, twocas));
+
+	chain2 =3D tls_cert_load_file(CERTDIR "cert-chain.pem");
+	assert(chain2);
+	assert(chain2->issuer);
+	assert(!chain2->issuer->issuer);
+	assert(tls_cert_verify_certchain(chain2, cacert));
+	assert(tls_cert_verify_certchain(chain2, NULL));
+	assert(!tls_cert_verify_certchain(chain2, wrongca));
+	assert(tls_cert_verify_certchain(chain2, twocas));
+
+	tls_cert_free_certchain(cert);
+	tls_cert_free_certchain(chain);
+	tls_cert_free_certchain(chain2);
 	l_queue_destroy(cacert, l_free);
 	l_queue_destroy(wrongca, l_free);
+	l_queue_destroy(twocas, l_free);
 }
 =

 struct tls_conn_test {
-- =

2.19.1


--===============0570850002282753327==--

