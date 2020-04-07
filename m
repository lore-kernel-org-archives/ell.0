Content-Type: multipart/mixed; boundary="===============9174344053771682344=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/3] unit: Relax test-tls certificate chain checks
Date: Tue, 07 Apr 2020 19:45:51 +0200
Message-ID: <20200407174551.9505-3-andrew.zaborowski@intel.com>
In-Reply-To: <20200407174551.9505-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9174344053771682344==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make the l_certchain_verify() failure tests pass after the previous
commit.
---
 unit/test-tls.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 3519376..f4beee8 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -228,6 +228,7 @@ static void test_certificates(const void *data)
 {
 	struct l_queue *cacert;
 	struct l_queue *wrongca;
+	struct l_queue *wrongca2;
 	struct l_queue *twocas;
 	struct l_certchain *chain;
 	struct l_certchain *chain2;
@@ -240,6 +241,9 @@ static void test_certificates(const void *data)
 	wrongca =3D l_pem_load_certificate_list(CERTDIR "cert-intca.pem");
 	assert(wrongca && !l_queue_isempty(wrongca));
 =

+	wrongca2 =3D l_pem_load_certificate_list(CERTDIR "cert-server.pem");
+	assert(wrongca2 && !l_queue_isempty(wrongca2));
+
 	twocas =3D l_pem_load_certificate_list(CERTDIR "cert-chain.pem");
 	assert(twocas);
 =

@@ -254,7 +258,7 @@ static void test_certificates(const void *data)
 	chain2 =3D l_pem_load_certificate_chain(CERTDIR "cert-chain.pem");
 	assert(chain2);
 =

-	assert(!l_certchain_verify(chain2, wrongca, NULL));
+	assert(!l_certchain_verify(chain2, wrongca2, NULL));
 	assert(l_certchain_verify(chain2, cacert, NULL));
 	assert(l_certchain_verify(chain2, NULL, NULL));
 	assert(l_certchain_verify(chain2, twocas, NULL));
@@ -282,7 +286,7 @@ static void test_certificates(const void *data)
 			load_cert_file(CERTDIR "cert-ca.pem"));
 	assert(chain4);
 =

-	assert(!l_certchain_verify(chain4, wrongca, NULL));
+	assert(!l_certchain_verify(chain4, wrongca2, NULL));
 	assert(l_certchain_verify(chain4, cacert, NULL));
 	assert(l_certchain_verify(chain4, NULL, NULL));
 	assert(l_certchain_verify(chain4, twocas, NULL));
@@ -293,6 +297,7 @@ static void test_certificates(const void *data)
 	l_certchain_free(chain4);
 	l_queue_destroy(cacert, (l_queue_destroy_func_t) l_cert_free);
 	l_queue_destroy(wrongca, (l_queue_destroy_func_t) l_cert_free);
+	l_queue_destroy(wrongca2, (l_queue_destroy_func_t) l_cert_free);
 	l_queue_destroy(twocas, (l_queue_destroy_func_t) l_cert_free);
 }
 =

-- =

2.20.1

--===============9174344053771682344==--

