Content-Type: multipart/mixed; boundary="===============3380967345512215545=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] dhcp-server: Fix lease expiry time calculation
Date: Sat, 05 Jun 2021 00:19:06 +0200
Message-ID: <20210604221907.202641-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3380967345512215545==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

We were comparing the l_time_now() (usecs) to lease->lifetime (secs)
and then converting the result from usecs to secs, so the "diff" and the
"to_secs" operations need to be switched around.  While there, use the
opportunity to replace the "diff" operation so that if lease->lifetime is
already in the past (e.g. because processing took to long), we schedule
the timeout in 1 millisec instead of the absolute value of the difference.
---
 ell/dhcp-server.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 50855fe..3d6a6a8 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -191,7 +191,6 @@ static void set_next_expire_timer(struct l_dhcp_server =
*server,
 					struct l_dhcp_lease *expired)
 {
 	struct l_dhcp_lease *next;
-	unsigned int next_timeout;
 =

 	/*
 	 * If this is an expiring lease put it into the expired queue, removing
@@ -214,15 +213,20 @@ static void set_next_expire_timer(struct l_dhcp_serve=
r *server,
 		return;
 	}
 =

-	next_timeout =3D l_time_to_secs(l_time_diff(l_time_now(),
-							next->lifetime));
-
-	if (server->next_expire)
-		l_timeout_modify(server->next_expire, next_timeout);
-	else
-		server->next_expire =3D l_timeout_create(server->lease_seconds,
-							lease_expired_cb,
-							server, NULL);
+	if (server->next_expire) {
+		uint32_t now =3D l_time_to_secs(l_time_now());
+
+		if (l_time_after(next->lifetime, now)) {
+			unsigned int next_timeout =3D next->lifetime - now;
+
+			l_timeout_modify(server->next_expire, next_timeout);
+		} else
+			l_timeout_modify_ms(server->next_expire, 1);
+	} else
+		server->next_expire =3D l_timeout_create(
+						server->lease_seconds,
+						lease_expired_cb,
+						server, NULL);
 }
 =

 static void lease_expired_cb(struct l_timeout *timeout, void *user_data)
-- =

2.30.2

--===============3380967345512215545==--

