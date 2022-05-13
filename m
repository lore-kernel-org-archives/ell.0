Content-Type: multipart/mixed; boundary="===============2088424089905364023=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: [PATCH] dhcp: Make sure lease bound_time is in BOOTTIME
Date: Fri, 13 May 2022 11:29:24 -0500
Message-ID: <20220513162924.27587-1-denkenz@gmail.com>

--===============2088424089905364023==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The timestamp obtained from the kernel is always in CLOCK_REALTIME, not
CLOCK_BOOTTIME.  For bound_time, we expected CLOCK_BOOTTIME.

Fixes: c78ad1bb6d7e ("dhcp: Set lease expiry based on frame reception times=
")
---
 ell/dhcp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index 01900f3b1d38..8418825c6c81 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -922,7 +922,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata,
 =

 		dhcp_client_event_notify(client, r);
 =

-		client->lease->bound_time =3D timestamp;
+		client->lease->bound_time =3D l_time_now();
 =

 		/*
 		 * Start T1, once it expires we will start the T2 timer.  If
-- =

2.32.0

--===============2088424089905364023==--

