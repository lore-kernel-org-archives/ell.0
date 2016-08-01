Content-Type: multipart/mixed; boundary="===============9116003083470984919=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v3 1/4] unit: Rename asymmetric key type to L_KEY_RSA
Date: Mon, 01 Aug 2016 14:25:46 -0700
Message-ID: <20160801212549.6526-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9116003083470984919==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/unit/test-key.c b/unit/test-key.c
index d52ae1b..7f5124f 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -375,9 +375,9 @@ static void test_trusted_keyring(const void *data)
 					&certlen);
 	assert(cert);
 =

-	cakey =3D l_key_new(L_KEY_ASYMMETRIC, cacert, cacertlen);
+	cakey =3D l_key_new(L_KEY_RSA, cacert, cacertlen);
 	assert(cakey);
-	key =3D l_key_new(L_KEY_ASYMMETRIC, cert, certlen);
+	key =3D l_key_new(L_KEY_RSA, cert, certlen);
 	assert(key);
 =

 	trust =3D l_keyring_new(L_KEYRING_SIMPLE, NULL);
-- =

2.9.2


--===============9116003083470984919==--

