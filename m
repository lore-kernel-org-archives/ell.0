Content-Type: multipart/mixed; boundary="===============6978801684266720450=="
MIME-Version: 1.0
From: Patrik Flykt <patrik.flykt@linux.intel.com>
Subject: [PATCH] netlink: Automatically request ACKs when a callback function
 is given
Date: Wed, 27 Aug 2014 13:49:10 +0300
Message-ID: <1409136550-7780-1-git-send-email-patrik.flykt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6978801684266720450==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Supplying a callback function without setting NLM_F_ACK results in no
ACKs to be sent by the kernel and thus the callback will never be called.
---
 ell/netlink.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ell/netlink.c b/ell/netlink.c
index f2d1baf..d247173 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -399,6 +399,9 @@ LIB_EXPORT unsigned int l_netlink_send(struct l_netlink=
 *netlink,
 	if (flags & 0xff)
 		return 0;
 =

+	if (function)
+		flags |=3D NLM_F_ACK;
+
 	size =3D NLMSG_ALIGN(sizeof(struct command)) +
 					NLMSG_HDRLEN + NLMSG_ALIGN(len);
 =

-- =

1.9.1


--===============6978801684266720450==--

