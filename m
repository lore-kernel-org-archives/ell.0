Content-Type: multipart/mixed; boundary="===============3610266033782616697=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/4] genl: Update genl refcount when creating/freeing a family
Date: Sat, 15 Feb 2020 00:37:29 +0100
Message-ID: <20200214233732.20146-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3610266033782616697==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Since struct l_genl is already refcounted we can hold references to the
l_genl object in an l_genl_family to allow the user to free them in
arbitrary order.
---
 ell/genl.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/genl.c b/ell/genl.c
index 431ed05..ca4fa62 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -1800,7 +1800,7 @@ LIB_EXPORT struct l_genl_family *l_genl_family_new(st=
ruct l_genl *genl,
 	if (!entry)
 		return NULL;
 =

-	family =3D family_alloc(genl, info->id);
+	family =3D family_alloc(l_genl_ref(genl), info->id);
 =

 	return family;
 }
@@ -2059,4 +2059,5 @@ LIB_EXPORT void l_genl_family_free(struct l_genl_fami=
ly *family)
 	}
 =

 	l_free(family);
+	l_genl_unref(genl);
 }
-- =

2.20.1

--===============3610266033782616697==--

