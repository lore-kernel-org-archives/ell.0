Content-Type: multipart/mixed; boundary="===============7370676845117659586=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] unit: Remove loop initial declaration.
Date: Tue, 26 Feb 2019 10:09:31 -0800
Message-ID: <20190226180931.32239-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7370676845117659586==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Move the variable declaration in test_string.c:test_strv_append() out
of the for-loop initial declaration to support older C standards, as
well as to conform to the ELL coding style.
---
 unit/test-string.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/unit/test-string.c b/unit/test-string.c
index 710617b..d8aebcb 100644
--- a/unit/test-string.c
+++ b/unit/test-string.c
@@ -257,15 +257,15 @@ static void test_strv_append(const void *test_data)
 {
 	const char *src[] =3D { "Foo", "Bar" };
 	char **dst =3D NULL;
-
 	size_t len =3D L_ARRAY_SIZE(src);
+	size_t i;
 =

-	for (size_t i =3D 0; i < len; i++)
+	for (i =3D 0; i < len; i++)
 		dst =3D l_strv_append(dst, src[i]);
 =

 	assert(l_strv_length(dst) =3D=3D len);
 =

-	for (size_t i =3D 0; i < len; i++)
+	for (i =3D 0; i < len; i++)
 		assert(strcmp(src[i], dst[i]) =3D=3D 0);
 =

         l_strv_free(dst);
-- =

2.17.1


--===============7370676845117659586==--

