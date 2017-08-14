Content-Type: multipart/mixed; boundary="===============5262162342448458609=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 6/7] unit: Update for l_pem_load_private_key() signature change
Date: Mon, 14 Aug 2017 16:57:49 +0200
Message-ID: <20170814145750.6683-6-andrew.zaborowski@intel.com>
In-Reply-To: <20170814145750.6683-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5262162342448458609==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/unit/test-key.c b/unit/test-key.c
index 7513b38..9e87fed 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -575,7 +575,7 @@ static void test_key_crypto(const void *data)
 	int rsa =3D L_KEY_RSA_PKCS1_V1_5;
 =

 	cert =3D l_pem_load_private_key(TESTDATADIR "/cert-client-key-pkcs8.pem",
-					NULL, &certlen);
+					NULL, NULL, &certlen);
 	assert(cert);
 	pubcert =3D l_pem_load_certificate(TESTDATADIR "/cert-client.pem",
 						&pubcertlen);
-- =

2.11.0


--===============5262162342448458609==--

