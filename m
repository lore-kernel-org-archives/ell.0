Content-Type: multipart/mixed; boundary="===============4922110829040541559=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 07/11] unit: Update tls_cert_verify_certchain parameters
Date: Thu, 01 Nov 2018 12:54:49 +0100
Message-ID: <20181101115453.10373-7-andrew.zaborowski@intel.com>
In-Reply-To: <20181101115453.10373-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4922110829040541559==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index d969ee7..75f36f0 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -214,16 +214,16 @@ static void test_tls12_prf(const void *data)
 static void test_certificates(const void *data)
 {
 	struct tls_cert *cert;
-	struct tls_cert *cacert;
-	struct tls_cert *wrongca;
+	struct l_queue *cacert;
+	struct l_queue *wrongca;
 =

 	cert =3D tls_cert_load_file(CERTDIR "cert-server.pem");
 	assert(cert);
 =

-	cacert =3D tls_cert_load_file(CERTDIR "cert-ca.pem");
+	cacert =3D tls_cert_list_load_file(CERTDIR "cert-ca.pem");
 	assert(cacert);
 =

-	wrongca =3D tls_cert_load_file(CERTDIR "cert-intca.pem");
+	wrongca =3D tls_cert_list_load_file(CERTDIR "cert-intca.pem");
 	assert(wrongca);
 =

 	assert(!tls_cert_verify_certchain(cert, wrongca));
@@ -233,8 +233,8 @@ static void test_certificates(const void *data)
 	assert(tls_cert_verify_certchain(cert, NULL));
 =

 	l_free(cert);
-	l_free(cacert);
-	l_free(wrongca);
+	l_queue_destroy(cacert, l_free);
+	l_queue_destroy(wrongca, l_free);
 }
 =

 struct tls_conn_test {
-- =

2.19.1


--===============4922110829040541559==--

