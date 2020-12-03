Content-Type: multipart/mixed; boundary="===============6277173863592521006=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 3/7] acd: add probe/annouce states, and announce address
Date: Thu, 03 Dec 2020 12:41:40 -0800
Message-ID: <20201203204144.480090-3-prestwoj@gmail.com>
In-Reply-To: <20201203204144.480090-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6277173863592521006==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Tracks state (probe/annouce) and will stop probing if an address
conflict is detected. Once all probes have been sent the state
transitions to announce. At this point the IP is safe to use.

Events are now signaled for conflicts and available IPs.

Going forward, the ANNOUNCED state will be the normal state the
ACD client is in while monitoring for conflicting packets.
---
 ell/acd.c | 84 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 80 insertions(+), 4 deletions(-)

diff --git a/ell/acd.c b/ell/acd.c
index f8f3df4..4528d76 100644
--- a/ell/acd.c
+++ b/ell/acd.c
@@ -43,6 +43,10 @@
 #define PROBE_MIN		1
 #define PROBE_MAX		2
 =

+#define ANNOUNCE_WAIT		2
+#define ANNOUNCE_NUM		2
+#define ANNOUNCE_INTERVAL	2
+
 #define MAC "%02x:%02x:%02x:%02x:%02x:%02x"
 #define MAC_STR(a) a[0], a[1], a[2], a[3], a[4], a[5]
 =

@@ -59,12 +63,19 @@
 	l_util_debug(acd->debug_handler, acd->debug_data,		\
 			"%s:%i " fmt, __func__, __LINE__, ## args)
 =

+enum acd_state {
+	ACD_STATE_PROBE,
+	ACD_STATE_ANNOUNCED,
+};
+
 struct l_acd {
 	int ifindex;
 =

 	uint32_t ip;
 	uint8_t mac[ETH_ALEN];
 =

+	enum acd_state state;
+
 	struct l_io *io;
 	struct l_timeout *timeout;
 	unsigned int retries;
@@ -152,6 +163,49 @@ static uint32_t acd_random_delay_ms(uint32_t max_sec)
 	return rand % (max_sec * 1000);
 }
 =

+static void announce_wait_timeout(struct l_timeout *timeout, void *user_da=
ta)
+{
+	struct l_acd *acd =3D user_data;
+
+	l_timeout_remove(acd->timeout);
+	acd->timeout =3D NULL;
+
+	if (acd->state =3D=3D ACD_STATE_PROBE) {
+		ACD_DEBUG("No conflicts found for %s, announcing address",
+				IP_STR(htonl(acd->ip)));
+
+		acd->state =3D ACD_STATE_ANNOUNCED;
+
+		/*
+		 * RFC 5227 - Section 2.3
+		 *
+		 * "The host may begin legitimately using the IP address
+		 *  immediately after sending the first of the two ARP
+		 *  Announcements"
+		 */
+
+		if (acd->event_func)
+			acd->event_func(L_ACD_EVENT_AVAILABLE, acd->user_data);
+	}
+
+	if (acd->retries !=3D ANNOUNCE_NUM) {
+		acd->retries++;
+
+		if (acd_send_packet(acd, acd->ip) < 0) {
+			ACD_DEBUG("Failed to send ACD announcement");
+			return;
+		}
+
+		acd->timeout =3D l_timeout_create(ANNOUNCE_INTERVAL,
+						announce_wait_timeout,
+						acd, NULL);
+
+		return;
+	}
+
+	ACD_DEBUG("Done announcing");
+}
+
 static void probe_wait_timeout(struct l_timeout *timeout, void *user_data)
 {
 	struct l_acd *acd =3D user_data;
@@ -181,9 +235,19 @@ static void probe_wait_timeout(struct l_timeout *timeo=
ut, void *user_data)
 		delay +=3D PROBE_MIN * 1000;
 		acd->timeout =3D l_timeout_create_ms(delay, probe_wait_timeout,
 							acd, NULL);
-	} else
+	} else {
+		/*
+		 * Wait for ANNOUNCE_WAIT seconds after probe period before
+		 * announcing address.
+		 */
 		ACD_DEBUG("Done probing");
 =

+		acd->retries =3D 1;
+
+		acd->timeout =3D l_timeout_create(ANNOUNCE_WAIT,
+							announce_wait_timeout,
+							acd, NULL);
+	}
 }
 =

 static bool acd_read_handler(struct l_io *io, void *user_data)
@@ -223,9 +287,20 @@ static bool acd_read_handler(struct l_io *io, void *us=
er_data)
 		return true;
 	}
 =

-	ACD_DEBUG("%s conflict detected for %s",
-			target_conflict ? "Target" : "Source",
-			IP_STR(ip));
+	switch (acd->state) {
+	case ACD_STATE_PROBE:
+		/* No reason to continue probing */
+		ACD_DEBUG("%s conflict detected for %s",
+				target_conflict ? "Target" : "Source",
+				IP_STR(ip));
+
+		if (acd->event_func)
+			acd->event_func(L_ACD_EVENT_CONFLICT, acd->user_data);
+
+		l_acd_stop(acd);
+	case ACD_STATE_ANNOUNCED:
+		break;
+	}
 =

 	return true;
 }
@@ -266,6 +341,7 @@ LIB_EXPORT bool l_acd_start(struct l_acd *acd, const ch=
ar *ip)
 	l_io_set_read_handler(acd->io, acd_read_handler, acd, NULL);
 =

 	acd->ip =3D ntohl(ia.s_addr);
+	acd->state =3D ACD_STATE_PROBE;
 =

 	delay =3D acd_random_delay_ms(PROBE_WAIT);
 =

-- =

2.26.2

--===============6277173863592521006==--

