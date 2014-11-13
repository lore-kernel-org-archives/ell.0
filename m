Content-Type: multipart/mixed; boundary="===============2106512528683321883=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 02/21] dbus: Add a private getter for the unique dbus tree in
 dbus struct
Date: Thu, 13 Nov 2014 12:36:06 +0200
Message-ID: <1415874985-13034-3-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2106512528683321883==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This will be useful for properly refactoring all interface related code
into dbus-service.c.
---
 ell/dbus-private.h | 1 +
 ell/dbus.c         | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 9987294..a34f444 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -210,5 +210,6 @@ int _dbus_kernel_add_match(int fd, uint64_t bloom_size,=
 uint64_t bloom_n_hash,
 				uint64_t *out_cookie);
 int _dbus_kernel_remove_match(int fd, uint64_t cookie);
 =

+struct _dbus_object_tree *_dbus_object_tree_get_from_dbus(struct l_dbus *d=
bus);
 uint8_t _dbus_get_version(struct l_dbus *dbus);
 int _dbus_get_fd(struct l_dbus *dbus);
diff --git a/ell/dbus.c b/ell/dbus.c
index 4c4ba2d..d5d58a9 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1199,6 +1199,11 @@ int _dbus_get_fd(struct l_dbus *dbus)
 	return l_io_get_fd(dbus->io);
 }
 =

+struct _dbus_object_tree *_dbus_object_tree_get_from_dbus(struct l_dbus *d=
bus)
+{
+	return dbus->tree;
+}
+
 LIB_EXPORT bool l_dbus_register_interface(struct l_dbus *dbus,
 				const char *path, const char *interface,
 				l_dbus_interface_setup_func_t setup_func,
-- =

2.0.4


--===============2106512528683321883==--

