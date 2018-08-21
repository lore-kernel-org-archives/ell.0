Content-Type: multipart/mixed; boundary="===============3317301990015405881=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] dbus: Avoid memcmp for string comparison
Date: Tue, 21 Aug 2018 05:12:53 +0200
Message-ID: <20180821031254.31527-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3317301990015405881==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

As discussed in
https://lists.01.org/pipermail/ell/2018-August/001279.html gcc's Address
Sanitizer may complain if we try using memcmp(A, B, len) to compare a
null-terminated A shorter than len against a longer B so use strncmp
instead.
---
 ell/dbus-service.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index edc46cd..4e70b7b 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1467,7 +1467,7 @@ bool _dbus_object_tree_add_interface(struct _dbus_obj=
ect_tree *tree,
 		manager =3D entry->data;
 		path_len =3D strlen(manager->path);
 =

-		if (memcmp(path, manager->path, path_len) ||
+		if (strncmp(path, manager->path, path_len) ||
 				(path[path_len] !=3D '\0' &&
 				 path[path_len] !=3D '/' && path_len > 1))
 			continue;
@@ -1544,7 +1544,7 @@ bool _dbus_object_tree_remove_interface(struct _dbus_=
object_tree *tree,
 		manager =3D entry->data;
 		path_len =3D strlen(manager->path);
 =

-		if (memcmp(path, manager->path, path_len) ||
+		if (strncmp(path, manager->path, path_len) ||
 				(path[path_len] !=3D '\0' &&
 				 path[path_len] !=3D '/' && path_len > 1))
 			continue;
-- =

2.14.1


--===============3317301990015405881==--

