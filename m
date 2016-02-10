Content-Type: multipart/mixed; boundary="===============0393710892239824873=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/9] dbus: Private function to retrieve the tree for a
 connection.
Date: Wed, 10 Feb 2016 11:45:49 +0100
Message-ID: <1455101156-3587-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455101156-3587-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0393710892239824873==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-private.h | 1 +
 ell/dbus.c         | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index e60d09e..35c97b7 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -212,6 +212,7 @@ int _dbus_kernel_remove_match(int fd, uint64_t cookie);
 =

 uint8_t _dbus_get_version(struct l_dbus *dbus);
 int _dbus_get_fd(struct l_dbus *dbus);
+struct _dbus_object_tree *_dbus_get_tree(struct l_dbus *dbus);
 =

 struct dbus1_filter_data;
 =

diff --git a/ell/dbus.c b/ell/dbus.c
index 1d9aed5..14849e8 100644
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
 LIB_EXPORT bool l_dbus_register_interface(struct l_dbus *dbus,
 				const char *path, const char *interface,
 				l_dbus_interface_setup_func_t setup_func,
-- =

2.5.0


--===============0393710892239824873==--

