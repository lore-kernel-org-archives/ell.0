Content-Type: multipart/mixed; boundary="===============4885070028060096179=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/3] unit: Add race condition test to test-main
Date: Wed, 16 Mar 2016 11:47:51 -0700
Message-ID: <1458154072-14292-2-git-send-email-mathew.j.martineau@linux.intel.com>
In-Reply-To: <1458154072-14292-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4885070028060096179==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This test excercises the case where multiple events are returned from
the same epoll_wait call and an early event deletes a watch that is
waiting to be processed in the same event loop iteration.
---
 unit/test-main.c | 35 +++++++++++++++++++++++++++++++----
 1 file changed, 31 insertions(+), 4 deletions(-)

diff --git a/unit/test-main.c b/unit/test-main.c
index b61e337..3ee78f5 100644
--- a/unit/test-main.c
+++ b/unit/test-main.c
@@ -25,6 +25,7 @@
 #endif
 =

 #include <ell/ell.h>
+#include <unistd.h>
 =

 static void signal_handler(struct l_signal *signal, uint32_t signo,
 							void *user_data)
@@ -38,7 +39,7 @@ static void signal_handler(struct l_signal *signal, uint3=
2_t signo,
 	}
 }
 =

-static void timeout_handler(struct l_timeout *timeout, void *user_data)
+static void timeout_quit_handler(struct l_timeout *timeout, void *user_dat=
a)
 {
 	l_main_quit();
 }
@@ -58,9 +59,25 @@ static void oneshot_handler(void *user_data)
 	l_info("One-shot");
 }
 =

+static void race_delay_handler(struct l_timeout *timeout, void *user_data)
+{
+        usleep(250 * 1000);
+}
+
+static void race_handler(struct l_timeout *timeout, void *user_data)
+{
+	struct l_timeout **other_racer =3D user_data;
+
+	l_timeout_remove(*other_racer);
+	*other_racer =3D NULL;
+}
+
 int main(int argc, char *argv[])
 {
-	struct l_timeout *timeout;
+	struct l_timeout *timeout_quit;
+	struct l_timeout *race_delay;
+	struct l_timeout *race1;
+	struct l_timeout *race2;
 	struct l_signal *signal;
 	struct l_idle *idle;
 	sigset_t mask;
@@ -71,7 +88,13 @@ int main(int argc, char *argv[])
 =

 	signal =3D l_signal_create(&mask, signal_handler, NULL, NULL);
 =

-	timeout =3D l_timeout_create(3, timeout_handler, NULL, NULL);
+	timeout_quit =3D l_timeout_create(3, timeout_quit_handler, NULL, NULL);
+
+	race_delay =3D l_timeout_create(1, race_delay_handler, NULL, NULL);
+	race1 =3D l_timeout_create_with_nanoseconds(1, 100000000, race_handler,
+						  &race2, NULL);
+	race2 =3D l_timeout_create_with_nanoseconds(1, 100000000, race_handler,
+						  &race1, NULL);
 =

 	idle =3D l_idle_create(idle_handler, NULL, NULL);
 =

@@ -85,7 +108,11 @@ int main(int argc, char *argv[])
 =

 	l_main_run();
 =

-	l_timeout_remove(timeout);
+	l_timeout_remove(race_delay);
+	l_timeout_remove(race1);
+	l_timeout_remove(race2);
+
+	l_timeout_remove(timeout_quit);
 =

 	l_signal_remove(signal);
 =

-- =

2.7.3


--===============4885070028060096179==--

