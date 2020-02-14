Content-Type: multipart/mixed; boundary="===============5196025316167357394=="
MIME-Version: 1.0
From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH 2/3] unit: Add unit test for l_rtnl_route6_{dump|extract}
Date: Fri, 14 Feb 2020 19:52:52 +0100
Message-ID: <20200214185253.32658-3-wagi@monom.org>
In-Reply-To: <20200214185253.32658-1-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5196025316167357394==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-rtnl.c | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/unit/test-rtnl.c b/unit/test-rtnl.c
index c0659c4378da..37db73dc6f2f 100644
--- a/unit/test-rtnl.c
+++ b/unit/test-rtnl.c
@@ -139,6 +139,37 @@ static void test_route4_dump(struct l_netlink *rtnl, v=
oid *user_data)
 					NULL, route4_dump_destroy_cb));
 }
 =

+static void route6_dump_cb(int error,
+			uint16_t type, const void *data,
+			uint32_t len, void *user_data)
+{
+	const struct rtmsg *rtmsg =3D data;
+	char *dst =3D NULL, *gateway =3D NULL, *src =3D NULL;
+	uint32_t idx;
+
+	test_assert(!error);
+	test_assert(type =3D=3D RTM_NEWROUTE);
+
+	l_rtnl_route6_extract(rtmsg, len, &idx, &dst, &gateway, &src);
+
+	l_info("idx %d dst %s gateway %s src %s", idx, dst, gateway, src);
+
+	l_free(dst);
+	l_free(gateway);
+	l_free(src);
+}
+
+static void route6_dump_destroy_cb(void *user_data)
+{
+	test_next();
+}
+
+static void test_route6_dump(struct l_netlink *rtnl, void *user_data)
+{
+	test_assert(l_rtnl_route6_dump(rtnl, route6_dump_cb,
+					NULL, route6_dump_destroy_cb));
+}
+
 static void ifaddr4_dump_cb(int error,
 				uint16_t type, const void *data,
 				uint32_t len, void *user_data)
@@ -211,6 +242,7 @@ int main(int argc, char *argv[])
 		return -1;
 =

 	test_add("Dump IPv4 routing table", test_route4_dump, NULL);
+	test_add("Dump IPv6 routing table", test_route6_dump, NULL);
 	test_add("Dump IPv4 addresses", test_ifaddr4_dump, NULL);
 	test_add("Dump IPv6 addresses", test_ifaddr6_dump, NULL);
 =

-- =

2.25.0
--===============5196025316167357394==--

