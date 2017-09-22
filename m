Content-Type: multipart/mixed; boundary="===============3857809253155578423=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 4/4] genl: Fix termination of name strings
Date: Fri, 22 Sep 2017 15:12:44 -0700
Message-ID: <20170922221244.12670-5-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20170922221244.12670-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3857809253155578423==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The genl_mcast and l_genl_family structs both have name fields of length
GENL_NAMSIZ. They are expected to be null terminated strings, but
strncpy() was being misused and not terminating long names
correctly. Depending on the context, this would result in an
unterminated string being passed to strcmp() or a kernel warning.
---
 ell/genl.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index 0ab6c98..b41a174 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -156,7 +156,7 @@ static struct l_genl_family *family_alloc(struct l_genl=
 *genl,
 	family =3D l_new(struct l_genl_family, 1);
 =

 	family->genl =3D genl;
-	strncpy(family->name, name, GENL_NAMSIZ);
+	l_strlcpy(family->name, name, GENL_NAMSIZ);
 =

 	family->op_list =3D l_queue_new();
 	family->mcast_list =3D l_queue_new();
@@ -232,7 +232,7 @@ static void family_add_mcast(struct l_genl_family *fami=
ly, const char *name,
 =

 	mcast =3D l_new(struct genl_mcast, 1);
 =

-	strncpy(mcast->name, name, GENL_NAMSIZ);
+	l_strlcpy(mcast->name, name, GENL_NAMSIZ);
 	mcast->id =3D id;
 	mcast->users =3D 0;
 =

@@ -1047,7 +1047,7 @@ static void get_family_callback(struct l_genl_msg *ms=
g, void *user_data)
 			family->id =3D *((uint16_t *) data);
 			break;
 		case CTRL_ATTR_FAMILY_NAME:
-			strncpy(family->name, data, GENL_NAMSIZ);
+			l_strlcpy(family->name, data, GENL_NAMSIZ);
 			break;
 		case CTRL_ATTR_VERSION:
 			family->version =3D *((uint32_t *) data);
-- =

2.14.1


--===============3857809253155578423==--

