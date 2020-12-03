Content-Type: multipart/mixed; boundary="===============3347548609411817575=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 4/7] acd: add address defence and address lost events
Date: Thu, 03 Dec 2020 12:41:41 -0800
Message-ID: <20201203204144.480090-4-prestwoj@gmail.com>
In-Reply-To: <20201203204144.480090-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3347548609411817575==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/acd.c | 68 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/acd.h |  1 +
 2 files changed, 69 insertions(+)

diff --git a/ell/acd.c b/ell/acd.c
index 4528d76..8fa8d95 100644
--- a/ell/acd.c
+++ b/ell/acd.c
@@ -47,6 +47,8 @@
 #define ANNOUNCE_NUM		2
 #define ANNOUNCE_INTERVAL	2
 =

+#define DEFEND_INTERVAL		10
+
 #define MAC "%02x:%02x:%02x:%02x:%02x:%02x"
 #define MAC_STR(a) a[0], a[1], a[2], a[3], a[4], a[5]
 =

@@ -66,6 +68,7 @@
 enum acd_state {
 	ACD_STATE_PROBE,
 	ACD_STATE_ANNOUNCED,
+	ACD_STATE_DEFEND,
 };
 =

 struct l_acd {
@@ -250,6 +253,17 @@ static void probe_wait_timeout(struct l_timeout *timeo=
ut, void *user_data)
 	}
 }
 =

+static void defend_wait_timeout(struct l_timeout *timeout, void *user_data)
+{
+	struct l_acd *acd =3D user_data;
+
+	l_timeout_remove(acd->timeout);
+	acd->timeout =3D NULL;
+
+	/* Successfully defended address */
+	acd->state =3D ACD_STATE_ANNOUNCED;
+}
+
 static bool acd_read_handler(struct l_io *io, void *user_data)
 {
 	struct l_acd *acd =3D user_data;
@@ -298,7 +312,61 @@ static bool acd_read_handler(struct l_io *io, void *us=
er_data)
 			acd->event_func(L_ACD_EVENT_CONFLICT, acd->user_data);
 =

 		l_acd_stop(acd);
+
+		break;
 	case ACD_STATE_ANNOUNCED:
+		/* Only defend packets with a source conflict */
+		if (!source_conflict)
+			return true;
+
+		/*
+		 * RFC 5227 - Section 2.4 (b)
+		 * [If the host] "has not seen any other conflicting ARP packets
+		 * within the last DEFEND_INTERVAL seconds, MAY elect to attempt
+		 * to defend its address by recording the time that the
+		 * conflicting ARP packet was received, and then broadcasting
+		 * one single ARP Announcement"
+		 */
+		acd->state =3D ACD_STATE_DEFEND;
+
+		/*
+		 * We still have an initial announcement to send, but rather
+		 * than wait for that (potentially 2 seconds) we can remove
+		 * the timeout, send annouce now, and still transition to the
+		 * defending state.
+		 */
+		if (acd->timeout)
+			l_timeout_remove(acd->timeout);
+
+		acd_send_packet(acd, acd->ip);
+
+		ACD_DEBUG("Defending address");
+
+		acd->timeout =3D l_timeout_create(DEFEND_INTERVAL,
+						defend_wait_timeout, acd, NULL);
+
+		break;
+	case ACD_STATE_DEFEND:
+		if (!source_conflict)
+			return true;
+
+		l_timeout_remove(acd->timeout);
+		acd->timeout =3D NULL;
+
+		ACD_DEBUG("Lost address");
+		/*
+		* RFC 5227 Section 2.4(b)
+		* "if this is not the first conflicting ARP packet the host has seen,
+		* and the time recorded for the previous conflicting ARP packet is
+		* recent, within DEFEND_INTERVAL seconds, then the host MUST
+		* immediately cease using this address and signal an error to the
+		* configuring agent"
+		*/
+		if (acd->event_func)
+			acd->event_func(L_ACD_EVENT_LOST, acd->user_data);
+
+		l_acd_stop(acd);
+
 		break;
 	}
 =

diff --git a/ell/acd.h b/ell/acd.h
index 121d119..21a6958 100644
--- a/ell/acd.h
+++ b/ell/acd.h
@@ -34,6 +34,7 @@ struct l_acd;
 enum l_acd_event {
 	L_ACD_EVENT_AVAILABLE,
 	L_ACD_EVENT_CONFLICT,
+	L_ACD_EVENT_LOST,
 };
 =

 typedef void (*l_acd_event_func_t)(enum l_acd_event event, void *user_data=
);
-- =

2.26.2

--===============3347548609411817575==--

