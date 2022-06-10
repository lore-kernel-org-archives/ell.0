Content-Type: multipart/mixed; boundary="===============6801683071594147637=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH 2/2] missing: use PTRDIFF_MAX instead of -1
Date: Fri, 10 Jun 2022 10:11:32 -0700
Message-ID: <20220610171132.334641-2-prestwoj@gmail.com>
In-Reply-To: 20220610171132.334641-1-prestwoj@gmail.com

--===============6801683071594147637==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On musl-gcc the compiler complains that the size passed to
memchr (-1) is larger than the object size (size_t). Looking
at the values its limiting size_t to a max size of a signed
integer (0x7FFF....) and we are passing 0xFFFFF....

Since this size is quite large its not expected that anyone
will ever need to use memchr with a buffer this big.
Limiting the size to a signed integer max value should be just
fine.

Instead, use PTRDIFF_MAX rather than -1. Below is the warning
produced in upstream:

In file included from ell/pem.c:45:
In function 'rawmemchr',
    inlined from 'pem_load_buffer' at ell/pem.c:227:21:
ell/missing.h:76:16: error: 'memchr' specified bound
	18446744073709551615 may exceed maximum object size
	9223372036854775807 [-Werror=3Dstringop-overread]
   76 |         return memchr(s, c, (size_t) -1);
---
 ell/missing.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/missing.h b/ell/missing.h
index 2a3e647..11d6a8e 100644
--- a/ell/missing.h
+++ b/ell/missing.h
@@ -73,7 +73,7 @@ static inline void *rawmemchr(const void *s, int c)
 {
 _Pragma("GCC diagnostic push")
 _Pragma("GCC diagnostic ignored \"-Wstringop-overflow=3D\"")
-	return memchr(s, c, (size_t) -1);
+	return memchr(s, c, PTRDIFF_MAX);
 _Pragma("GCC diagnostic pop")
 }
 #endif
-- =

2.34.1

--===============6801683071594147637==--

