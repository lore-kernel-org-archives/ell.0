Content-Type: multipart/mixed; boundary="===============3788883312817568098=="
MIME-Version: 1.0
From: Inga Stotland <inga.stotland@intel.com>
Subject: [PATCH 2/2] io: Allow socket error to be retrieved on disconnect
Date: Mon, 12 Oct 2020 15:13:54 -0700
Message-ID: <20201012221354.242562-3-inga.stotland@intel.com>
In-Reply-To: <20201012221354.242562-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3788883312817568098==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When encountering an error condition, first invoke disconnect handler
if it is set, and only then clear/remove the watch.

This allows the client to retrieve the the actual code for the socket
error (via getsockopt()). Otherwise, if the socket is closed
prior to invoking disconnect handler, the error code is lost.
---
 ell/io.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/ell/io.c b/ell/io.c
index 1fa5f0b..169dfb2 100644
--- a/ell/io.c
+++ b/ell/io.c
@@ -102,8 +102,9 @@ static void io_callback(int fd, uint32_t events, void *=
user_data)
 	if (unlikely(events & (EPOLLERR | EPOLLHUP))) {
 		l_util_debug(io->debug_handler, io->debug_data,
 						"disconnect event <%p>", io);
-		watch_remove(io->fd, !io->close_on_destroy);
+
 		io_disconnected(io);
+		watch_remove(io->fd, !io->close_on_destroy);
 		return;
 	}
 =

@@ -123,8 +124,8 @@ static void io_callback(int fd, uint32_t events, void *=
user_data)
 =

 			if (watch_modify(io->fd, io->events, false) =3D=3D -EBADF) {
 				io->close_on_destroy =3D false;
-				watch_clear(io->fd);
 				io_disconnected(io);
+				watch_clear(io->fd);
 				return;
 			}
 		}
@@ -146,8 +147,8 @@ static void io_callback(int fd, uint32_t events, void *=
user_data)
 =

 			if (watch_modify(io->fd, io->events, false) =3D=3D -EBADF) {
 				io->close_on_destroy =3D false;
-				watch_clear(io->fd);
 				io_disconnected(io);
+				watch_clear(io->fd);
 				return;
 			}
 		}
-- =

2.26.2

--===============3788883312817568098==--

