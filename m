Content-Type: multipart/mixed; boundary="===============4826221347369165803=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/3] main: Manually initialize and clean up the main loop
Date: Tue, 07 Jun 2016 15:30:13 -0700
Message-ID: <20160607223015.26693-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4826221347369165803==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Automatic initialization and cleanup of the main loop created some
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
 ell/main.c                   | 81 +++++++++++++++++++++++++++-------------=
----
 ell/main.h                   |  4 ++-
 examples/dbus-client.c       |  5 +++
 examples/dbus-service.c      |  5 +++
 examples/https-client-test.c |  5 +++
 examples/https-server-test.c |  5 +++
 unit/test-dbus-message-fds.c |  5 +++
 unit/test-dbus-properties.c  |  5 +++
 unit/test-dbus.c             |  5 +++
 unit/test-genl.c             |  5 +++
 unit/test-io.c               |  5 +++
 unit/test-kdbus.c            |  5 +++
 unit/test-main.c             |  5 +++
 unit/test-netlink.c          |  5 +++
 14 files changed, 113 insertions(+), 32 deletions(-)

diff --git a/ell/main.c b/ell/main.c
index f53ed9e..b4c1582 100644
--- a/ell/main.c
+++ b/ell/main.c
@@ -86,9 +86,6 @@ static inline bool __attribute__ ((always_inline)) create=
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
@@ -127,7 +124,7 @@ int watch_add(int fd, uint32_t events, watch_event_cb_t=
 callback,
 	if (unlikely(fd < 0 || !callback))
 		return -EINVAL;
 =

-	if (!create_epoll())
+	if (!epoll_fd)
 		return -EIO;
 =

 	if ((unsigned int) fd > watch_entries - 1)
@@ -260,7 +257,7 @@ int idle_add(idle_event_cb_t callback, void *user_data,
 	if (unlikely(!callback))
 		return -EINVAL;
 =

-	if (!create_epoll())
+	if (!epoll_fd)
 		return -EIO;
 =

 	data =3D l_new(struct idle_data, 1);
@@ -313,25 +310,45 @@ static void idle_dispatch(void *data, void *user_data)
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
@@ -375,6 +392,26 @@ LIB_EXPORT int l_main_run(void)
 		l_queue_foreach_remove(idle_list, idle_prune, NULL);
 	}
 =

+	epoll_running =3D false;
+
+	return exit_status;
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

@@ -399,12 +436,10 @@ LIB_EXPORT int l_main_run(void)
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
@@ -472,19 +507,3 @@ int l_main_run_with_signal(l_main_signal_cb_t callback=
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
diff --git a/examples/dbus-client.c b/examples/dbus-client.c
index be640b7..507a4e8 100644
--- a/examples/dbus-client.c
+++ b/examples/dbus-client.c
@@ -78,6 +78,9 @@ int main(int argc, char *argv[])
 	sigset_t mask;
 	uint32_t watch_id;
 =

+	if (!l_main_init())
+		return -1;
+
 	sigemptyset(&mask);
 	sigaddset(&mask, SIGINT);
 	sigaddset(&mask, SIGTERM);
@@ -102,5 +105,7 @@ int main(int argc, char *argv[])
 	l_dbus_destroy(dbus);
 	l_signal_remove(signal);
 =

+	l_main_exit();
+
 	return 0;
 }
diff --git a/examples/dbus-service.c b/examples/dbus-service.c
index 51b7e4f..19b17a0 100644
--- a/examples/dbus-service.c
+++ b/examples/dbus-service.c
@@ -181,6 +181,9 @@ int main(int argc, char *argv[])
 	sigset_t mask;
 	struct test_data *test;
 =

+	if (!l_main_init())
+		return -1;
+
 	sigemptyset(&mask);
 	sigaddset(&mask, SIGINT);
 	sigaddset(&mask, SIGTERM);
@@ -233,5 +236,7 @@ cleanup:
 	l_dbus_destroy(dbus);
 	l_signal_remove(signal);
 =

+	l_main_exit();
+
 	return 0;
 }
diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index 3382970..04a3b37 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -159,6 +159,9 @@ int main(int argc, char *argv[])
 		return -1;
 	}
 =

+	if (!l_main_init())
+		return -1;
+
 	io =3D l_io_new(fd);
 	l_io_set_close_on_destroy(io, true);
 	l_io_set_read_handler(io, https_io_read, tls, NULL);
@@ -176,5 +179,7 @@ int main(int argc, char *argv[])
 	l_io_destroy(io);
 	l_tls_free(tls);
 =

+	l_main_exit();
+
 	return 0;
 }
diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index 22a9db1..0f16ed2 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -149,6 +149,9 @@ int main(int argc, char *argv[])
 		return -1;
 	}
 =

+	if (!l_main_init())
+		return -1;
+
 	io =3D l_io_new(fd);
 	l_io_set_close_on_destroy(io, true);
 	l_io_set_read_handler(io, https_io_read, tls, NULL);
@@ -164,5 +167,7 @@ int main(int argc, char *argv[])
 	l_io_destroy(io);
 	l_tls_free(tls);
 =

+	l_main_exit();
+
 	return 0;
 }
diff --git a/unit/test-dbus-message-fds.c b/unit/test-dbus-message-fds.c
index 7e710cf..c93f093 100644
--- a/unit/test-dbus-message-fds.c
+++ b/unit/test-dbus-message-fds.c
@@ -330,6 +330,9 @@ int main(int argc, char *argv[])
 	sigset_t mask;
 	int i;
 =

+	if (!l_main_init())
+		return -1;
+
 	test_add("FD passing 1", test_fd_passing_1, NULL);
 =

 	sigemptyset(&mask);
@@ -377,6 +380,8 @@ done:
 =

 	l_queue_destroy(tests, l_free);
 =

+	l_main_exit();
+
 	if (!success)
 		abort();
 =

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index 6eae592..b11d1d5 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -978,6 +978,9 @@ int main(int argc, char *argv[])
 	sigset_t mask;
 	int i;
 =

+	if (!l_main_init())
+		return -1;
+
 	test_add("Legacy properties get", test_old_get, NULL);
 	test_add("Legacy properties set", test_old_set, NULL);
 	test_add("Legacy optional property", test_old_optional_get, NULL);
@@ -1034,6 +1037,8 @@ done:
 =

 	l_queue_destroy(tests, l_free);
 =

+	l_main_exit();
+
 	if (!success)
 		abort();
 =

diff --git a/unit/test-dbus.c b/unit/test-dbus.c
index b01a530..0fed605 100644
--- a/unit/test-dbus.c
+++ b/unit/test-dbus.c
@@ -201,6 +201,9 @@ int main(int argc, char *argv[])
 	sigset_t mask;
 	int i;
 =

+	if (!l_main_init())
+		return -1;
+
 	sigemptyset(&mask);
 	sigaddset(&mask, SIGINT);
 	sigaddset(&mask, SIGTERM);
@@ -248,5 +251,7 @@ int main(int argc, char *argv[])
 =

 	l_signal_remove(signal);
 =

+	l_main_exit();
+
 	return 0;
 }
diff --git a/unit/test-genl.c b/unit/test-genl.c
index 1764133..d15d92c 100644
--- a/unit/test-genl.c
+++ b/unit/test-genl.c
@@ -44,6 +44,9 @@ int main(int argc, char *argv[])
 {
 	struct l_genl *genl;
 =

+	if (!l_main_init())
+		return -1;
+
 	l_log_set_stderr();
 =

 	genl =3D l_genl_new_default();
@@ -56,5 +59,7 @@ int main(int argc, char *argv[])
 =

 	l_genl_unref(genl);
 =

+	l_main_exit();
+
 	return 0;
 }
diff --git a/unit/test-io.c b/unit/test-io.c
index 24e1681..922ecad 100644
--- a/unit/test-io.c
+++ b/unit/test-io.c
@@ -75,6 +75,9 @@ int main(int argc, char *argv[])
 	struct l_io *io1, *io2;
 	int fd[2];
 =

+	if (!l_main_init())
+		return -1;
+
 	l_log_set_stderr();
 =

 	if (socketpair(PF_UNIX, SOCK_STREAM | SOCK_NONBLOCK, 0, fd) < 0) {
@@ -99,5 +102,7 @@ int main(int argc, char *argv[])
 	l_io_destroy(io2);
 	l_io_destroy(io1);
 =

+	l_main_exit();
+
 	return 0;
 }
diff --git a/unit/test-kdbus.c b/unit/test-kdbus.c
index 8cac761..ad4a754 100644
--- a/unit/test-kdbus.c
+++ b/unit/test-kdbus.c
@@ -136,6 +136,9 @@ int main(int argc, char *argv[])
 	struct l_signal *signal;
 	sigset_t mask;
 =

+	if (!l_main_init())
+		return -1;
+
 	sigemptyset(&mask);
 	sigaddset(&mask, SIGINT);
 	sigaddset(&mask, SIGTERM);
@@ -191,5 +194,7 @@ error:
 =

 	l_signal_remove(signal);
 =

+	l_main_exit();
+
 	return EXIT_SUCCESS;
 }
diff --git a/unit/test-main.c b/unit/test-main.c
index ee99a4b..1f4bb31 100644
--- a/unit/test-main.c
+++ b/unit/test-main.c
@@ -91,6 +91,9 @@ int main(int argc, char *argv[])
 	struct l_idle *idle;
 	sigset_t mask;
 =

+	if (!l_main_init())
+		return -1;
+
 	sigemptyset(&mask);
 	sigaddset(&mask, SIGINT);
 	sigaddset(&mask, SIGTERM);
@@ -129,5 +132,7 @@ int main(int argc, char *argv[])
 =

 	l_idle_remove(idle);
 =

+	l_main_exit();
+
 	return 0;
 }
diff --git a/unit/test-netlink.c b/unit/test-netlink.c
index a56e5a1..ce522a6 100644
--- a/unit/test-netlink.c
+++ b/unit/test-netlink.c
@@ -77,6 +77,9 @@ int main(int argc, char *argv[])
 	struct l_netlink *netlink;
 	struct ifinfomsg msg;
 =

+	if (!l_main_init())
+		return -1;
+
 	l_log_set_stderr();
 =

 	netlink =3D l_netlink_new(NETLINK_ROUTE);
@@ -92,5 +95,7 @@ int main(int argc, char *argv[])
 =

 	l_netlink_destroy(netlink);
 =

+	l_main_exit();
+
 	return 0;
 }
-- =

2.8.4


--===============4826221347369165803==--

