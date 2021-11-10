Content-Type: multipart/mixed; boundary="===============4747891447416759107=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman at gmail.com>
To: ell at lists.01.org
Subject: [PATCH 2/3] unit: Add l_rtnl_address_get_address() test case.
Date: Tue, 09 Nov 2021 16:14:47 -0800
Message-ID: <20211110001448.175980-3-ossama.othman@intel.com>
In-Reply-To: 20211110001448.175980-1-ossama.othman@intel.com

--===============4747891447416759107==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-rtnl.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/unit/test-rtnl.c b/unit/test-rtnl.c
index 107f69a..9826272 100644
--- a/unit/test-rtnl.c
+++ b/unit/test-rtnl.c
@@ -31,6 +31,7 @@
 #include <stdlib.h>
 #include <signal.h>
 #include <sys/wait.h>
+#include <netinet/in.h>
 =

 #include <ell/ell.h>
 #include "ell/dbus-private.h"
@@ -232,6 +233,30 @@ static void test_ifaddr6_dump(struct l_netlink *rntl, =
void *user_data)
 					NULL, ifaddr6_dump_destroy_cb));
 }
 =

+static void test_get_address(struct l_netlink *rntl, void *user_data)
+{
+	static const char ip[] =3D "192.0.2.1";
+	static const uint8_t prefix_len =3D 32;
+	struct l_rtnl_address *addr =3D NULL;
+	size_t buflen, badlen;
+
+	char buf[INET_ADDRSTRLEN];
+	buflen =3D L_ARRAY_SIZE(buf);
+	badlen =3D 4;
+
+	addr =3D l_rtnl_address_new(ip, prefix_len);
+	test_assert(addr);
+
+	test_assert(l_rtnl_address_get_address(addr, buf, buflen));
+	test_assert(!l_rtnl_address_get_address(addr, buf, badlen));
+
+	test_assert(strcmp(ip, buf) =3D=3D 0);
+
+	l_rtnl_address_free(addr);
+
+	test_next();
+}
+
 static void test_run(void)
 {
 	success =3D false;
@@ -249,6 +274,7 @@ int main(int argc, char *argv[])
 	test_add("Dump IPv6 routing table", test_route6_dump, NULL);
 	test_add("Dump IPv4 addresses", test_ifaddr4_dump, NULL);
 	test_add("Dump IPv6 addresses", test_ifaddr6_dump, NULL);
+	test_add("Get address", test_get_address, NULL);
 =

 	l_log_set_stderr();
 =

-- =

2.32.0

--===============4747891447416759107==--

