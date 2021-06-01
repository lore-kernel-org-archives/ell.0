Content-Type: multipart/mixed; boundary="===============2894367202929582652=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/4] dhcp-server: Don't check if lease expired in lease_release
Date: Tue, 01 Jun 2021 04:03:45 +0200
Message-ID: <20210601020346.35502-3-andrew.zaborowski@intel.com>
In-Reply-To: <20210601020346.35502-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2894367202929582652==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When lease_release() is called by listener_event(), the lease must have
been found in server->lease_list meaning that its expiry timeout hasn't
happened yet.  Even if lease->lifetime happens to have just expired, we
probably want to emit the LEASE_EXPIRED notification immediately and
move the lease from least_list and expired_list, rather than wait for
the timeout.
---
 ell/dhcp-server.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 9226ba4..217844b 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -287,14 +287,6 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_se=
rver *server,
 static void lease_release(struct l_dhcp_server *server,
 			struct l_dhcp_lease *lease)
 {
-	/*
-	 * If the client released the lease after the server timeout expired
-	 * there is nothing to do. Otherwise the client is releasing the
-	 * lease early which may require re-setting the lease expire timer
-	 */
-	if (is_expired_lease(lease))
-		return;
-
 	if (server->event_handler)
 		server->event_handler(server, L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
 					server->user_data, lease);
-- =

2.30.2

--===============2894367202929582652==--

