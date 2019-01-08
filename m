Content-Type: multipart/mixed; boundary="===============6253198731531116289=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/8] unit: Free temporary buffer in load_cert_file
Date: Tue, 08 Jan 2019 05:29:44 +0100
Message-ID: <20190108042951.21914-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6253198731531116289==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 6731a0e..3bb710e 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -212,16 +212,19 @@ static void test_tls12_prf(const void *data)
 =

 static struct l_cert *load_cert_file(const char *filename)
 {
-	const uint8_t *der;
+	uint8_t *der;
 	size_t len;
 	char *label;
+	struct l_cert *cert;
 =

 	der =3D l_pem_load_file(filename, 0, &label, &len);
 	if (!der)
 		return NULL;
 =

 	l_free(label);
-	return l_cert_new_from_der(der, len);
+	cert =3D l_cert_new_from_der(der, len);
+	l_free(der);
+	return cert;
 }
 =

 static void test_certificates(const void *data)
-- =

2.19.1


--===============6253198731531116289==--

