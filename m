Content-Type: multipart/mixed; boundary="===============7490088783260753994=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 2/8] util: Use unlikely() for L_WARN_ON() condition
Date: Fri, 15 Apr 2022 20:32:05 +0200
Message-ID: <20220415183211.987345-2-andrew.zaborowski@intel.com>
In-Reply-To: 20220415183211.987345-1-andrew.zaborowski@intel.com

--===============7490088783260753994==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Any condition used in L_WARN_ON() should be only true in an error or
trouble situation and thus be unlikely true.   Add unlikely() directly
in the macro to avoid repeating use of L_WARN_ON(unlikely(condition))
---
 ell/util.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/util.h b/ell/util.h
index 9d4e36c..db47ae7 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -49,7 +49,7 @@ _Pragma("GCC diagnostic pop")						\
 =

 #define L_WARN_ON(condition) __extension__ ({				\
 		bool r =3D !!(condition);					\
-		if (r)							\
+		if (unlikely(r))					\
 			l_warn("WARNING: %s:%s() condition %s failed",	\
 				__FILE__, __func__,			\
 				#condition);				\
-- =

2.32.0

--===============7490088783260753994==--

