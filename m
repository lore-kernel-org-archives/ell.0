Content-Type: multipart/mixed; boundary="===============9197391632912328339=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 06/15] examples: Update netconfig method calls
Date: Fri, 20 May 2022 17:43:29 +0200
Message-ID: <20220520154338.2056273-6-andrew.zaborowski@intel.com>
In-Reply-To: 20220520154338.2056273-1-andrew.zaborowski@intel.com

--===============9197391632912328339==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/netconfig-test.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/examples/netconfig-test.c b/examples/netconfig-test.c
index aba63f9..39b6fa4 100644
--- a/examples/netconfig-test.c
+++ b/examples/netconfig-test.c
@@ -40,7 +40,6 @@
 #include <ell/ell.h>
 =

 static bool apply;
-static struct l_netlink *rtnl;
 =

 static void do_debug(const char *str, void *user_data)
 {
@@ -138,7 +137,7 @@ static void event_handler(struct l_netconfig *netconfig=
, uint8_t family,
 	log_routes(af_str, "removed", removed);
 =

 	if (apply)
-		l_netconfig_apply_rtnl(netconfig, rtnl);
+		l_netconfig_apply_rtnl(netconfig);
 }
 =

 static const struct option main_options[] =3D {
@@ -180,14 +179,6 @@ int main(int argc, char *argv[])
 	if (!l_main_init())
 		return EXIT_FAILURE;
 =

-	if (apply) {
-		rtnl =3D l_netlink_new(NETLINK_ROUTE);
-		if (!rtnl) {
-			fprintf(stderr, "l_netlink_new(NETLINK_ROUTE) error\n");
-			return EXIT_FAILURE;
-		}
-	}
-
 	l_log_set_stderr();
 	l_debug_enable("*");
 =

@@ -202,7 +193,5 @@ int main(int argc, char *argv[])
 	l_netconfig_destroy(netconfig);
 	l_main_exit();
 =

-	l_netlink_destroy(rtnl);
-
 	return EXIT_SUCCESS;
 }
-- =

2.32.0

--===============9197391632912328339==--

