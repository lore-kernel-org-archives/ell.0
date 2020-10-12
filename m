Content-Type: multipart/mixed; boundary="===============6038556015563594711=="
MIME-Version: 1.0
From: Inga Stotland <inga.stotland@intel.com>
Subject: [PATCH 1/2] io: Do not call disconnect handler in destroyer
Date: Mon, 12 Oct 2020 15:13:53 -0700
Message-ID: <20201012221354.242562-2-inga.stotland@intel.com>
In-Reply-To: <20201012221354.242562-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6038556015563594711==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When a client is calling l_io_destroy() there is no need to inform
that same client that io has been disconnected.

Removing the disconnect callback from l_io_destroy() eliminates the
need to zero out and preserve disconnect handler data when invoking
disconnect handler in io_closed().

Also, rename static function io_closed() to io_disconnected() to
reflect the actual functionality.
---
 ell/io.c | 32 +++++++++-----------------------
 1 file changed, 9 insertions(+), 23 deletions(-)

diff --git a/ell/io.c b/ell/io.c
index 41ff6dd..1fa5f0b 100644
--- a/ell/io.c
+++ b/ell/io.c
@@ -86,25 +86,13 @@ static void io_cleanup(void *user_data)
 	io->fd =3D -1;
 }
 =

-static void io_closed(struct l_io *io)
+static void io_disconnected(struct l_io *io)
 {
-	/*
-	 * Save off copies of disconnect_handler, disconnect_destroy
-	 * and disconnect_data in case the handler calls io_destroy
-	 */
-	l_io_disconnect_cb_t handler =3D io->disconnect_handler;
-	l_io_destroy_cb_t destroy =3D io->disconnect_destroy;
-	void *disconnect_data =3D io->disconnect_data;
-
-	io->disconnect_handler =3D NULL;
-	io->disconnect_destroy =3D NULL;
-	io->disconnect_data =3D NULL;
-
-	if (handler)
-		handler(io, disconnect_data);
-
-	if (destroy)
-		destroy(disconnect_data);
+	if (io->disconnect_handler)
+		io->disconnect_handler(io, io->disconnect_data);
+
+	if (io->disconnect_destroy)
+		io->disconnect_destroy(io->disconnect_data);
 }
 =

 static void io_callback(int fd, uint32_t events, void *user_data)
@@ -115,7 +103,7 @@ static void io_callback(int fd, uint32_t events, void *=
user_data)
 		l_util_debug(io->debug_handler, io->debug_data,
 						"disconnect event <%p>", io);
 		watch_remove(io->fd, !io->close_on_destroy);
-		io_closed(io);
+		io_disconnected(io);
 		return;
 	}
 =

@@ -136,7 +124,7 @@ static void io_callback(int fd, uint32_t events, void *=
user_data)
 			if (watch_modify(io->fd, io->events, false) =3D=3D -EBADF) {
 				io->close_on_destroy =3D false;
 				watch_clear(io->fd);
-				io_closed(io);
+				io_disconnected(io);
 				return;
 			}
 		}
@@ -159,7 +147,7 @@ static void io_callback(int fd, uint32_t events, void *=
user_data)
 			if (watch_modify(io->fd, io->events, false) =3D=3D -EBADF) {
 				io->close_on_destroy =3D false;
 				watch_clear(io->fd);
-				io_closed(io);
+				io_disconnected(io);
 				return;
 			}
 		}
@@ -211,8 +199,6 @@ LIB_EXPORT void l_io_destroy(struct l_io *io)
 	if (io->fd !=3D -1)
 		watch_remove(io->fd, !io->close_on_destroy);
 =

-	io_closed(io);
-
 	if (io->debug_destroy)
 		io->debug_destroy(io->debug_data);
 =

-- =

2.26.2

--===============6038556015563594711==--

