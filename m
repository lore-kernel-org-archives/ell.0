Content-Type: multipart/mixed; boundary="===============8392944085428485267=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] settings: clear copies of values in set_value
Date: Fri, 03 Apr 2020 18:44:10 +0200
Message-ID: <20200403164410.18943-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8392944085428485267==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

We bzero the setting values before they're free elsewhere in the file
but not in set_value, and we do use it in iwd to set a PIN.
---
 ell/settings.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/ell/settings.c b/ell/settings.c
index f4326d6..945dff7 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -885,17 +885,13 @@ static bool set_value(struct l_settings *settings, co=
nst char *group_name,
 	if (!validate_group_name(group_name)) {
 		l_util_debug(settings->debug_handler, settings->debug_data,
 				"Invalid group name %s", group_name);
-		l_free(value);
-
-		return false;
+		goto error;
 	}
 =

 	if (!validate_key(key)) {
 		l_util_debug(settings->debug_handler, settings->debug_data,
 				"Invalid key %s", key);
-		l_free(value);
-
-		return false;
+		goto error;
 	}
 =

 	group =3D l_queue_find(settings->groups, group_match, group_name);
@@ -919,10 +915,16 @@ add_pair:
 		return true;
 	}
 =

+	explicit_bzero(pair->value, strlen(pair->value));
 	l_free(pair->value);
 	pair->value =3D value;
 =

 	return true;
+
+error:
+	explicit_bzero(value, strlen(value));
+	l_free(value);
+	return false;
 }
 =

 LIB_EXPORT bool l_settings_set_value(struct l_settings *settings,
-- =

2.20.1

--===============8392944085428485267==--

