Content-Type: multipart/mixed; boundary="===============6682437415982205167=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dhcp-server: Fix lease expiry time calculation
Date: Wed, 02 Jun 2021 01:53:32 +0200
Message-ID: <20210601235332.95056-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6682437415982205167==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

We were comparing the l_time_now() (usecs) to lease->lifetime (secs)
and then converting the result from usecs to secs, so the "diff" and the
"to_secs" operations need to be switched around.  While there, use the
opportunity to replace the "diff" operation so that if lease->lifetime is
already in the past (e.g. because processing took to long), we schedule
the timeout in 1 millisec instead of the absolute value of the difference.

Since we're using uint32_t for the timestamps, use the overflow-safe(r)
comparisons in set_next_expire_timer and in is_expired_lease.
---
 ell/dhcp-server.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index ebd4438..38193a2 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -104,7 +104,7 @@ struct l_dhcp_server {
 =

 static bool is_expired_lease(struct l_dhcp_lease *lease)
 {
-	if (lease->lifetime < l_time_to_secs(l_time_now()))
+	if ((int32_t) (lease->lifetime - l_time_to_secs(l_time_now())) < 0)
 		return true;
 =

 	return false;
@@ -191,7 +191,8 @@ static void set_next_expire_timer(struct l_dhcp_server =
*server,
 					struct l_dhcp_lease *expired)
 {
 	struct l_dhcp_lease *next;
-	unsigned int next_timeout;
+	unsigned long next_timeout;
+	uint32_t now;
 =

 	/*
 	 * If this is an expiring lease put it into the expired queue, removing
@@ -214,11 +215,12 @@ static void set_next_expire_timer(struct l_dhcp_serve=
r *server,
 		return;
 	}
 =

-	next_timeout =3D l_time_to_secs(l_time_diff(l_time_now(),
-							next->lifetime));
+	now =3D l_time_to_secs(l_time_now());
+	next_timeout =3D (int32_t) (next->lifetime - now) > 0 ?
+		(next->lifetime - now) * 1000L : 1;
 =

 	if (server->next_expire)
-		l_timeout_modify(server->next_expire, next_timeout);
+		l_timeout_modify_ms(server->next_expire, next_timeout);
 	else
 		server->next_expire =3D l_timeout_create(server->lease_seconds,
 							lease_expired_cb,
-- =

2.30.2

--===============6682437415982205167==--

