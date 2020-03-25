Content-Type: multipart/mixed; boundary="===============1134517984375634009=="
MIME-Version: 1.0
From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH] rtnl: Export l_rtnl_*() functions
Date: Wed, 25 Mar 2020 13:36:40 +0100
Message-ID: <20200325123640.15114-1-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1134517984375634009==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ell.sym | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 0c83b874706f..f4b30dd9366f 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -543,6 +543,26 @@ ELL_0.10 {
 	l_gpio_reader_new;
 	l_gpio_reader_free;
 	l_gpio_reader_get;
+	/* rtnl */
+	l_rtnl_set_linkmode_and_operstate;
+	l_rtnl_set_mac;
+	l_rtnl_set_powered;
+	l_rtnl_ifaddr4_extract;
+	l_rtnl_ifaddr4_dump;
+	l_rtnl_ifaddr4_add;
+	l_rtnl_ifaddr4_delete;
+	l_rtnl_route4_extract;
+	l_rtnl_route4_dump;
+	l_rtnl_route4_add_connected;
+	l_rtnl_route4_add_gateway;
+	l_rtnl_ifaddr6_extract;
+	l_rtnl_ifaddr6_dump;
+	l_rtnl_ifaddr6_add;
+	l_rtnl_ifaddr6_delete;
+	l_rtnl_route6_extract;
+	l_rtnl_route6_dump;
+	l_rtnl_route6_add_gateway;
+	l_rtnl_route6_delete_gateway;
 local:
 	*;
 };
-- =

2.25.1
--===============1134517984375634009==--

