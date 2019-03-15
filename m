Content-Type: multipart/mixed; boundary="===============1507418678372457200=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] utf8: Don't rely on char being signed
Date: Fri, 15 Mar 2019 01:13:30 +0100
Message-ID: <20190315001331.1944-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1507418678372457200==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Even if it gets forced by compile flags in a future commit it's better
to avoid this char usage.

Reported-by: Natanael Copa
Tested-by: Natanael Copa
---
 ell/utf8.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/utf8.c b/ell/utf8.c
index e9998f7..edc2fc0 100644
--- a/ell/utf8.c
+++ b/ell/utf8.c
@@ -93,7 +93,7 @@ LIB_EXPORT int l_utf8_get_codepoint(const char *str, size=
_t len, wchar_t *cp)
 	if (len =3D=3D 0)
 		return 0;
 =

-	if (str[0] > 0) {
+	if ((signed char) str[0] > 0) {
 		*cp =3D str[0];
 		return 1;
 	}
-- =

2.19.1


--===============1507418678372457200==--

