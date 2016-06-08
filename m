Content-Type: multipart/mixed; boundary="===============6993806655758642415=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 1/3] main: Manually initialize and clean up the main loop
Date: Wed, 08 Jun 2016 14:55:36 -0700
Message-ID: <20160608215538.5590-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6993806655758642415==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Atomatic initialization and cleanup of the main loop created some
issues with orderly shutdown of an ELL program. If cleanup functions
were called after the l_main_run() returned, they could indirectly set
up the epoll file descriptor and associated resources again. Those
resources were not freed after the cleanup functions ran.

Now, epoll resources are set up by l_main_init() and cleaned up by
l_main_exit(). If cleanup functions set up any idles or watches
(including watch-based timeouts, signals, or ios) after l_main_run()
returns, those will be destroyed by l_main_exit().

l_main_init() must be called before l_main_run() or any other ELL
function that expects epoll to be set up. l_main_exit() should be
called after l_main_run() returns to ensure that all resources are
freed.
---
 ell/main.c | 87 ++++++++++++++++++++++++++++++++++++++--------------------=
----
 ell/main.h |  4 ++-
 2 files changed, 57 insertions(+), 34 deletions(-)

diff --git a/ell/main.c b/ell/main.c
index f53ed9e..882690c 100644
--- a/ell/main.c
+++ b/ell/main.c
@@ -56,7 +56,6 @@ static int epoll_fd;
 static bool epoll_running;
 static bool epoll_terminate;
 static int idle_id;
-static int exit_status =3D EXIT_FAILURE;
 =

 static struct l_queue *idle_list;
 =

@@ -86,9 +85,6 @@ static inline bool __attribute__ ((always_inline)) create=
_epoll(void)
 {
 	unsigned int i;
 =

-	if (likely(epoll_fd))
-		return true;
-
 	epoll_fd =3D epoll_create1(EPOLL_CLOEXEC);
 	if (epoll_fd < 0) {
 		epoll_fd =3D 0;
@@ -127,7 +123,7 @@ int watch_add(int fd, uint32_t events, watch_event_cb_t=
 callback,
 	if (unlikely(fd < 0 || !callback))
 		return -EINVAL;
 =

-	if (!create_epoll())
+	if (!epoll_fd)
 		return -EIO;
 =

 	if ((unsigned int) fd > watch_entries - 1)
@@ -260,7 +256,7 @@ int idle_add(idle_event_cb_t callback, void *user_data,
 	if (unlikely(!callback))
 		return -EINVAL;
 =

-	if (!create_epoll())
+	if (!epoll_fd)
 		return -EIO;
 =

 	data =3D l_new(struct idle_data, 1);
@@ -313,25 +309,49 @@ static void idle_dispatch(void *data, void *user_data)
 }
 =

 /**
+ * l_main_init:
+ *
+ * Initialize the main loop. This must be called before l_main_run()
+ * and any other function that directly or indirectly sets up an idle
+ * or watch. A safe rule-of-thumb is to call it before any function
+ * prefixed with "l_".
+ *
+ * Returns: true if initialization was successful, false otherwise.
+ **/
+LIB_EXPORT bool l_main_init(void)
+{
+	if (unlikely(epoll_running))
+		return false;
+
+	if (!create_epoll())
+		return false;
+
+	epoll_terminate =3D false;
+
+	return true;
+}
+
+/**
  * l_main_run:
  *
  * Run the main loop
  *
- * Returns: #EXIT_SCUCESS after successful execution or #EXIT_FAILURE in
+ * The loop may be restarted by invoking this function after a
+ * previous invocation returns, provided that l_main_exit() has not
+ * been called first.
+ *
+ * Returns: #EXIT_SUCCESS after successful execution or #EXIT_FAILURE in
  *          case of failure
  **/
 LIB_EXPORT int l_main_run(void)
 {
-	unsigned int i;
-
-	if (unlikely(epoll_running))
+	/* Has l_main_init() been called? */
+	if (unlikely(!epoll_fd))
 		return EXIT_FAILURE;
 =

-	if (!create_epoll())
+	if (unlikely(epoll_running))
 		return EXIT_FAILURE;
 =

-	epoll_terminate =3D false;
-
 	epoll_running =3D true;
 =

 	for (;;) {
@@ -375,6 +395,26 @@ LIB_EXPORT int l_main_run(void)
 		l_queue_foreach_remove(idle_list, idle_prune, NULL);
 	}
 =

+	epoll_running =3D false;
+
+	return EXIT_SUCCESS;
+}
+
+/**
+ * l_main_exit:
+ *
+ * Clean up after main loop completes.
+ *
+ **/
+LIB_EXPORT bool l_main_exit(void)
+{
+	unsigned int i;
+
+	if (epoll_running) {
+		l_error("Cleanup attempted on running main loop");
+		return false;
+	}
+
 	for (i =3D 0; i < watch_entries; i++) {
 		struct watch_data *data =3D watch_list[i];
 =

@@ -399,12 +439,10 @@ LIB_EXPORT int l_main_run(void)
 	l_queue_destroy(idle_list, idle_destroy);
 	idle_list =3D NULL;
 =

-	epoll_running =3D false;
-
 	close(epoll_fd);
 	epoll_fd =3D 0;
 =

-	return exit_status;
+	return true;
 }
 =

 /**
@@ -419,7 +457,6 @@ LIB_EXPORT bool l_main_quit(void)
 	if (unlikely(!epoll_running))
 		return false;
 =

-	exit_status =3D EXIT_SUCCESS;
 	epoll_terminate =3D true;
 =

 	return true;
@@ -472,19 +509,3 @@ int l_main_run_with_signal(l_main_signal_cb_t callback=
, void *user_data)
 =

 	return result;
 }
-
-/**
- * l_main_exit:
- *
- * Teminate the running main loop with exit status
- *
- **/
-LIB_EXPORT
-void l_main_exit(int status)
-{
-	if (unlikely(!epoll_running))
-		return;
-
-	exit_status =3D status;
-	epoll_terminate =3D true;
-}
diff --git a/ell/main.h b/ell/main.h
index 46d2a13..c23ec55 100644
--- a/ell/main.h
+++ b/ell/main.h
@@ -29,13 +29,15 @@
 extern "C" {
 #endif
 =

+bool l_main_init(void);
 int l_main_run(void);
+bool l_main_exit(void);
+
 bool l_main_quit(void);
 =

 typedef void (*l_main_signal_cb_t) (uint32_t signo, void *user_data);
 =

 int l_main_run_with_signal(l_main_signal_cb_t callback, void *user_data);
-void l_main_exit(int status);
 =

 #ifdef __cplusplus
 }
-- =

2.8.4


--===============6993806655758642415==--

