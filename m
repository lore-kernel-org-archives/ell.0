Content-Type: multipart/mixed; boundary="===============3042021544399606625=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 4/5] string: Use __va_copy() for pre-C99 builds.
Date: Mon, 04 Mar 2019 10:42:58 -0800
Message-ID: <20190304184259.22809-5-ossama.othman@intel.com>
In-Reply-To: <20190304184259.22809-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3042021544399606625==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The va_copy() function was introduced in C99.  Use __va_copy() when
building for older C standards to address a link-time error.
---
 ell/string.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ell/string.c b/ell/string.c
index f959bb9..37806e3 100644
--- a/ell/string.c
+++ b/ell/string.c
@@ -242,7 +242,11 @@ LIB_EXPORT void l_string_append_vprintf(struct l_strin=
g *dest,
 	if (unlikely(!dest))
 		return;
 =

+#if __STDC_VERSION__ > 199409L
 	va_copy(args_copy, args);
+#else
+	__va_copy(args_copy, args);
+#endif
 =

 	have_space =3D dest->max - dest->len;
 	len =3D vsnprintf(dest->str + dest->len, have_space, format, args);
-- =

2.17.1


--===============3042021544399606625==--

