Content-Type: multipart/mixed; boundary="===============0456932156067457545=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] log: Use standard variadic macro syntax
Date: Fri, 07 Dec 2018 12:01:09 -0800
Message-ID: <20181207200109.16000-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0456932156067457545==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use '...' and '__VA_ARGS__' for variadic macros as described in
https://gcc.gnu.org/onlinedocs/cpp/Variadic-Macros.html

Previous 'args...' syntax is supported by gcc for backward compatibility,
but triggers compiler warnings with -Wvariadic-macros.
---

Tested build with iwd and bluez.


 ell/log.h | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/ell/log.h b/ell/log.h
index 324dcd8..19bf10b 100644
--- a/ell/log.h
+++ b/ell/log.h
@@ -49,9 +49,9 @@ void l_log_with_location(int priority, const char *file, =
const char *line,
 				const char *func, const char *format, ...)
 				__attribute__((format(printf, 5, 6)));
 =

-#define l_log(priority, format, args...)  l_log_with_location(priority, \
+#define l_log(priority, format, ...)  l_log_with_location(priority, \
 					__FILE__, L_STRINGIFY(__LINE__), \
-					__func__, format "\n", ## args)
+					__func__, format "\n", ##__VA_ARGS__)
 =

 struct l_debug_desc {
 	const char *file;
@@ -61,7 +61,7 @@ struct l_debug_desc {
 	unsigned int flags;
 } __attribute__((aligned(8)));
 =

-#define L_DEBUG_SYMBOL(symbol, format, args...) do { \
+#define L_DEBUG_SYMBOL(symbol, format, ...) do { \
 	static struct l_debug_desc symbol \
 	__attribute__((used, section("__ell_debug"), aligned(8))) =3D { \
 		.file =3D __FILE__, .func =3D __func__, \
@@ -69,7 +69,7 @@ struct l_debug_desc {
 	}; \
 	if (symbol.flags & L_DEBUG_FLAG_PRINT) \
 		l_log(L_LOG_DEBUG, "%s:%s() " format, __FILE__, \
-					__func__ , ## args); \
+					__func__ , ##__VA_ARGS__); \
 } while (0)
 =

 void l_debug_enable_full(const char *pattern,
@@ -89,10 +89,10 @@ _Pragma("GCC diagnostic pop") \
 =

 void l_debug_disable(void);
 =

-#define l_error(format, args...)  l_log(L_LOG_ERR, format, ## args)
-#define l_warn(format, args...)   l_log(L_LOG_WARNING, format, ## args)
-#define l_info(format, args...)   l_log(L_LOG_INFO, format, ## args)
-#define l_debug(format, args...)  L_DEBUG_SYMBOL(__debug_desc, format, ## =
args)
+#define l_error(format, ...)  l_log(L_LOG_ERR, format, ##__VA_ARGS__)
+#define l_warn(format, ...)   l_log(L_LOG_WARNING, format, ##__VA_ARGS__)
+#define l_info(format, ...)   l_log(L_LOG_INFO, format, ##__VA_ARGS__)
+#define l_debug(format, ...)  L_DEBUG_SYMBOL(__debug_desc, format, ##__VA_=
ARGS__)
 =

 #ifdef __cplusplus
 }
-- =

2.19.2


--===============0456932156067457545==--

