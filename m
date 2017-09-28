Content-Type: multipart/mixed; boundary="===============6004536650108232761=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/4] genl: Sanitize incoming family name string
Date: Wed, 27 Sep 2017 17:22:02 -0700
Message-ID: <20170928002205.17218-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6004536650108232761==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The null terminated name must fit in a system-defined fixed-size buffer.
---
 ell/genl.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/genl.c b/ell/genl.c
index 0ab6c98..d9f8af3 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -1079,7 +1079,8 @@ LIB_EXPORT struct l_genl_family *l_genl_family_new(st=
ruct l_genl *genl,
 	struct l_genl_family *family;
 	struct l_genl_msg *msg;
 =

-	if (unlikely(!genl) || unlikely(!name))
+	if (unlikely(!genl) || unlikely(!name) ||
+		unlikely(strlen(name) >=3D GENL_NAMSIZ))
 		return NULL;
 =

 	family =3D family_alloc(genl, name);
-- =

2.14.1


--===============6004536650108232761==--

