Content-Type: multipart/mixed; boundary="===============6330744140494812358=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Fix subpath comparisons in object tree walk
Date: Wed, 15 Aug 2018 06:02:45 +0200
Message-ID: <20180815040245.22277-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6330744140494812358==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

By only using strncmp(child->subpath, path, len) we'd only check that
child->subpath had path as its prefix in makepath_recurse.  As a
result, if an object at /ab was added first and at /a second, the
second object would not get a new node created and strangely none of
our tests or users have caught this.
---
 ell/dbus-service.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 43c7a5c..cd9d402 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -649,7 +649,8 @@ static struct object_node *makepath_recurse(struct obje=
ct_node *node,
 	child =3D node->children;
 =

 	while (child) {
-		if (!strncmp(child->subpath, path, end - path))
+		if (!memcmp(child->subpath, path, end - path) &&
+				child->subpath[end - path] =3D=3D '\0')
 			goto done;
 =

 		child =3D child->next;
@@ -690,7 +691,8 @@ static struct object_node *lookup_recurse(struct object=
_node *node,
 	child =3D node->children;
 =

 	while (child) {
-		if (!strncmp(child->subpath, path, end - path))
+		if (!memcmp(child->subpath, path, end - path) &&
+				child->subpath[end - path] =3D=3D '\0')
 			return lookup_recurse(child->node, end);
 =

 		child =3D child->next;
-- =

2.14.1


--===============6330744140494812358==--

