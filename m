Content-Type: multipart/mixed; boundary="===============3228244433367175073=="
MIME-Version: 1.0
From: ell@ongy.net
Subject: [PATCH 1/4] autotools: Only used -Wcast-align with gcc
Date: Wed, 14 Dec 2016 23:51:18 +0100
Message-ID: <20161214225121.9439-2-ell@ongy.net>
In-Reply-To: <20161214225121.9439-1-ell@ongy.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3228244433367175073==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Markus Ongyerth <ongy@ongy.net>

clang can currently not compile NLMSG_NEXT with -Wcast-align.
I asked about this in #llvm on irc.oftc.net, where I was told the best
solution is to disable -Wcast-align for now.
---
 acinclude.m4 | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/acinclude.m4 b/acinclude.m4
index 8aab4ee..b1dbabe 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -58,6 +58,8 @@ AC_DEFUN([COMPILER_FLAGS], [
 		CFLAGS+=3D" -Wdeclaration-after-statement"
 		CFLAGS+=3D" -Wmissing-declarations"
 		CFLAGS+=3D" -Wredundant-decls"
-		CFLAGS+=3D" -Wcast-align"
+		if ( $CC -v 2>/dev/null | grep "gcc version" ); then
+			CFLAGS+=3D" -Wcast-align"
+		fi
 	fi
 ])
-- =

2.10.2


--===============3228244433367175073==--

