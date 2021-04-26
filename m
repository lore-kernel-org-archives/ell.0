Content-Type: multipart/mixed; boundary="===============7419197094344859077=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] settings: Add l_settings_add_group
Date: Mon, 26 Apr 2021 18:06:21 +0200
Message-ID: <20210426160622.761540-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7419197094344859077==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_settings_add_group creates a group in the l_settings object without
adding any key/value pairs to it.
---
 ell/ell.sym    |  1 +
 ell/settings.c | 28 ++++++++++++++++++++++++++++
 ell/settings.h |  2 ++
 3 files changed, 31 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 229a2a6..5568ac2 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -443,6 +443,7 @@ global:
 	l_settings_set_debug;
 	l_settings_get_groups;
 	l_settings_has_group;
+	l_settings_add_group;
 	l_settings_get_keys;
 	l_settings_has_key;
 	l_settings_get_value;
diff --git a/ell/settings.c b/ell/settings.c
index 8db0942..3d3728c 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -866,6 +866,34 @@ static bool validate_group_name(const char *group_name)
 	return true;
 }
 =

+LIB_EXPORT bool l_settings_add_group(struct l_settings *settings,
+					const char *group_name)
+{
+	struct group_data *group;
+
+	if (unlikely(!settings || !group_name))
+		return false;
+
+	if (!validate_group_name(group_name)) {
+		l_util_debug(settings->debug_handler, settings->debug_data,
+				"Invalid group name %s", group_name);
+		return false;
+	}
+
+	group =3D l_queue_find(settings->groups, group_match, group_name);
+	if (group) {
+		l_util_debug(settings->debug_handler, settings->debug_data,
+				"Group %s exists", group_name);
+		return true;
+	}
+
+	group =3D l_new(struct group_data, 1);
+	group->name =3D l_strdup(group_name);
+	group->settings =3D l_queue_new();
+	l_queue_push_tail(settings->groups, group);
+	return true;
+}
+
 static bool validate_key(const char *key)
 {
 	int i;
diff --git a/ell/settings.h b/ell/settings.h
index f95ed9b..be92d29 100644
--- a/ell/settings.h
+++ b/ell/settings.h
@@ -54,6 +54,8 @@ char **l_settings_get_groups(const struct l_settings *set=
tings);
 char **l_settings_get_keys(const struct l_settings *settings,
 							const char *group_name);
 =

+bool l_settings_add_group(struct l_settings *settings, const char *group_n=
ame);
+
 bool l_settings_has_group(const struct l_settings *settings,
 							const char *group_name);
 bool l_settings_has_key(const struct l_settings *settings,
-- =

2.27.0

--===============7419197094344859077==--

