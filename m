Content-Type: multipart/mixed; boundary="===============4104062015117846680=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/5] gvariant: Allow empty signature in
 enter_struct_dict_common
Date: Sat, 23 Apr 2016 03:10:04 +0200
Message-ID: <1461373807-19793-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461373807-19793-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4104062015117846680==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

gvariant_iter_init_internal now checks if the signature is empty before
calling _gvariant_num_children which would return an error in that case.
The gvariant_iter_init_internal caller is responsible for checking if
the signature is allowed in the specific context.
---
 ell/gvariant-util.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index 17606f8..1f493e0 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -391,11 +391,17 @@ static bool gvariant_iter_init_internal(struct l_dbus=
_message_iter *iter,
 	iter->len =3D len;
 	iter->pos =3D 0;
 =

-	n_children =3D _gvariant_num_children(subsig);
-	if (n_children < 0)
-		return false;
+	if (subsig[0] !=3D '\0') {
+		n_children =3D _gvariant_num_children(subsig);
+		if (n_children < 0)
+			return false;
 =

-	children =3D l_new(struct gvariant_type_info, n_children);
+		children =3D l_new(struct gvariant_type_info, n_children);
+	} else {
+		n_children =3D 0;
+
+		children =3D NULL;
+	}
 =

 	for (p =3D sig_start, i =3D 0; i < n_children; i++) {
 		int alignment;
@@ -966,7 +972,7 @@ static bool enter_struct_dict_common(struct dbus_builde=
r *builder,
 bool _gvariant_builder_enter_struct(struct dbus_builder *builder,
 					const char *signature)
 {
-	if (!_gvariant_valid_signature(signature))
+	if (signature[0] && !_gvariant_valid_signature(signature))
 		return false;
 =

 	return enter_struct_dict_common(builder, signature,
-- =

2.5.0


--===============4104062015117846680==--

