Content-Type: multipart/mixed; boundary="===============5466383915923354495=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 3/5] acd: optimize to use l_timeout_modify
Date: Tue, 08 Dec 2020 10:42:26 -0800
Message-ID: <20201208184228.751111-3-prestwoj@gmail.com>
In-Reply-To: <20201208184228.751111-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5466383915923354495==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Rather than destroy and create a new timeout the existing
timeout can be modified in cases where the same callback
is used.
---
 ell/acd.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/ell/acd.c b/ell/acd.c
index ae6f7b1..a50b26e 100644
--- a/ell/acd.c
+++ b/ell/acd.c
@@ -161,9 +161,6 @@ static void announce_wait_timeout(struct l_timeout *tim=
eout, void *user_data)
 {
 	struct l_acd *acd =3D user_data;
 =

-	l_timeout_remove(acd->timeout);
-	acd->timeout =3D NULL;
-
 	if (acd->state =3D=3D ACD_STATE_PROBE) {
 		ACD_DEBUG("No conflicts found for %s, announcing address",
 				IP_STR(acd->ip));
@@ -190,13 +187,14 @@ static void announce_wait_timeout(struct l_timeout *t=
imeout, void *user_data)
 			return;
 		}
 =

-		acd->timeout =3D l_timeout_create(ANNOUNCE_INTERVAL,
-						announce_wait_timeout,
-						acd, NULL);
+		l_timeout_modify(acd->timeout, ANNOUNCE_INTERVAL);
 =

 		return;
 	}
 =

+	l_timeout_remove(acd->timeout);
+	acd->timeout =3D NULL;
+
 	ACD_DEBUG("Done announcing");
 }
 =

@@ -207,9 +205,6 @@ static void probe_wait_timeout(struct l_timeout *timeou=
t, void *user_data)
 =

 	ACD_DEBUG("Sending ACD Probe");
 =

-	l_timeout_remove(acd->timeout);
-	acd->timeout =3D NULL;
-
 	if (acd_send_packet(acd, 0) < 0) {
 		ACD_DEBUG("Failed to send ACD probe");
 		return;
@@ -226,8 +221,7 @@ static void probe_wait_timeout(struct l_timeout *timeou=
t, void *user_data)
 		 * to PROBE_MAX seconds apart."
 		 */
 		delay =3D _time_pick_interval_secs(PROBE_MIN, PROBE_MAX);
-		acd->timeout =3D l_timeout_create_ms(delay, probe_wait_timeout,
-							acd, NULL);
+		l_timeout_modify_ms(acd->timeout, delay);
 	} else {
 		/*
 		 * Wait for ANNOUNCE_WAIT seconds after probe period before
@@ -235,6 +229,9 @@ static void probe_wait_timeout(struct l_timeout *timeou=
t, void *user_data)
 		 */
 		ACD_DEBUG("Done probing");
 =

+		l_timeout_remove(acd->timeout);
+		acd->timeout =3D NULL;
+
 		acd->retries =3D 1;
 =

 		acd->timeout =3D l_timeout_create(ANNOUNCE_WAIT,
-- =

2.26.2

--===============5466383915923354495==--

