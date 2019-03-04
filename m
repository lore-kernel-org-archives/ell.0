Content-Type: multipart/mixed; boundary="===============8192418879580427737=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 2/5] ell: Do not use C99 '//' single line comment.
Date: Mon, 04 Mar 2019 10:42:56 -0800
Message-ID: <20190304184259.22809-3-ossama.othman@intel.com>
In-Reply-To: <20190304184259.22809-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8192418879580427737==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Support older C standards by avoiding use of C99/C++ style '//'
comments.
---
 ell/dbus.c    | 2 +-
 ell/netlink.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index 5664f85..92be396 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1286,7 +1286,7 @@ LIB_EXPORT bool l_dbus_set_debug(struct l_dbus *dbus,
 	dbus->debug_destroy =3D destroy;
 	dbus->debug_data =3D user_data;
 =

-	//l_io_set_debug(dbus->io, function, user_data, NULL);
+	/* l_io_set_debug(dbus->io, function, user_data, NULL); */
 =

 	return true;
 }
diff --git a/ell/netlink.c b/ell/netlink.c
index 39e6b3a..3d291cf 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -607,7 +607,7 @@ LIB_EXPORT bool l_netlink_set_debug(struct l_netlink *n=
etlink,
 	netlink->debug_destroy =3D destroy;
 	netlink->debug_data =3D user_data;
 =

-	//l_io_set_debug(netlink->io, function, user_data, NULL);
+	/* l_io_set_debug(netlink->io, function, user_data, NULL); */
 =

 	return true;
 }
-- =

2.17.1


--===============8192418879580427737==--

