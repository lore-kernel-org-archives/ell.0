Content-Type: multipart/mixed; boundary="===============8884157632488663095=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@gmail.com>
Subject: [PATCH] genl: Return false, not NULL, for boolean return.
Date: Fri, 12 Mar 2021 11:04:16 -0800
Message-ID: <20210312190416.183218-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8884157632488663095==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Ossama Othman <ossama.othman@gmail.com>

The return type of the l_genl_request_family() function is bool, not a
pointer.  Return false instead of NULL to match the return type.
---
 ell/genl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index 7e3f800..97457cf 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -1538,11 +1538,11 @@ LIB_EXPORT bool l_genl_request_family(struct l_genl=
 *genl, const char *name,
 	struct family_request *req;
 =

 	if (unlikely(!genl) || unlikely(!name))
-		return NULL;
+		return false;
 =

 	len =3D strlen(name);
 	if (unlikely(strlen(name) >=3D GENL_NAMSIZ))
-		return NULL;
+		return false;
 =

 	req =3D l_new(struct family_request, 1);
 	req->appeared_func =3D appeared_func;
-- =

2.25.1

--===============8884157632488663095==--

