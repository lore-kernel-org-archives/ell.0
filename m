Content-Type: multipart/mixed; boundary="===============1517068595515410470=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/8] dhcp-server: Handle DHCPDECLINE for active leases
Date: Fri, 23 Jul 2021 20:23:25 +0200
Message-ID: <20210723182331.135123-2-andrew.zaborowski@intel.com>
In-Reply-To: <20210723182331.135123-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1517068595515410470==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

RFC2131 Section 3.1 mentions a scenario where the client is supposed to
drop its lease using DHCPDECLINE after sending the DHCPREQUEST and
receiving the DHCPACK meaning that lease is no longer in the offering
state:

"5. The client receives the DHCPACK message with configuration
    parameters.  The client SHOULD perform a final check on the
    parameters [...].  If the client detects that the address is already
    in use (e.g., through the use of ARP), the client MUST send a
    DHCPDECLINE message..."
---
 ell/dhcp-server.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 6415872..9f4703c 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -734,7 +734,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 		SERVER_DEBUG("Received DECLINE");
 =

 		if (server_id_opt !=3D server->address || !requested_ip_opt ||
-				!lease || !lease->offering)
+				!lease)
 			break;
 =

 		if (requested_ip_opt =3D=3D lease->address)
-- =

2.30.2

--===============1517068595515410470==--

