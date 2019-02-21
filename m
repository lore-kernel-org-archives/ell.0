Content-Type: multipart/mixed; boundary="===============1064736532951730270=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v3 1/2] settings: fix segfault if when settings has no group
Date: Thu, 21 Feb 2019 14:33:54 -0800
Message-ID: <20190221223355.31790-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1064736532951730270==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

A settings file containing a key/value but no group caused
l_settings_load_from_data to segfault. This was due to not checking
that a group was actually found before parsing a key/value pair.

A new flag was added, 'has_group', which gets set after a group has
been parsed successfully. This flag also must be true for the load
to be successful.

Also, the return of parse_key was being checked against false, when
it actually is returning a unsigned int. This was changed to just
check !parse_key.
---
 ell/settings.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/ell/settings.c b/ell/settings.c
index e3e8303..0c06fe7 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -347,7 +347,7 @@ static bool parse_keyvalue(struct l_settings *settings,=
 const char *data,
 		return false;
 	}
 =

-	if (parse_key(settings, data, equal - data, line) =3D=3D false)
+	if (!parse_key(settings, data, equal - data, line))
 		return false;
 =

 	equal +=3D 1;
@@ -362,6 +362,7 @@ LIB_EXPORT bool l_settings_load_from_data(struct l_sett=
ings *settings,
 {
 	size_t pos =3D 0;
 	bool r =3D true;
+	bool has_group =3D false;
 	const char *eol;
 	size_t line =3D 1;
 	size_t line_len;
@@ -387,11 +388,17 @@ LIB_EXPORT bool l_settings_load_from_data(struct l_se=
ttings *settings,
 =

 		line_len =3D eol - data - pos;
 =

-		if (data[pos] =3D=3D '[')
+		if (data[pos] =3D=3D '[') {
 			r =3D parse_group(settings, data + pos, line_len, line);
-		else if (data[pos] !=3D '#')
+			if (r)
+				has_group =3D true;
+		} else if (data[pos] !=3D '#') {
+			if (!has_group)
+				return false;
+
 			r =3D parse_keyvalue(settings, data + pos, line_len,
 						line);
+		}
 =

 		pos +=3D line_len;
 	}
-- =

2.17.1


--===============1064736532951730270==--

