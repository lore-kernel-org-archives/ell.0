Content-Type: multipart/mixed; boundary="===============5177293159612789998=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 3/3] main: Safely free watch_data structures
Date: Wed, 16 Mar 2016 11:47:52 -0700
Message-ID: <1458154072-14292-3-git-send-email-mathew.j.martineau@linux.intel.com>
In-Reply-To: <1458154072-14292-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5177293159612789998==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The race condition test in test-main exposed a case where the events
array returned by epoll_wait could have a stale watch_data
pointer. This triggered a use-after-free error that was reported by
the address sanitizer (./configure --enable-asan).

When the event loop is running, watch_remove now queues the watch_data
structure to be freed later. The watch_data callback is modified so
that a safe function is executed if the event loop attempts a callback
on a pending removed watch. Any queued watch_data structures are freed
at the end of each event loop iteration.
---
 ell/main.c | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/ell/main.c b/ell/main.c
index f8fa4ac..135a6da 100644
--- a/ell/main.c
+++ b/ell/main.c
@@ -56,6 +56,7 @@ static int idle_id;
 static int exit_status =3D EXIT_FAILURE;
 =

 static struct l_queue *idle_list;
+static struct l_queue *watch_free_list;
 =

 struct watch_data {
 	int fd;
@@ -101,6 +102,10 @@ static inline bool __attribute__ ((always_inline)) cre=
ate_epoll(void)
 =

 	idle_id =3D 0;
 =

+	watch_free_list =3D l_queue_new();
+	if (!watch_free_list)
+		goto free_idle_list;
+
 	watch_entries =3D DEFAULT_WATCH_ENTRIES;
 =

 	for (i =3D 0; i < watch_entries; i++)
@@ -108,6 +113,10 @@ static inline bool __attribute__ ((always_inline)) cre=
ate_epoll(void)
 =

 	return true;
 =

+free_idle_list:
+	l_queue_destroy(idle_list, NULL);
+	idle_list =3D NULL;
+
 free_watch_list:
 	free(watch_list);
 	watch_list =3D NULL;
@@ -190,6 +199,11 @@ int watch_modify(int fd, uint32_t events, bool force)
 	return 0;
 }
 =

+static void watch_nop_callback(int fd, uint32_t events, void *user_data)
+{
+	return;
+}
+
 int watch_remove(int fd)
 {
 	struct watch_data *data;
@@ -212,7 +226,15 @@ int watch_remove(int fd)
 	if (data->destroy)
 		data->destroy(data->user_data);
 =

-	l_free(data);
+	if (epoll_running) {
+		/* The epoll events array may point to the same memory as
+		 * 'data', so let the event loop free it later
+		 */
+		data->callback =3D watch_nop_callback;
+		l_queue_push_tail(watch_free_list, data);
+	} else {
+		l_free(data);
+	}
 =

 	return err;
 }
@@ -352,6 +374,7 @@ LIB_EXPORT int l_main_run(void)
 =

 		l_queue_foreach(idle_list, idle_dispatch, NULL);
 		l_queue_foreach_remove(idle_list, idle_prune, NULL);
+		l_queue_clear(watch_free_list, l_free);
 	}
 =

 	for (i =3D 0; i < watch_entries; i++) {
@@ -378,6 +401,9 @@ LIB_EXPORT int l_main_run(void)
 	l_queue_destroy(idle_list, idle_destroy);
 	idle_list =3D NULL;
 =

+	l_queue_destroy(watch_free_list, l_free);
+	watch_free_list =3D NULL;
+
 	epoll_running =3D false;
 =

 	close(epoll_fd);
-- =

2.7.3


--===============5177293159612789998==--

