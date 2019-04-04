Content-Type: multipart/mixed; boundary="===============2765606389756233530=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] genl: Be more careful with termination of genl names
Date: Thu, 04 Apr 2019 15:13:03 -0700
Message-ID: <20190404221303.2452-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2765606389756233530==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

GCC 9 adds "-Werror=3Dstringop-truncation" that warns (and therefore
triggers a compile error) when strncpy has a size limit that's the same
as the destination size, which can allow string termination
problems. Instead, reduce the limit passed to strncpy by 1 and make sure
the destination is terminated. This appears to be consistent with the
handling of GENL_NAMSIZ strings in the kernel.

The fixed-length struct genl_mcast name is also used in a string
comparison, where the known size limit is now applied.
---
 ell/genl.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index 2905a5e..74a49e6 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -161,7 +161,8 @@ static struct l_genl_family *family_alloc(struct l_genl=
 *genl,
 	family =3D l_new(struct l_genl_family, 1);
 =

 	family->genl =3D genl;
-	strncpy(family->name, name, GENL_NAMSIZ);
+	strncpy(family->name, name, GENL_NAMSIZ - 1);
+	family->name[GENL_NAMSIZ - 1] =3D '\0';
 =

 	family->op_list =3D l_queue_new();
 	family->mcast_list =3D l_queue_new();
@@ -218,7 +219,7 @@ static bool match_mcast_name(const void *a, const void =
*b)
 	const struct genl_mcast *mcast =3D a;
 	const char *name =3D b;
 =

-	return !strcmp(mcast->name, name);
+	return !strncmp(mcast->name, name, GENL_NAMSIZ);
 }
 =

 static void family_add_mcast(struct l_genl_family *family, const char *nam=
e,
@@ -237,7 +238,9 @@ static void family_add_mcast(struct l_genl_family *fami=
ly, const char *name,
 =

 	mcast =3D l_new(struct genl_mcast, 1);
 =

-	strncpy(mcast->name, name, GENL_NAMSIZ);
+	strncpy(mcast->name, name, GENL_NAMSIZ - 1);
+	mcast->name[GENL_NAMSIZ - 1] =3D '\0';
+
 	mcast->id =3D id;
 	mcast->users =3D 0;
 =

@@ -1046,7 +1049,8 @@ static void get_family_callback(struct l_genl_msg *ms=
g, void *user_data)
 			family->id =3D *((uint16_t *) data);
 			break;
 		case CTRL_ATTR_FAMILY_NAME:
-			strncpy(family->name, data, GENL_NAMSIZ);
+			strncpy(family->name, data, GENL_NAMSIZ - 1);
+			family->name[GENL_NAMSIZ - 1] =3D '\0';
 			break;
 		case CTRL_ATTR_VERSION:
 			family->version =3D *((uint32_t *) data);
-- =

2.21.0


--===============2765606389756233530==--

