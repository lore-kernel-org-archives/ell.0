Content-Type: multipart/mixed; boundary="===============7915231154002688888=="
MIME-Version: 1.0
From: John Zimmermann <johnz@posteo.net>
Subject: Re: [PATCH 1/2] dhcp-transport: define _GNU_SOURCE
Date: Thu, 17 May 2018 17:50:46 +0200
Message-ID: <2f39121366cbd4eb5fc354c08af99357df4fe8cc.camel@posteo.net>
In-Reply-To: <a8719c91-ab9a-eb35-c3c0-1882fe8390da@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7915231154002688888==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 2018-05-17 at 10:34 -0500, Denis Kenzior wrote:
> Hi John,
> =

> On 05/17/2018 06:08 AM, John wrote:
> > the source, dest, len, check naming for the udphdr struct is not
> > avaible
> > on non GLIBC libc's like MUSL without defining _GNU_SOURCE
> > ---
> >   ell/dhcp-transport.c | 1 +
> >   1 file changed, 1 insertion(+)
> > =

> =

> These look fine, but could you add some form of last name to your
> author =

> info? We use a simplified form of Linux Kernel patch submission =

> guidelines but still require a full name for acceptance.
> =

> Regards,
> -Denis

Yep can do that.

From 150e93547b14b13db187dd4b3beb13e238405b85 Mon Sep 17 00:00:00 2001
From: John Zimmermann <johnz@posteo.net>
Date: Thu, 17 May 2018 12:59:56 +0200
Subject: [PATCH 1/2] dhcp-transport: define _GNU_SOURCE

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


--===============7915231154002688888==--

