Content-Type: multipart/mixed; boundary="===============7121957065612283764=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 3/3] unit: Update for new main loop init/exit functions
Date: Wed, 08 Jun 2016 14:55:38 -0700
Message-ID: <20160608215538.5590-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160608215538.5590-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7121957065612283764==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-message-fds.c | 5 +++++
 unit/test-dbus-properties.c  | 5 +++++
 unit/test-dbus.c             | 5 +++++
 unit/test-genl.c             | 5 +++++
 unit/test-io.c               | 5 +++++
 unit/test-kdbus.c            | 5 +++++
 unit/test-main.c             | 5 +++++
 unit/test-netlink.c          | 5 +++++
 8 files changed, 40 insertions(+)

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


--===============7121957065612283764==--

