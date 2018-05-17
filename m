Content-Type: multipart/mixed; boundary="===============5911942342278501482=="
MIME-Version: 1.0
From: John Zimmermann <johnz@posteo.net>
Subject: [PATCH 1/2] dhcp-transport: define _GNU_SOURCE
Date: Thu, 17 May 2018 23:56:37 +0200
Message-ID: <20180517215637.15765-1-johnz@posteo.net>
In-Reply-To: <89469edc-1e03-031b-bd5d-99347f3d8ad3@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5911942342278501482==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

the source, dest, len, check naming for the udphdr struct is not avaible
on non GLIBC libc's like MUSL without defining _GNU_SOURCE
---
 ell/dhcp-transport.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index a317431..1de190a 100644
--- a/ell/dhcp-transport.c
+++ b/ell/dhcp-transport.c
@@ -24,6 +24,7 @@
 #include <config.h>
 #endif
 =

+#define _GNU_SOURCE
 #include <linux/types.h>
 #include <sys/uio.h>
 #include <sys/socket.h>
-- =

2.17.0


--===============5911942342278501482==--

