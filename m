Content-Type: multipart/mixed; boundary="===============6635926830986614018=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/4] dhcp-server: Validate the offering state when handling
 message
Date: Tue, 01 Jun 2021 04:03:46 +0200
Message-ID: <20210601020346.35502-4-andrew.zaborowski@intel.com>
In-Reply-To: <20210601020346.35502-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6635926830986614018==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make extra sure we don't call remove_lease() on a lease that is not in
the "offering" state because that would remove the lease without
respecting the lease_list/expire_lease semantics or emitting the
LEASE_EXPIRED event.  Similarly make sure we don't call lease_expire()
on a lease that is in the "offering" state because that would move it
directly to expire_lease, emit a false LEASE_EXPIRED event and update
the expiry timeout wrongly.
---
I wonder if instead we should insert the leases being offered into
server->lease_list same as the active leases (i.e. according to their
leas->lifetime), and call set_next_expire_timer() so that their lifetimes
are tracked and so that they're also expired.  We'd only need to check
the lease->offered flag before emitting the LEASE_EXPIRED events.

As it is now, I think a lease that is offered never times out if the
client never replies to the offer, the 5-minute lifetime is ignored.

 ell/dhcp-server.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 217844b..f4d08d6 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -646,7 +646,8 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 	case DHCP_MESSAGE_TYPE_DECLINE:
 		SERVER_DEBUG("Received DECLINE");
 =

-		if (!server_id_opt || !requested_ip_opt || !lease)
+		if (!server_id_opt || !requested_ip_opt || !lease ||
+				!lease->offering)
 			break;
 =

 		if (requested_ip_opt =3D=3D lease->address)
@@ -656,7 +657,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 	case DHCP_MESSAGE_TYPE_RELEASE:
 		SERVER_DEBUG("Received RELEASE");
 =

-		if (!server_id_opt || !lease)
+		if (!server_id_opt || !lease || lease->offering)
 			break;
 =

 		if (message->ciaddr =3D=3D lease->address)
-- =

2.30.2

--===============6635926830986614018==--

