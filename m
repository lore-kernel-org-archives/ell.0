Content-Type: multipart/mixed; boundary="===============8754549366060768237=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 1/2] settings: fix segfault if when settings has no group
Date: Thu, 21 Feb 2019 10:22:15 -0800
Message-ID: <20190221182216.29956-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8754549366060768237==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

A settings file containing a key/value but no group caused
l_settings_load_from_data to segfault. This was due to both parse_key
and parse_value not checking that the group was non-NULL.

Also, the return of parse_key was being checked against false, when
it actually is returning a unsigned int. This was changed to just
check !parse_key.
---
 ell/settings.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/ell/settings.c b/ell/settings.c
index e3e8303..2153218 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -297,6 +297,9 @@ static unsigned int parse_key(struct l_settings *settin=
gs, const char *data,
 	}
 =

 	group =3D l_queue_peek_tail(settings->groups);
+	if (!group)
+		return 0;
+
 	pair =3D l_new(struct setting_data, 1);
 	pair->key =3D l_strndup(data, end);
 	l_queue_push_head(group->settings, pair);
@@ -312,6 +315,9 @@ static bool parse_value(struct l_settings *settings, co=
nst char *data,
 	struct setting_data *pair;
 =

 	group =3D l_queue_peek_tail(settings->groups);
+	if (!group)
+		return false;
+
 	pair =3D l_queue_pop_head(group->settings);
 =

 	if (!l_utf8_validate(data, len, NULL)) {
@@ -347,7 +353,7 @@ static bool parse_keyvalue(struct l_settings *settings,=
 const char *data,
 		return false;
 	}
 =

-	if (parse_key(settings, data, equal - data, line) =3D=3D false)
+	if (!parse_key(settings, data, equal - data, line))
 		return false;
 =

 	equal +=3D 1;
-- =

2.17.1


--===============8754549366060768237==--

