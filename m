Content-Type: multipart/mixed; boundary="===============6649795280613524974=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/8] dbus: Private function to retrieve the tree for a
 connection.
Date: Fri, 05 Feb 2016 03:58:31 +0100
Message-ID: <1454641114-3421-5-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1454641114-3421-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6649795280613524974==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-private.h | 1 +
 ell/dbus.c         | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 3eb3847..8c58218 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -226,6 +226,7 @@ int _dbus_kernel_remove_match(int fd, uint64_t cookie);
 =

 uint8_t _dbus_get_version(struct l_dbus *dbus);
 int _dbus_get_fd(struct l_dbus *dbus);
+struct _dbus_object_tree *_dbus_get_tree(struct l_dbus *dbus);
 =

 struct dbus1_filter_data;
 =

diff --git a/ell/dbus.c b/ell/dbus.c
index d825414..796240f 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1214,6 +1214,11 @@ int _dbus_get_fd(struct l_dbus *dbus)
 	return l_io_get_fd(dbus->io);
 }
 =

+struct _dbus_object_tree *_dbus_get_tree(struct l_dbus *dbus)
+{
+	return dbus->tree;
+}
+
 /**
  * l_dbus_register_interface:
  * @dbus: D-Bus connection as returned by @l_dbus_new*
-- =

2.5.0


--===============6649795280613524974==--

