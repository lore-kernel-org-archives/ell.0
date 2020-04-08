Content-Type: multipart/mixed; boundary="===============7921896006743817976=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/5] unit: Relax test-tls certificate chain checks
Date: Thu, 09 Apr 2020 01:37:24 +0200
Message-ID: <20200408233724.25721-5-andrew.zaborowski@intel.com>
In-Reply-To: <20200408233724.25721-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7921896006743817976==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make the l_certchain_verify() failure tests pass after the previous
commit.
---
 unit/test-tls.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 92747b4..89dcb9a 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -228,6 +228,7 @@ static void test_certificates(const void *data)
 {
 	struct l_queue *cacert;
 	struct l_queue *wrongca;
+	struct l_queue *wrongca2;
 	struct l_queue *twocas;
 	struct l_certchain *chain;
 =

@@ -237,6 +238,9 @@ static void test_certificates(const void *data)
 	wrongca =3D l_pem_load_certificate_list(CERTDIR "cert-intca.pem");
 	assert(wrongca && !l_queue_isempty(wrongca));
 =

+	wrongca2 =3D l_pem_load_certificate_list(CERTDIR "cert-server.pem");
+	assert(wrongca2 && !l_queue_isempty(wrongca2));
+
 	twocas =3D l_pem_load_certificate_list(CERTDIR "cert-chain.pem");
 	assert(twocas);
 =

@@ -253,7 +257,7 @@ static void test_certificates(const void *data)
 	chain =3D l_pem_load_certificate_chain(CERTDIR "cert-chain.pem");
 	assert(chain);
 =

-	assert(!l_certchain_verify(chain, wrongca, NULL));
+	assert(!l_certchain_verify(chain, wrongca2, NULL));
 	assert(l_certchain_verify(chain, cacert, NULL));
 	assert(l_certchain_verify(chain, NULL, NULL));
 	assert(l_certchain_verify(chain, twocas, NULL));
@@ -285,7 +289,7 @@ static void test_certificates(const void *data)
 			load_cert_file(CERTDIR "cert-ca.pem"));
 	assert(chain);
 =

-	assert(!l_certchain_verify(chain, wrongca, NULL));
+	assert(!l_certchain_verify(chain, wrongca2, NULL));
 	assert(l_certchain_verify(chain, cacert, NULL));
 	assert(l_certchain_verify(chain, NULL, NULL));
 	assert(l_certchain_verify(chain, twocas, NULL));
@@ -316,6 +320,7 @@ static void test_certificates(const void *data)
 	l_certchain_free(chain);
 	l_queue_destroy(cacert, (l_queue_destroy_func_t) l_cert_free);
 	l_queue_destroy(wrongca, (l_queue_destroy_func_t) l_cert_free);
+	l_queue_destroy(wrongca2, (l_queue_destroy_func_t) l_cert_free);
 	l_queue_destroy(twocas, (l_queue_destroy_func_t) l_cert_free);
 }
 =

-- =

2.20.1

--===============7921896006743817976==--

