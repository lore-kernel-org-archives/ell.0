Content-Type: multipart/mixed; boundary="===============7470672470694316555=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 4/7] unit: Adjust for renamed l_key_get_payload_size
 function
Date: Fri, 29 Jul 2016 11:11:58 -0700
Message-ID: <20160729181201.16446-4-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160729181201.16446-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7470672470694316555==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/unit/test-key.c b/unit/test-key.c
index df1e13b..d52ae1b 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -55,7 +55,7 @@ static void test_user(const void *data)
 	key =3D l_key_new(L_KEY_RAW, KEY1_STR, KEY1_LEN);
 	assert(key);
 =

-	reported_len =3D l_key_get_size(key);
+	reported_len =3D l_key_get_payload_size(key);
 	assert(reported_len =3D=3D KEY1_LEN);
 =

 	len =3D KEY1_LEN - 1;
-- =

2.9.2


--===============7470672470694316555==--

