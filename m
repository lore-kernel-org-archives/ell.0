Content-Type: multipart/mixed; boundary="===============6355156491502223601=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/5] gvariant: Make sure builder outputs a zero for empty
 struct
Date: Sat, 23 Apr 2016 03:10:05 +0200
Message-ID: <1461373807-19793-4-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461373807-19793-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6355156491502223601==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make sure the single byte being written by the builder is a zero.
I had assumed grow_body would zero the newly allocated body bytes but on
a closer look it zeros the alignment padding only.
---
 ell/gvariant-util.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index 1f493e0..2172ad9 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -1016,9 +1016,12 @@ static bool leave_struct_dict_common(struct dbus_bui=
lder *builder,
 		int alignment =3D _gvariant_get_alignment(container->signature);
 		grow_body(builder, 0, alignment);
 =

-		/* Empty struct or "unit type" is a encoded as a zero byte */
-		if (container->signature[0] =3D=3D '\0')
-			grow_body(builder, 1, 1);
+		/* Empty struct or "unit type" is encoded as a zero byte */
+		if (container->signature[0] =3D=3D '\0') {
+			size_t start =3D grow_body(builder, 1, 1);
+
+			memset(builder->body + start, 0, 1);
+		}
 =

 		parent->variable_is_last =3D false;
 	} else {
@@ -1323,9 +1326,12 @@ char *_gvariant_builder_finish(struct dbus_builder *=
builder,
 		int alignment =3D _gvariant_get_alignment(signature);
 		grow_body(builder, 0, alignment);
 =

-		/* Empty struct or "unit type" is encoded one zero byte */
-		if (signature[0] =3D=3D '\0')
-			grow_body(builder, 1, 1);
+		/* Empty struct or "unit type" is encoded as a zero byte */
+		if (signature[0] =3D=3D '\0') {
+			size_t start =3D grow_body(builder, 1, 1);
+
+			memset(builder->body + start, 0, 1);
+		}
 	} else
 		container_append_struct_offsets(root, builder);
 =

-- =

2.5.0


--===============6355156491502223601==--

