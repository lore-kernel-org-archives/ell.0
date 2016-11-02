Content-Type: multipart/mixed; boundary="===============5489685733455414122=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 3/5] timeout: Add millisecond timeout functions,
 remove nanosecond functions
Date: Wed, 02 Nov 2016 14:50:46 -0700
Message-ID: <20161102215048.19166-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20161102215048.19166-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5489685733455414122==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Nanosecond resolution was overkill, but there are still common use cases
for millisecond timer resolution.
---
 ell/timeout.c | 109 +++++++++++++++++++++++++++++++++++++++++-------------=
----
 ell/timeout.h |   8 ++---
 2 files changed, 82 insertions(+), 35 deletions(-)

diff --git a/ell/timeout.c b/ell/timeout.c
index fc24d60..0935fd3 100644
--- a/ell/timeout.c
+++ b/ell/timeout.c
@@ -29,6 +29,7 @@
 #include <string.h>
 #include <sys/epoll.h>
 #include <sys/timerfd.h>
+#include <limits.h>
 =

 #include "util.h"
 #include "timeout.h"
@@ -91,31 +92,22 @@ static inline int timeout_set(int fd, unsigned int seco=
nds, long nanoseconds)
 	return timerfd_settime(fd, 0, &itimer, NULL);
 }
 =

-/**
- * l_timeout_create:
- * @seconds: timeout in seconds
- * @callback: timeout callback function
- * @user_data: user data provided to timeout callback function
- * @destroy: destroy function for user data
- *
- * Create new timeout callback handling.
- *
- * The timeout will on fire once. The timeout handling needs to be rearmed
- * with l_timeout_modify() to trigger again.
- *
- * Returns: a newly allocated #l_timeout object. On failure, the function
- * returns NULL.
- **/
-LIB_EXPORT struct l_timeout *l_timeout_create(unsigned int seconds,
-			l_timeout_notify_cb_t callback,
-			void *user_data, l_timeout_destroy_cb_t destroy)
+static bool convert_ms(unsigned long milliseconds, unsigned int *seconds,
+			long *nanoseconds)
 {
-	return l_timeout_create_with_nanoseconds(seconds, 0, callback,
-							user_data, destroy);
+	unsigned long big_seconds =3D milliseconds / 1000;
+
+	if (big_seconds > UINT_MAX)
+		return false;
+
+	*seconds =3D big_seconds;
+	*nanoseconds =3D (milliseconds % 1000) * 1000000L;
+
+	return true;
 }
 =

 /**
- * l_timeout_create_with_nanoseconds:
+ * timeout_create_with_nanoseconds:
  * @seconds: number of seconds
  * @nanoseconds: number of nanoseconds
  * @callback: timeout callback function
@@ -124,13 +116,13 @@ LIB_EXPORT struct l_timeout *l_timeout_create(unsigne=
d int seconds,
  *
  * Create new timeout callback handling.
  *
- * The timeout will on fire once. The timeout handling needs to be rearmed
- * with l_timeout_modify_with_nanoseconds() to trigger again.
+ * The timeout will only fire once. The timeout handling needs to be rearm=
ed
+ * with one of the l_timeout_modify functions to trigger again.
  *
  * Returns: a newly allocated #l_timeout object. On failure, the function
  * returns NULL.
  **/
-LIB_EXPORT struct l_timeout *l_timeout_create_with_nanoseconds(unsigned in=
t seconds,
+static struct l_timeout *timeout_create_with_nanoseconds(unsigned int seco=
nds,
 			long nanoseconds, l_timeout_notify_cb_t callback,
 			void *user_data, l_timeout_destroy_cb_t destroy)
 {
@@ -173,6 +165,58 @@ LIB_EXPORT struct l_timeout *l_timeout_create_with_nan=
oseconds(unsigned int seco
 }
 =

 /**
+ * l_timeout_create:
+ * @seconds: timeout in seconds
+ * @callback: timeout callback function
+ * @user_data: user data provided to timeout callback function
+ * @destroy: destroy function for user data
+ *
+ * Create new timeout callback handling.
+ *
+ * The timeout will only fire once. The timeout handling needs to be rearm=
ed
+ * with one of the l_timeout_modify functions to trigger again.
+ *
+ * Returns: a newly allocated #l_timeout object. On failure, the function
+ * returns NULL.
+ **/
+LIB_EXPORT struct l_timeout *l_timeout_create(unsigned int seconds,
+			l_timeout_notify_cb_t callback,
+			void *user_data, l_timeout_destroy_cb_t destroy)
+{
+	return timeout_create_with_nanoseconds(seconds, 0, callback,
+							user_data, destroy);
+}
+
+/**
+ * l_timeout_create_ms:
+ * @milliseconds: timeout in milliseconds
+ * @callback: timeout callback function
+ * @user_data: user data provided to timeout callback function
+ * @destroy: destroy function for user data
+ *
+ * Create new timeout callback handling.
+ *
+ * The timeout will only fire once. The timeout handling needs to be rearm=
ed
+ * with one of the l_timeout_modify functions to trigger again.
+ *
+ * Returns: a newly allocated #l_timeout object. On failure, the function
+ * returns NULL.
+ **/
+LIB_EXPORT struct l_timeout *l_timeout_create_ms(unsigned long millisecond=
s,
+			l_timeout_notify_cb_t callback,
+			void *user_data, l_timeout_destroy_cb_t destroy)
+{
+	unsigned int seconds;
+	long nanoseconds;
+
+	if (!convert_ms(milliseconds, &seconds, &nanoseconds))
+		return NULL;
+
+	return timeout_create_with_nanoseconds(seconds, nanoseconds, callback,
+						user_data, destroy);
+}
+
+/**
  * l_timeout_modify:
  * @timeout: timeout object
  * @seconds: timeout in seconds
@@ -197,15 +241,14 @@ LIB_EXPORT void l_timeout_modify(struct l_timeout *ti=
meout,
 }
 =

 /**
- * l_timeout_modify_with_nanoseconds:
+ * l_timeout_modify_ms:
  * @timeout: timeout object
- * @seconds: number of seconds
- * @nanoseconds: number of nanoseconds
+ * @milliseconds: number of milliseconds
  *
  * Modify an existing @timeout and rearm it.
  **/
-LIB_EXPORT void l_timeout_modify_with_nanoseconds(struct l_timeout *timeou=
t,
-					unsigned int seconds, long nanoseconds)
+LIB_EXPORT void l_timeout_modify_ms(struct l_timeout *timeout,
+					unsigned long milliseconds)
 {
 	if (unlikely(!timeout))
 		return;
@@ -213,8 +256,12 @@ LIB_EXPORT void l_timeout_modify_with_nanoseconds(stru=
ct l_timeout *timeout,
 	if (unlikely(timeout->fd < 0))
 		return;
 =

-	if (seconds > 0 || nanoseconds > 0) {
-		if (timeout_set(timeout->fd, seconds, nanoseconds) < 0)
+	if (milliseconds > 0) {
+		unsigned int sec;
+		long nanosec;
+
+		if (!convert_ms(milliseconds, &sec, &nanosec) ||
+			timeout_set(timeout->fd, sec, nanosec) < 0)
 			return;
 	}
 =

diff --git a/ell/timeout.h b/ell/timeout.h
index 882f166..288f0ca 100644
--- a/ell/timeout.h
+++ b/ell/timeout.h
@@ -36,13 +36,13 @@ typedef void (*l_timeout_destroy_cb_t) (void *user_data=
);
 struct l_timeout *l_timeout_create(unsigned int seconds,
 			l_timeout_notify_cb_t callback,
 			void *user_data, l_timeout_destroy_cb_t destroy);
-struct l_timeout *l_timeout_create_with_nanoseconds(unsigned int seconds,
-			long nanoseconds, l_timeout_notify_cb_t callback,
+struct l_timeout *l_timeout_create_ms(unsigned long milliseconds,
+			l_timeout_notify_cb_t callback,
 			void *user_data, l_timeout_destroy_cb_t destroy);
 void l_timeout_modify(struct l_timeout *timeout,
 				unsigned int seconds);
-void l_timeout_modify_with_nanoseconds(struct l_timeout *timeout,
-				unsigned int seconds, long nanoseconds);
+void l_timeout_modify_ms(struct l_timeout *timeout,
+				unsigned long milliseconds);
 void l_timeout_remove(struct l_timeout *timeout);
 =

 #ifdef __cplusplus
-- =

2.10.2


--===============5489685733455414122==--

