Content-Type: multipart/mixed; boundary="===============3358354447852167326=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v3 3/5] main: Safely free watch_data structures
Date: Thu, 17 Mar 2016 11:15:40 -0700
Message-ID: <1458238542-11711-3-git-send-email-mathew.j.martineau@linux.intel.com>
In-Reply-To: <1458238542-11711-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3358354447852167326==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The race condition test in test-main exposed a case where the events
array returned by epoll_wait could have a stale watch_data
pointer. This triggered a use-after-free error that was reported by
the address sanitizer (./configure --enable-asan).

When the event loop is running, watch_data structures with events
being dispatched are flagged. If watch_remove is called on a flagged
structure, the l_free() is deferred until after all events are
dispatched and the callback for that event is skipped.
---
 ell/main.c | 31 +++++++++++++++++++++++++++++--
 1 file changed, 29 insertions(+), 2 deletions(-)

diff --git a/ell/main.c b/ell/main.c
index f8fa4ac..6143a42 100644
--- a/ell/main.c
+++ b/ell/main.c
@@ -49,6 +49,9 @@
 #define IDLE_FLAG_DISPATCHING	1
 #define IDLE_FLAG_DESTROYED	2
 =

+#define WATCH_FLAG_DISPATCHING	1
+#define WATCH_FLAG_DESTROYED	2
+
 static int epoll_fd;
 static bool epoll_running;
 static bool epoll_terminate;
@@ -60,6 +63,7 @@ static struct l_queue *idle_list;
 struct watch_data {
 	int fd;
 	uint32_t events;
+	uint32_t flags;
 	watch_event_cb_t callback;
 	watch_destroy_cb_t destroy;
 	void *user_data;
@@ -139,6 +143,7 @@ int watch_add(int fd, uint32_t events, watch_event_cb_t=
 callback,
 =

 	data->fd =3D fd;
 	data->events =3D events;
+	data->flags =3D 0;
 	data->callback =3D callback;
 	data->destroy =3D destroy;
 	data->user_data =3D user_data;
@@ -212,7 +217,10 @@ int watch_remove(int fd)
 	if (data->destroy)
 		data->destroy(data->user_data);
 =

-	l_free(data);
+	if (data->flags & WATCH_FLAG_DISPATCHING)
+		data->flags |=3D WATCH_FLAG_DESTROYED;
+	else
+		l_free(data);
 =

 	return err;
 }
@@ -334,6 +342,7 @@ LIB_EXPORT int l_main_run(void)
 =

 	for (;;) {
 		struct epoll_event events[MAX_EPOLL_EVENTS];
+		struct watch_data *data;
 		int n, nfds;
 		int timeout;
 =

@@ -344,12 +353,30 @@ LIB_EXPORT int l_main_run(void)
 		nfds =3D epoll_wait(epoll_fd, events, MAX_EPOLL_EVENTS, timeout);
 =

 		for (n =3D 0; n < nfds; n++) {
-			struct watch_data *data =3D events[n].data.ptr;
+			data =3D events[n].data.ptr;
+
+			data->flags |=3D WATCH_FLAG_DISPATCHING;
+		}
+
+		for (n =3D 0; n < nfds; n++) {
+			data =3D events[n].data.ptr;
+
+			if (data->flags & WATCH_FLAG_DESTROYED)
+				continue;
 =

 			data->callback(data->fd, events[n].events,
 							data->user_data);
 		}
 =

+		for (n =3D 0; n < nfds; n++) {
+			data =3D events[n].data.ptr;
+
+			if (data->flags & WATCH_FLAG_DESTROYED)
+				l_free(data);
+			else
+				data->flags =3D 0;
+		}
+
 		l_queue_foreach(idle_list, idle_dispatch, NULL);
 		l_queue_foreach_remove(idle_list, idle_prune, NULL);
 	}
-- =

2.7.3


--===============3358354447852167326==--

