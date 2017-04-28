Content-Type: multipart/mixed; boundary="===============6245483017515836674=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] unit: Test netlink multicast group registration
Date: Fri, 28 Apr 2017 13:56:40 -0700
Message-ID: <1493413000-14282-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6245483017515836674==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Register for the rtnetlink RTNLGRP_LINK multicast group to test the
ELL netlink multicast group registration code.  Only registration and
deregistration is performed for now.  An actual RTNLGRP_LINK multicast
notification is not triggered.
---
 unit/test-netlink.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/unit/test-netlink.c b/unit/test-netlink.c
index ce522a6..928830a 100644
--- a/unit/test-netlink.c
+++ b/unit/test-netlink.c
@@ -27,6 +27,7 @@
 #include <sys/socket.h>
 #include <linux/rtnetlink.h>
 #include <net/if.h>
+#include <assert.h>
 =

 #include <ell/ell.h>
 =

@@ -72,10 +73,16 @@ done:
 	l_main_quit();
 }
 =

+static void link_notification(uint16_t type, void const * data,
+					uint32_t len, void * user_data)
+{
+}
+
 int main(int argc, char *argv[])
 {
 	struct l_netlink *netlink;
 	struct ifinfomsg msg;
+	unsigned int link_id;
 =

 	if (!l_main_init())
 		return -1;
@@ -91,8 +98,13 @@ int main(int argc, char *argv[])
 	l_netlink_send(netlink, RTM_GETLINK, NLM_F_DUMP, &msg, sizeof(msg),
 						getlink_callback, NULL, NULL);
 =

+	link_id =3D l_netlink_register(netlink, RTNLGRP_LINK,
+					link_notification, NULL, NULL);
+
 	l_main_run();
 =

+	assert(l_netlink_unregister(netlink, link_id));
+
 	l_netlink_destroy(netlink);
 =

 	l_main_exit();
-- =

2.7.4


--===============6245483017515836674==--

