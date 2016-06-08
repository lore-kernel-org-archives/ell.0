Content-Type: multipart/mixed; boundary="===============2698205896198516096=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 2/3] examples: Update for new main loop init/exit functions
Date: Wed, 08 Jun 2016 14:55:37 -0700
Message-ID: <20160608215538.5590-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160608215538.5590-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2698205896198516096==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/dbus-client.c       | 5 +++++
 examples/dbus-service.c      | 5 +++++
 examples/https-client-test.c | 5 +++++
 examples/https-server-test.c | 5 +++++
 4 files changed, 20 insertions(+)

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
-- =

2.8.4


--===============2698205896198516096==--

