Content-Type: multipart/mixed; boundary="===============6999807378244318089=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 1/5] acd: store IP in network order
Date: Tue, 08 Dec 2020 10:42:24 -0800
Message-ID: <20201208184228.751111-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6999807378244318089==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The IP target was being converted into host order during
l_acd_start, which required converting back to network order
many times throughout the ACD process. Instead just leave
the IP in network order and use directly. This avoids the
need for conversions and additional temporary variables.
---
 ell/acd.c | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

diff --git a/ell/acd.c b/ell/acd.c
index ef72fef..7d912d9 100644
--- a/ell/acd.c
+++ b/ell/acd.c
@@ -125,8 +125,6 @@ static int acd_send_packet(struct l_acd *acd, uint32_t =
source_ip)
 {
 	struct sockaddr_ll dest;
 	struct ether_arp p;
-	uint32_t ip_source;
-	uint32_t ip_target;
 	int n;
 	int fd =3D l_io_get_fd(acd->io);
 =

@@ -138,19 +136,17 @@ static int acd_send_packet(struct l_acd *acd, uint32_=
t source_ip)
 	dest.sll_halen =3D ETH_ALEN;
 	memset(dest.sll_addr, 0xFF, ETH_ALEN);
 =

-	ip_source =3D htonl(source_ip);
-	ip_target =3D htonl(acd->ip);
 	p.arp_hrd =3D htons(ARPHRD_ETHER);
 	p.arp_pro =3D htons(ETHERTYPE_IP);
 	p.arp_hln =3D ETH_ALEN;
 	p.arp_pln =3D 4;
 	p.arp_op =3D htons(ARPOP_REQUEST);
 =

-	ACD_DEBUG("sending packet with target IP %s", IP_STR(ip_target));
+	ACD_DEBUG("sending packet with target IP %s", IP_STR(acd->ip));
 =

 	memcpy(&p.arp_sha, acd->mac, ETH_ALEN);
-	memcpy(&p.arp_spa, &ip_source, sizeof(p.arp_spa));
-	memcpy(&p.arp_tpa, &ip_target, sizeof(p.arp_tpa));
+	memcpy(&p.arp_spa, &source_ip, sizeof(p.arp_spa));
+	memcpy(&p.arp_tpa, &acd->ip, sizeof(p.arp_tpa));
 =

 	n =3D sendto(fd, &p, sizeof(p), 0,
 			(struct sockaddr*) &dest, sizeof(dest));
@@ -178,7 +174,7 @@ static void announce_wait_timeout(struct l_timeout *tim=
eout, void *user_data)
 =

 	if (acd->state =3D=3D ACD_STATE_PROBE) {
 		ACD_DEBUG("No conflicts found for %s, announcing address",
-				IP_STR(htonl(acd->ip)));
+				IP_STR(acd->ip));
 =

 		acd->state =3D ACD_STATE_ANNOUNCED;
 =

@@ -275,7 +271,6 @@ static bool acd_read_handler(struct l_io *io, void *use=
r_data)
 	int source_conflict;
 	int target_conflict;
 	bool probe;
-	uint32_t ip;
 =

 	memset(&arp, 0, sizeof(arp));
 	len =3D read(l_io_get_fd(acd->io), &arp, sizeof(arp));
@@ -292,15 +287,14 @@ static bool acd_read_handler(struct l_io *io, void *u=
ser_data)
 	if (memcmp(arp.arp_sha, acd->mac, ETH_ALEN) =3D=3D 0)
 		return true;
 =

-	ip =3D htonl(acd->ip);
-	source_conflict =3D !memcmp(arp.arp_spa, &ip, sizeof(uint32_t));
+	source_conflict =3D !memcmp(arp.arp_spa, &acd->ip, sizeof(uint32_t));
 	probe =3D l_memeqzero(arp.arp_spa, sizeof(uint32_t));
 	target_conflict =3D probe &&
-		!memcmp(arp.arp_tpa, &ip, sizeof(uint32_t));
+		!memcmp(arp.arp_tpa, &acd->ip, sizeof(uint32_t));
 =

 	if (!source_conflict && !target_conflict) {
 		ACD_DEBUG("No target or source conflict detected for %s",
-				IP_STR(ip));
+				IP_STR(acd->ip));
 		return true;
 	}
 =

@@ -309,7 +303,7 @@ static bool acd_read_handler(struct l_io *io, void *use=
r_data)
 		/* No reason to continue probing */
 		ACD_DEBUG("%s conflict detected for %s",
 				target_conflict ? "Target" : "Source",
-				IP_STR(ip));
+				IP_STR(acd->ip));
 =

 		if (acd->event_func)
 			acd->event_func(L_ACD_EVENT_CONFLICT, acd->user_data);
@@ -454,7 +448,7 @@ LIB_EXPORT bool l_acd_start(struct l_acd *acd, const ch=
ar *ip)
 	l_io_set_close_on_destroy(acd->io, true);
 	l_io_set_read_handler(acd->io, acd_read_handler, acd, NULL);
 =

-	acd->ip =3D ntohl(ia.s_addr);
+	acd->ip =3D ia.s_addr;
 =

 	/*
 	 * Optimization to allows skipping the probe stage. The RFC does not
-- =

2.26.2

--===============6999807378244318089==--

