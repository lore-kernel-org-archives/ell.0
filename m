Content-Type: multipart/mixed; boundary="===============8181532460260133553=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 5/9] unit: Update RSA cipher type name
Date: Fri, 23 Sep 2016 16:02:18 -0700
Message-ID: <20160923230222.27401-5-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160923230222.27401-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8181532460260133553==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/unit/test-key.c b/unit/test-key.c
index 0742eb7..bd3e72f 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -492,7 +492,7 @@ static void test_key_crypto(const void *data)
 	ssize_t len;
 	struct l_checksum *checksum;
 	int hash =3D L_CHECKSUM_SHA256;
-	int rsa =3D L_CIPHER_RSA_PKCS1_V1_5;
+	int rsa =3D L_KEY_RSA_PKCS1_V1_5;
 =

 	cert =3D l_pem_load_private_key(TESTDATADIR "/cert-client-key-pkcs8.pem",
 					NULL, &certlen);
-- =

2.10.0


--===============8181532460260133553==--

