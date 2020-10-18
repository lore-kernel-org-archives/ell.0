Content-Type: multipart/mixed; boundary="===============5077701743345824189=="
MIME-Version: 1.0
From: Inga Stotland <inga.stotland@intel.com>
Subject: [PATCH 2/2] io: Call disconnect handler before removing the watch
Date: Sat, 17 Oct 2020 23:06:45 -0700
Message-ID: <20201018060645.37208-2-inga.stotland@intel.com>
In-Reply-To: <20201018060645.37208-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5077701743345824189==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When encountering EPOLLERR or EPOLLHUP conditions, first invoke
disconnect handler if it is set, and only then clear/remove the watch.

This allows the client to retrieve the actual code for the socket
error via getsockopt(). Otherwise, if the socket is closed prior
to calling the disconnect handler, the error code is lost.
---
 ell/io.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/ell/io.c b/ell/io.c
index a9e0a38..4337acb 100644
--- a/ell/io.c
+++ b/ell/io.c
@@ -135,10 +135,13 @@ static void io_callback(int fd, uint32_t events, void=
 *user_data)
 	}
 =

 	if (unlikely(events & (EPOLLERR | EPOLLHUP))) {
+		bool close_on_destroy =3D io->close_on_destroy;
+		int fd =3D io->fd;
+
 		l_util_debug(io->debug_handler, io->debug_data,
 						"disconnect event <%p>", io);
-		watch_remove(io->fd, !io->close_on_destroy);
 		io_closed(io);
+		watch_remove(fd, !close_on_destroy);
 		return;
 	}
 =

-- =

2.26.2

--===============5077701743345824189==--

