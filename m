Content-Type: multipart/mixed; boundary="===============6707303351646389096=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] fswatch: Notify about L_FSWATCH_EVENT_ATTRIB events
Date: Thu, 09 Aug 2018 16:28:51 +0200
Message-ID: <20180809142852.17764-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6707303351646389096==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Also emit events on file attribute changes, this was actually my
original intent but I must have missed this bit in the bitmask.
---
 ell/fswatch.c | 7 ++++++-
 ell/fswatch.h | 1 +
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/ell/fswatch.c b/ell/fswatch.c
index c5980d3..f7719b3 100644
--- a/ell/fswatch.c
+++ b/ell/fswatch.c
@@ -48,7 +48,8 @@ struct l_fswatch {
 };
 =

 #define EVENT_MASK	(IN_CREATE | IN_DELETE | IN_DELETE_SELF | \
-				IN_MODIFY | IN_MOVE | IN_MOVE_SELF)
+				IN_MODIFY | IN_MOVE | IN_MOVE_SELF | \
+				IN_ATTRIB)
 =

 static void l_fswatch_free(void *data)
 {
@@ -125,6 +126,10 @@ static bool inotify_read_cb(struct l_io *io, void *use=
r_data)
 				watch->cb(watch, name, L_FSWATCH_EVENT_DELETE,
 						watch->user_data);
 =

+			if ((event->mask & IN_ATTRIB) && watch->cb)
+				watch->cb(watch, name, L_FSWATCH_EVENT_ATTRIB,
+						watch->user_data);
+
 			if (event->mask & IN_IGNORED) {
 				stale_items =3D true;
 				watch->cb =3D NULL;
diff --git a/ell/fswatch.h b/ell/fswatch.h
index 419df09..425dc3e 100644
--- a/ell/fswatch.h
+++ b/ell/fswatch.h
@@ -30,6 +30,7 @@ enum l_fswatch_event {
 	L_FSWATCH_EVENT_MOVE,
 	L_FSWATCH_EVENT_MODIFY,
 	L_FSWATCH_EVENT_DELETE,
+	L_FSWATCH_EVENT_ATTRIB,
 };
 =

 typedef void (*l_fswatch_cb_t) (struct l_fswatch *watch, const char *filen=
ame,
-- =

2.14.1


--===============6707303351646389096==--

