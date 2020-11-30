Content-Type: multipart/mixed; boundary="===============6158646984420132598=="
MIME-Version: 1.0
From: =?unknown-8bit?q?=C3=89rico?= Nogueira <ericonr@disroot.org>
Subject: [PATCH v2] ell: add missing include in dhcp-server.
Date: Mon, 30 Nov 2020 18:40:33 -0300
Message-ID: <C7GXAHWOYET1.RX1LFTLT7WVC@mussels>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6158646984420132598==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This is v2 only because I'm attempting to send it again.

Hope it works!

 ell/dhcp-server.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index c983ed4..144e83e 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -24,6 +24,7 @@
 #include <config.h>
 #endif
 =

+#include <linux/types.h>
 #include <net/ethernet.h>
 #include <sys/socket.h>
 #include <arpa/inet.h>
-- =

2.29.2

--===============6158646984420132598==--

