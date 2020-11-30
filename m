Content-Type: multipart/mixed; boundary="===============4783420780954232307=="
MIME-Version: 1.0
From: =?unknown-8bit?q?=C3=89rico?= Nogueira <ericonr@disroot.org>
Subject: [PATCH] ell: add missing include in dhcp-server.
Date: Mon, 30 Nov 2020 14:10:16 -0300
Message-ID: <20201130171016.22457-1-ericonr@disroot.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4783420780954232307==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: =C3=89rico Rolim <erico.erc@gmail.com>

---

I would prefer adding `#include <linux/types>` directly in
dhcp-private.h, but this patch follows the current style.

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

--===============4783420780954232307==--

