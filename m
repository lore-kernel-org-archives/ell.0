Content-Type: multipart/mixed; boundary="===============0327150856227896630=="
MIME-Version: 1.0
From: Inga Stotland <inga.stotland@intel.com>
Subject: [PATCH 1/2] io: Always call read handler on EPOLLIN
Date: Sat, 17 Oct 2020 23:06:44 -0700
Message-ID: <20201018060645.37208-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0327150856227896630==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When detecting EPOLLIN, always invoke read handler first.
This ensures that even when error conditions (i.e., EPOLLHUP
and/or EPOLLERR) are encountered, any residual data is still
delivered to the client.
---
 ell/io.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/ell/io.c b/ell/io.c
index 41ff6dd..a9e0a38 100644
--- a/ell/io.c
+++ b/ell/io.c
@@ -111,14 +111,6 @@ static void io_callback(int fd, uint32_t events, void =
*user_data)
 {
 	struct l_io *io =3D user_data;
 =

-	if (unlikely(events & (EPOLLERR | EPOLLHUP))) {
-		l_util_debug(io->debug_handler, io->debug_data,
-						"disconnect event <%p>", io);
-		watch_remove(io->fd, !io->close_on_destroy);
-		io_closed(io);
-		return;
-	}
-
 	if ((events & EPOLLIN) && io->read_handler) {
 		l_util_debug(io->debug_handler, io->debug_data,
 						"read event <%p>", io);
@@ -142,6 +134,14 @@ static void io_callback(int fd, uint32_t events, void =
*user_data)
 		}
 	}
 =

+	if (unlikely(events & (EPOLLERR | EPOLLHUP))) {
+		l_util_debug(io->debug_handler, io->debug_data,
+						"disconnect event <%p>", io);
+		watch_remove(io->fd, !io->close_on_destroy);
+		io_closed(io);
+		return;
+	}
+
 	if ((events & EPOLLOUT) && io->write_handler) {
 		l_util_debug(io->debug_handler, io->debug_data,
 						"write event <%p>", io);
-- =

2.26.2

--===============0327150856227896630==--

