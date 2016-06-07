Content-Type: multipart/mixed; boundary="===============3404104869629837578=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/3] signal: Propagate watch_add errors in l_signal_create
Date: Tue, 07 Jun 2016 15:30:14 -0700
Message-ID: <20160607223015.26693-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160607223015.26693-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3404104869629837578==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_signal_create now fails cleanly and returns NULL if watch_add fails.
---
 ell/signal.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/ell/signal.c b/ell/signal.c
index 863129f..fe4da55 100644
--- a/ell/signal.c
+++ b/ell/signal.c
@@ -155,6 +155,7 @@ LIB_EXPORT struct l_signal *l_signal_create(const sigse=
t_t *mask,
 			void *user_data, l_signal_destroy_cb_t destroy)
 {
 	struct l_signal *signal;
+	int err;
 =

 	if (unlikely(!mask || !callback))
 		return NULL;
@@ -172,16 +173,21 @@ LIB_EXPORT struct l_signal *l_signal_create(const sig=
set_t *mask,
 	}
 =

 	signal->fd =3D signalfd(-1, mask, SFD_NONBLOCK | SFD_CLOEXEC);
-	if (signal->fd < 0) {
-		masked_signals_del(mask);
-		l_free(signal);
-		return NULL;
-	}
+	if (signal->fd < 0)
+		goto error;
 =

-	watch_add(signal->fd, EPOLLIN, signal_callback,
-					signal, signal_destroy);
+	err =3D watch_add(signal->fd, EPOLLIN, signal_callback,
+			signal, signal_destroy);
+
+	if (err < 0)
+		goto error;
 =

 	return signal;
+
+error:
+	masked_signals_del(mask);
+	l_free(signal);
+	return NULL;
 }
 =

 /**
-- =

2.8.4


--===============3404104869629837578==--

