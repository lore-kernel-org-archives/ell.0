Content-Type: multipart/mixed; boundary="===============1343416749058547947=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dhcp: Fix address endianness in l2_send
Date: Fri, 04 Jun 2021 03:22:14 +0200
Message-ID: <20210604012214.162251-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1343416749058547947==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

dhcp_set_ip_udp_headers was unnecessarily trying to convert saddr and
daddr from host byte order to network order, the addresses are already
passsed in network byte order by the current 2 callers.  This wasn't
breaking normal dhcp but could break P2P where the DHCP OFFER and ACK
source address is used by the client:

DHCPOFFER of 192.168.1.2 from 1.1.168.192
---
 ell/dhcp-transport.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index c42bf45..68108e2 100644
--- a/ell/dhcp-transport.c
+++ b/ell/dhcp-transport.c
@@ -169,8 +169,8 @@ static void dhcp_set_ip_udp_headers(struct iphdr *ip, s=
truct udphdr *udp,
 	ip->tot_len =3D L_CPU_TO_BE16(len + sizeof(*ip) + sizeof(*udp));
 =

 	ip->protocol =3D IPPROTO_UDP;
-	ip->saddr =3D L_CPU_TO_BE32(saddr);
-	ip->daddr =3D L_CPU_TO_BE32(daddr);
+	ip->saddr =3D saddr;
+	ip->daddr =3D daddr;
 =

 	udp->source =3D L_CPU_TO_BE16(sport);
 	udp->dest =3D L_CPU_TO_BE16(dport);
-- =

2.30.2

--===============1343416749058547947==--

