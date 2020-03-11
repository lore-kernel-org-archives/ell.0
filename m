Content-Type: multipart/mixed; boundary="===============0658533749842110971=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH] rtnl: add 'power_up' flag to l_rtnl_set_mac
Date: Wed, 11 Mar 2020 18:51:54 -0400
Message-ID: <20200311225154.1322714-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0658533749842110971==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The use of l_rtnl_set_mac in IWD is always followed by powering up the
device. Bringing the device back up requires calling l_rtnl_set_powered
which makes another async call into the kernel. In order to reduce
complexity we can include the IFF_UP flag to the MAC change message which
will both change the MAC and bring the interface up all in one go.

The existing behavior is maintained by passing false to 'power_up'.
---
 ell/rtnl.c | 5 +++++
 ell/rtnl.h | 1 +
 2 files changed, 6 insertions(+)

diff --git a/ell/rtnl.c b/ell/rtnl.c
index 4600a7e..bf84cbd 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -167,6 +167,7 @@ uint32_t l_rtnl_set_linkmode_and_operstate(struct l_net=
link *rtnl, int ifindex,
 =

 uint32_t l_rtnl_set_mac(struct l_netlink *rtnl, int ifindex,
 					const uint8_t addr[static 6],
+					bool power_up,
 					l_netlink_command_func_t cb,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
@@ -183,6 +184,10 @@ uint32_t l_rtnl_set_mac(struct l_netlink *rtnl, int if=
index,
 =

 	rtmmsg->ifi_family =3D AF_UNSPEC;
 	rtmmsg->ifi_index =3D ifindex;
+	if (power_up) {
+		rtmmsg->ifi_change =3D IFF_UP;
+		rtmmsg->ifi_flags =3D IFF_UP;
+	}
 =

 	rta_buf =3D (void *) rtmmsg + NLMSG_ALIGN(sizeof(struct ifinfomsg));
 =

diff --git a/ell/rtnl.h b/ell/rtnl.h
index ea283c1..60b8db4 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -38,6 +38,7 @@ uint32_t l_rtnl_set_linkmode_and_operstate(struct l_netli=
nk *rtnl, int ifindex,
 =

 uint32_t l_rtnl_set_mac(struct l_netlink *rtnl, int ifindex,
 					const uint8_t addr[static 6],
+					bool power_up,
 					l_netlink_command_func_t cb,
 					void *user_data,
 					l_netlink_destroy_func_t destroy);
-- =

2.24.1

--===============0658533749842110971==--

