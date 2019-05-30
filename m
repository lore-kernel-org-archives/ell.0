Content-Type: multipart/mixed; boundary="===============7988822921952264303=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH] netlink: Relax sequence check for the group notifications
Date: Thu, 30 May 2019 13:20:48 -0700
Message-ID: <20190530202048.23766-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7988822921952264303==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Some of the RTNL groups such as RTNLGRP_IPV4_IFADDR set the
sequence number in the header of the broadcasted messages.
In order to be able to receive the such messages, we relax the
check and allow the broadcasted messages with non-zero sequence
numbers.
---
 ell/netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/netlink.c b/ell/netlink.c
index 3d291cf..33d0e5b 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -275,7 +275,7 @@ static bool can_read_data(struct l_io *io, void *user_d=
ata)
 =

 	for (nlmsg =3D iov.iov_base; NLMSG_OK(nlmsg, (uint32_t) len);
 					nlmsg =3D NLMSG_NEXT(nlmsg, len)) {
-		if (group > 0 && nlmsg->nlmsg_seq =3D=3D 0) {
+		if (group > 0) {
 			process_broadcast(netlink, group, nlmsg);
 			continue;
 		}
-- =

2.13.6


--===============7988822921952264303==--

