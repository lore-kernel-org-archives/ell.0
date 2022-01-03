Content-Type: multipart/mixed; boundary="===============3447137363181158265=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 2/4] dhcp6: Minor optimzation in dhcp6_client_send_initial
Date: Mon, 03 Jan 2022 15:18:28 +0100
Message-ID: <20220103141830.311011-2-andrew.zaborowski@intel.com>
In-Reply-To: 20220103141830.311011-1-andrew.zaborowski@intel.com

--===============3447137363181158265==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dhcp6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index 3321043..3e38ff2 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -1493,7 +1493,7 @@ static void dhcp6_client_icmp6_event(struct l_icmp6_c=
lient *icmp6,
 			return;
 		}
 =

-		if (l_icmp6_router_get_managed(r))
+		if (managed)
 			dhcp6_client_send_initial(client);
 =

 		break;
-- =

2.32.0

--===============3447137363181158265==--

