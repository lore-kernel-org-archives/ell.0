Content-Type: multipart/mixed; boundary="===============8403391007158605518=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/2] log: Use __func__ for function name
Date: Tue, 23 Oct 2018 16:34:58 -0700
Message-ID: <20181023233459.18708-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8403391007158605518==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

__FUNCTION__ and __PRETTY_FUNCTION__ are older gcc aliases for
__func__. Switch to use __func__ in L_DEBUG_SYMBOL(), like l_log()
already does. This resolves some compiler warnings in ELL headers when a
program is built with compiler flags that are more strict than the
maintainer-mode build.
---
 ell/log.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/log.h b/ell/log.h
index d21e2aa..a86705f 100644
--- a/ell/log.h
+++ b/ell/log.h
@@ -66,12 +66,12 @@ struct l_debug_desc {
 #define L_DEBUG_SYMBOL(symbol, format, args...) do { \
 	static struct l_debug_desc symbol \
 	__attribute__((used, section("__ell_debug"), aligned(8))) =3D { \
-		.file =3D __FILE__, .func =3D __FUNCTION__, \
+		.file =3D __FILE__, .func =3D __func__, \
 		.flags =3D L_DEBUG_FLAG_DEFAULT, \
 	}; \
 	if (symbol.flags & L_DEBUG_FLAG_PRINT) \
 		l_log(L_LOG_DEBUG, "%s:%s() " format, __FILE__, \
-					__PRETTY_FUNCTION__ , ## args); \
+					__func__ , ## args); \
 } while (0)
 =

 void l_debug_enable_full(const char *pattern,
-- =

2.19.1


--===============8403391007158605518==--

