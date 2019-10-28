Content-Type: multipart/mixed; boundary="===============6244605471427529275=="
MIME-Version: 1.0
From: Will Dietz <w@wdtz.org>
Subject: [PATCH] utf8: cast to avoid left shift of negative value (ubsan)
Date: Mon, 28 Oct 2019 14:41:00 -0500
Message-ID: <20191028194100.11762-1-w@wdtz.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6244605471427529275==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/utf8.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/utf8.c b/ell/utf8.c
index e6b4b05..44601dc 100644
--- a/ell/utf8.c
+++ b/ell/utf8.c
@@ -98,7 +98,7 @@ LIB_EXPORT int l_utf8_get_codepoint(const char *str, size=
_t len, wchar_t *cp)
 		return 1;
 	}
 =

-	expect_bytes =3D __builtin_clz(~(str[0] << 24));
+	expect_bytes =3D __builtin_clz(~((unsigned char)str[0] << 24));
 =

 	if (expect_bytes < 2 || expect_bytes > 4)
 		goto error;
-- =

2.24.0-rc1

--===============6244605471427529275==--

