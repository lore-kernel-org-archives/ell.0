Content-Type: multipart/mixed; boundary="===============2016301954511445170=="
MIME-Version: 1.0
From: Fangrui Song <i at maskray.me>
To: ell at lists.01.org
Subject: [PATCH] log: Set retain attribute on __ell_debug
Date: Wed, 10 Nov 2021 19:07:42 -0800
Message-ID: <20211111030742.2005152-1-i@maskray.me>

--===============2016301954511445170==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

LLD 13 and GNU ld 2.37 support -z start-stop-gc which allows garbage
collection of C identifier name sections despite the __start_/__stop_
references. GNU ld before 2015-10 had the behavior as well. Simply set
the retain attribute so that GCC 11 (if configure-time binutils is 2.36
or newer)/Clang 13 will set the SHF_GNU_RETAIN section attribute to
prevent garbage collection.

Without the patch, there are linker errors with -z start-stop-gc (LLD defau=
lt):

```
ld.lld: error: undefined symbol: __start___ell_debug
>>> referenced by log.c
>>>               log.o:(register_debug_section) in archive ell/.libs/libel=
l-private.a
```
---
 ell/log.h | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/ell/log.h b/ell/log.h
index 924523b..32d6b8a 100644
--- a/ell/log.h
+++ b/ell/log.h
@@ -61,12 +61,18 @@ struct l_debug_desc {
 	unsigned int flags;
 } __attribute__((aligned(8)));
 =

+// Set the retain attribute so that the section cannot be discarded by ld
+// --gc-sections -z start-stop-gc. Older compilers would warn for the unkn=
own
+// attribute, so just disable -Wattributes.
 #define L_DEBUG_SYMBOL(symbol, format, ...) do { \
+_Pragma("GCC diagnostic push") \
+_Pragma("GCC diagnostic ignored \"-Wattributes\"") \
 	static struct l_debug_desc symbol \
-	__attribute__((used, section("__ell_debug"), aligned(8))) =3D { \
+	__attribute__((used, retain, section("__ell_debug"), aligned(8))) =3D { \
 		.file =3D __FILE__, .func =3D __func__, \
 		.flags =3D L_DEBUG_FLAG_DEFAULT, \
 	}; \
+_Pragma("GCC diagnostic pop") \
 	if (symbol.flags & L_DEBUG_FLAG_PRINT) \
 		l_log(L_LOG_DEBUG, "%s:%s() " format, __FILE__, \
 					__func__ , ##__VA_ARGS__); \
-- =

2.34

--===============2016301954511445170==--

