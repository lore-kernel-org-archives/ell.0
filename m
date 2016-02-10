Content-Type: multipart/mixed; boundary="===============5892407520804407764=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/2] build: Undefine _FORTIFY_SOURCE when building without
 optimization
Date: Wed, 10 Feb 2016 15:48:42 -0800
Message-ID: <1455148122-20449-2-git-send-email-mathew.j.martineau@linux.intel.com>
In-Reply-To: <1455148122-20449-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5892407520804407764==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

'./configure --disable-optimization --enable-maintainer-mode' would
claim that signalfd was not available. _FORTIFY_SOURCE requires that
optimization is enabled and issues a compile-time warning which is
treated as an error. Disabling optimization takes precedence over
fortification in this case, since it is being explicitly requested.
---
 configure.ac | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index f074081..39755fe 100644
--- a/configure.ac
+++ b/configure.ac
@@ -33,7 +33,7 @@ LT_INIT([disable-static])
 AC_ARG_ENABLE(optimization, AC_HELP_STRING([--disable-optimization],
 			[disable code optimization through compiler]), [
 	if (test "${enableval}" =3D "no"); then
-		CFLAGS=3D"$CFLAGS -O0"
+		CFLAGS=3D"$CFLAGS -U_FORTIFY_SOURCE -O0"
 	fi
 ])
 =

-- =

2.7.0


--===============5892407520804407764==--

