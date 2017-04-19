Content-Type: multipart/mixed; boundary="===============7358824813293263988=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 3/3] unit: More test coverage for TLS chain validation
Date: Tue, 18 Apr 2017 17:24:19 -0700
Message-ID: <20170419002419.9762-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20170419002419.9762-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7358824813293263988==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Confirm that cert validation fails when the wrong root cert is supplied,
and to confirm behavior when no trusted root is supplied.
---
 unit/test-tls.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 0d23f16..0082c36 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -214,6 +214,7 @@ static void test_certificates(const void *data)
 {
 	struct tls_cert *cert;
 	struct tls_cert *cacert;
+	struct tls_cert *wrongca;
 =

 	cert =3D tls_cert_load_file(TESTDATADIR "/cert-server.pem");
 	assert(cert);
@@ -221,10 +222,18 @@ static void test_certificates(const void *data)
 	cacert =3D tls_cert_load_file(TESTDATADIR "/cert-ca.pem");
 	assert(cacert);
 =

+	wrongca =3D tls_cert_load_file(TESTDATADIR "/cert-intca.pem");
+	assert(wrongca);
+
+	assert(!tls_cert_verify_certchain(cert, wrongca));
+
 	assert(tls_cert_verify_certchain(cert, cacert));
 =

+	assert(tls_cert_verify_certchain(cert, NULL));
+
 	l_free(cert);
 	l_free(cacert);
+	l_free(wrongca);
 }
 =

 struct tls_conn_test {
-- =

2.12.2


--===============7358824813293263988==--

