Content-Type: multipart/mixed; boundary="===============8386521796974865171=="
MIME-Version: 1.0
From: Rosen Penev <rosenp@gmail.com>
Subject: [PATCH 1/4] ell: add missing void to function declarations
Date: Wed, 01 Apr 2020 20:36:29 -0700
Message-ID: <20200402033632.961701-1-rosenp@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8386521796974865171==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Found with -Wstrict-prototypes.
---
 ell/checksum.h     | 2 +-
 ell/dbus-private.h | 2 +-
 ell/main.h         | 2 +-
 ell/random.h       | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/ell/checksum.h b/ell/checksum.h
index 08d74b7..531fcb0 100644
--- a/ell/checksum.h
+++ b/ell/checksum.h
@@ -64,7 +64,7 @@ ssize_t l_checksum_get_digest(struct l_checksum *checksum,
 char *l_checksum_get_string(struct l_checksum *checksum);
 =

 bool l_checksum_is_supported(enum l_checksum_type type, bool check_hmac);
-bool l_checksum_cmac_aes_supported();
+bool l_checksum_cmac_aes_supported(void);
 =

 ssize_t l_checksum_digest_length(enum l_checksum_type type);
 =

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index be62691..d34a298 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -189,7 +189,7 @@ struct _dbus_signal *_dbus_interface_find_signal(struct=
 l_dbus_interface *i,
 struct _dbus_property *_dbus_interface_find_property(struct l_dbus_interfa=
ce *i,
 						const char *property);
 =

-struct _dbus_object_tree *_dbus_object_tree_new();
+struct _dbus_object_tree *_dbus_object_tree_new(void);
 void _dbus_object_tree_free(struct _dbus_object_tree *tree);
 =

 struct object_node *_dbus_object_tree_makepath(struct _dbus_object_tree *t=
ree,
diff --git a/ell/main.h b/ell/main.h
index 99b34ad..51e051a 100644
--- a/ell/main.h
+++ b/ell/main.h
@@ -42,7 +42,7 @@ typedef void (*l_main_signal_cb_t) (uint32_t signo, void =
*user_data);
 =

 int l_main_run_with_signal(l_main_signal_cb_t callback, void *user_data);
 =

-int l_main_get_epoll_fd();
+int l_main_get_epoll_fd(void);
 =

 #ifdef __cplusplus
 }
diff --git a/ell/random.h b/ell/random.h
index 49a4637..acc278b 100644
--- a/ell/random.h
+++ b/ell/random.h
@@ -32,7 +32,7 @@ extern "C" {
 #include <stdint.h>
 =

 bool l_getrandom(void *buf, size_t len);
-bool l_getrandom_is_supported();
+bool l_getrandom_is_supported(void);
 =

 uint32_t l_getrandom_uint32(void);
 =

-- =

2.25.1

--===============8386521796974865171==--

