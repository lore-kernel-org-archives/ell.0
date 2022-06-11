Content-Type: multipart/mixed; boundary="===============7900886199507238230=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 1/3] acd: Emit event as the last statement in handler
Date: Sat, 11 Jun 2022 03:45:43 +0200
Message-ID: <20220611014545.1466270-1-andrew.zaborowski@intel.com>

--===============7900886199507238230==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Move l_acd_stop() to before the call to the event handler for
L_ACD_EVENT_LOST to allow the handler to free the l_acd instance if
needed.
---
 ell/acd.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/ell/acd.c b/ell/acd.c
index 2d84843..723ae17 100644
--- a/ell/acd.c
+++ b/ell/acd.c
@@ -317,12 +317,12 @@ static bool acd_read_handler(struct l_io *io, void *u=
ser_data)
 		if (acd->policy =3D=3D L_ACD_DEFEND_POLICY_NONE) {
 			ACD_DEBUG("Conflict detected, giving up address");
 =

+			l_acd_stop(acd);
+
 			if (acd->event_func)
 				acd->event_func(L_ACD_EVENT_LOST,
 							acd->user_data);
 =

-			l_acd_stop(acd);
-
 			break;
 		}
 =

@@ -387,6 +387,8 @@ static bool acd_read_handler(struct l_io *io, void *use=
r_data)
 		acd->timeout =3D NULL;
 =

 		ACD_DEBUG("Lost address");
+		l_acd_stop(acd);
+
 		/*
 		* RFC 5227 Section 2.4(b)
 		* "if this is not the first conflicting ARP packet the host has seen,
@@ -398,8 +400,6 @@ static bool acd_read_handler(struct l_io *io, void *use=
r_data)
 		if (acd->event_func)
 			acd->event_func(L_ACD_EVENT_LOST, acd->user_data);
 =

-		l_acd_stop(acd);
-
 		break;
 	}
 =

-- =

2.34.1

--===============7900886199507238230==--

