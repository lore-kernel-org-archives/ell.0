Content-Type: multipart/mixed; boundary="===============0114144252653694175=="
MIME-Version: 1.0
From: Jonathan Liu <net147@gmail.com>
Subject: [PATCH] ell.sym: Add l_dhcp6_client_set_rtnl symbol
Date: Sun, 15 Nov 2020 15:30:43 +1100
Message-ID: <20201115043043.163797-1-net147@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0114144252653694175==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Fixes: e51f6b9f11eb ("dhcp6: Add support for setting address(es)")
---
 ell/ell.sym | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index b02c60e..73623ea 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -268,6 +268,7 @@ global:
 	l_dhcp6_client_set_no_rapid_commit;
 	l_dhcp6_client_set_nodelay;
 	l_dhcp6_client_set_nora;
+	l_dhcp6_client_set_rtnl;
 	l_dhcp6_client_set_stateless;
 	l_dhcp6_client_get_icmp6;
 	l_dhcp6_client_add_request_option;
-- =

2.29.2

--===============0114144252653694175==--

