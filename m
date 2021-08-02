Content-Type: multipart/mixed; boundary="===============0781820661705794442=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 08/15] dhcp-server: Reuse leases in find_free_or_expired_ip
Date: Mon, 02 Aug 2021 16:04:17 +0200
Message-ID: <20210802140424.170150-8-andrew.zaborowski@intel.com>
In-Reply-To: <20210802140424.170150-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0781820661705794442==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

If a 'safe_mac' parameter is passed to find_free_or_expired_ip and a
lease matching that MAC is found in expired_list, return that lease's
address over the oldest lease's or an unused address.
---
 ell/dhcp-server.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index a4e7002..eb8fcd7 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -411,7 +411,7 @@ static uint32_t find_free_or_expired_ip(struct l_dhcp_s=
erver *server,
 			continue;
 =

 		lease =3D find_lease_by_ip(server->expired_list, ip_nl);
-		if (lease)
+		if (lease && memcmp(lease->mac, safe_mac, ETH_ALEN))
 			continue;
 =

 		if (arp_check(ip_nl, safe_mac))
-- =

2.30.2

--===============0781820661705794442==--

