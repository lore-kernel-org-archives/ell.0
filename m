Content-Type: multipart/mixed; boundary="===============2241082371507443411=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 2/5] acd: remove acd_random_delay_ms
Date: Tue, 08 Dec 2020 10:42:25 -0800
Message-ID: <20201208184228.751111-2-prestwoj@gmail.com>
In-Reply-To: <20201208184228.751111-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2241082371507443411==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

time.c privately exposes a similar function
---
 ell/acd.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/ell/acd.c b/ell/acd.c
index 7d912d9..ae6f7b1 100644
--- a/ell/acd.c
+++ b/ell/acd.c
@@ -36,6 +36,7 @@
 #include "net.h"
 #include "timeout.h"
 #include "random.h"
+#include "time-private.h"
 =

 /* IPv4 Address Conflict Detection (RFC 5227) */
 #define PROBE_WAIT		1
@@ -156,15 +157,6 @@ static int acd_send_packet(struct l_acd *acd, uint32_t=
 source_ip)
 	return n;
 }
 =

-static uint32_t acd_random_delay_ms(uint32_t max_sec)
-{
-	uint32_t rand;
-
-	l_getrandom(&rand, sizeof(rand));
-
-	return rand % (max_sec * 1000);
-}
-
 static void announce_wait_timeout(struct l_timeout *timeout, void *user_da=
ta)
 {
 	struct l_acd *acd =3D user_data;
@@ -233,8 +225,7 @@ static void probe_wait_timeout(struct l_timeout *timeou=
t, void *user_data)
 		 * these probe packets spaced randomly and uniformly, PROBE_MIN
 		 * to PROBE_MAX seconds apart."
 		 */
-		delay =3D acd_random_delay_ms(PROBE_MAX - PROBE_MIN);
-		delay +=3D PROBE_MIN * 1000;
+		delay =3D _time_pick_interval_secs(PROBE_MIN, PROBE_MAX);
 		acd->timeout =3D l_timeout_create_ms(delay, probe_wait_timeout,
 							acd, NULL);
 	} else {
@@ -468,7 +459,7 @@ LIB_EXPORT bool l_acd_start(struct l_acd *acd, const ch=
ar *ip)
 	} else
 		acd->state =3D ACD_STATE_PROBE;
 =

-	delay =3D acd_random_delay_ms(PROBE_WAIT);
+	delay =3D _time_pick_interval_secs(0, PROBE_WAIT);
 =

 	ACD_DEBUG("Waiting %ums to send probe", delay);
 =

-- =

2.26.2

--===============2241082371507443411==--

