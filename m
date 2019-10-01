Content-Type: multipart/mixed; boundary="===============7156918211812105018=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v3 5/6] settings: introduce extended groups concept
Date: Tue, 01 Oct 2019 09:47:42 -0700
Message-ID: <20191001164743.23088-5-prestwoj@gmail.com>
In-Reply-To: <20191001164743.23088-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7156918211812105018==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This patch introduces a new extended format for settings files. This new
format allows raw data to be provided under a given group rather than
key/value pairs. A group using an extended format will contain both the
extended type and group name in the format, for example:

[@pem(a)certificate]

Where 'pem' is the type and 'certificate' is the name. The type of
format requires an extension specific parser implementation in settings
as the parser must know when to start/stop parsing data. This allows for
any textual characters to be present after the group is declared,
including special characters like [] (its completely up to the parser to
decide whats valid and what is not).

Three new l_settings APIs were added:

l_settings_has_embedded_group
l_settings_get_embedded_groups
l_settings_get_embedded_value

In this patch, the 'pem' extension type is also introduced, and for now
is the only extended type. The pem extended type expects a base64 encoded
PEM (or list of PEMs) after the group. The pem parser will stop after the
last PEM is found. Examples can be found in unit/test-settings.c
---
 ell/ell.sym    |   3 +
 ell/settings.c | 231 ++++++++++++++++++++++++++++++++++++++++++++++---
 ell/settings.h |   7 ++
 3 files changed, 230 insertions(+), 11 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index e02f0fe..32d94f5 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -425,6 +425,9 @@ global:
 	l_settings_set_float;
 	l_settings_remove_group;
 	l_settings_remove_key;
+	l_settings_has_embedded_group;
+	l_settings_get_embedded_groups;
+	l_settings_get_embedded_value;
 	/* signal */
 	l_signal_create;
 	l_signal_remove;
diff --git a/ell/settings.c b/ell/settings.c
index 98f0cfd..da38cb7 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -48,15 +48,23 @@
 #include "settings.h"
 #include "private.h"
 #include "missing.h"
+#include "pem-private.h"
 =

 struct setting_data {
 	char *key;
 	char *value;
 };
 =

+struct embedded_group_data {
+	char type[32];
+	size_t len;
+	char data[0];
+};
+
 struct group_data {
 	char *name;
 	struct l_queue *settings;
+	struct embedded_group_data *embedded_data;
 };
 =

 struct l_settings {
@@ -81,7 +89,11 @@ static void group_destroy(void *data)
 	struct group_data *group =3D data;
 =

 	l_free(group->name);
-	l_queue_destroy(group->settings, setting_destroy);
+
+	if (group->settings)
+		l_queue_destroy(group->settings, setting_destroy);
+	else
+		l_free(group->embedded_data);
 =

 	l_free(group);
 }
@@ -222,6 +234,125 @@ static char *escape_value(const char *value)
 	return ret;
 }
 =

+static ssize_t parse_pem(const char *data, size_t len)
+{
+	const char *ptr, *end;
+
+	ptr =3D data;
+	end =3D data + len;
+
+	while (ptr && ptr < end) {
+		size_t out_len =3D 0;
+		const char *pem;
+
+		pem =3D pem_next(ptr, len, NULL, &out_len);
+		if (!pem)
+			break;
+
+		ptr +=3D out_len;
+		len -=3D out_len;
+	}
+
+	return ptr - data;
+}
+
+struct group_extension {
+	char *name;
+	ssize_t (*parse)(const char *data, size_t len);
+};
+
+static struct group_extension pem_extension =3D {
+	.name =3D "pem",
+	.parse =3D parse_pem,
+};
+
+struct group_extension *extensions[] =3D {
+	&pem_extension,
+	NULL
+};
+
+static struct group_extension *find_group_extension(const char *type)
+{
+	unsigned int i;
+
+	for (i =3D 0; extensions[i]; i++) {
+		if (!strcmp(type, extensions[i]->name))
+			return extensions[i];
+	}
+
+	return NULL;
+}
+
+static ssize_t parse_embedded_group(struct l_settings *setting, const char=
 *data,
+					size_t line_len, size_t len)
+{
+	struct group_data *group;
+	struct group_extension *ext;
+	const char *ptr1, *ptr2;
+	L_AUTO_FREE_VAR(char *, type) =3D NULL;
+	char *name;
+	ssize_t bytes;
+
+	/* Must be at least [@a(a)b]\n */
+	if (line_len < 7)
+		return -EINVAL;
+
+	/* caller checked data[1] =3D=3D '@' */
+	ptr1 =3D data + 1;
+
+	ptr2 =3D ptr1 + 1;
+
+	while (*ptr2 !=3D '@' && (size_t)(ptr2 - data) < line_len)
+		ptr2++;
+
+	if (*ptr2 !=3D '@')
+		return -EINVAL;
+
+	type =3D l_strndup(ptr1 + 1, ptr2 - ptr1 - 1);
+
+	ptr1 =3D ptr2;
+
+	while (*ptr1 !=3D ']' && (size_t)(ptr1 - data) < line_len)
+		ptr1++;
+
+	if (*ptr1 !=3D ']')
+		return -EINVAL;
+
+	if (ptr1[1] !=3D '\n')
+		return -EINVAL;
+
+	if (ptr1 - ptr2 - 1 < 1)
+		return -EINVAL;
+
+	name =3D l_strndup(ptr2 + 1, ptr1 - ptr2 - 1);
+
+	ext =3D find_group_extension(type);
+	if (!ext)
+		goto free_name;
+
+	bytes =3D ext->parse(ptr1 + 2, len - line_len);
+	if (bytes < 0)
+		goto free_name;
+
+	group =3D l_new(struct group_data, 1);
+
+	group->name =3D name;
+	group->embedded_data =3D l_malloc(sizeof(struct embedded_group_data) +
+						bytes + 1);
+	strcpy(group->embedded_data->type, type);
+	group->embedded_data->len =3D bytes;
+	memcpy(group->embedded_data->data, ptr1 + 2, bytes);
+	group->embedded_data->data[bytes] =3D '\0';
+
+	l_queue_push_tail(setting->groups, group);
+
+	return bytes;
+
+free_name:
+	l_free(name);
+	return -EINVAL;
+}
+
 static bool parse_group(struct l_settings *settings, const char *data,
 			size_t len, size_t line)
 {
@@ -404,7 +535,20 @@ LIB_EXPORT bool l_settings_load_from_data(struct l_set=
tings *settings,
 =

 		line_len =3D eol - data - pos;
 =

-		if (data[pos] =3D=3D '[') {
+		if (line_len > 1 && data[pos] =3D=3D '[' && data[pos + 1] =3D=3D '@') {
+			ssize_t ret;
+
+			ret =3D parse_embedded_group(settings, data + pos,
+							line_len, len - pos);
+			if (ret < 0)
+				return false;
+
+			/*
+			 * This is the offset for the actual raw data, the
+			 * group line will be offset below
+			 */
+			pos +=3D ret;
+		} else if (data[pos] =3D=3D '[') {
 			r =3D parse_group(settings, data + pos, line_len, line);
 			if (r)
 				has_group =3D true;
@@ -437,10 +581,18 @@ LIB_EXPORT char *l_settings_to_data(const struct l_se=
ttings *settings,
 	group_entry =3D l_queue_get_entries(settings->groups);
 	while (group_entry) {
 		struct group_data *group =3D group_entry->data;
-		const struct l_queue_entry *setting_entry =3D
-				l_queue_get_entries(group->settings);
+		const struct l_queue_entry *setting_entry;
+
+		if (group->embedded_data) {
+			l_string_append_printf(buf, "[@%s@%s]\n%s",
+					group->embedded_data->type,
+					group->name,
+					group->embedded_data->data);
+			goto group_done;
+		} else
+			l_string_append_printf(buf, "[%s]\n", group->name);
 =

-		l_string_append_printf(buf, "[%s]\n", group->name);
+		setting_entry =3D l_queue_get_entries(group->settings);
 =

 		while (setting_entry) {
 			struct setting_data *setting =3D setting_entry->data;
@@ -450,6 +602,7 @@ LIB_EXPORT char *l_settings_to_data(const struct l_sett=
ings *settings,
 			setting_entry =3D setting_entry->next;
 		}
 =

+group_done:
 		if (group_entry->next)
 			l_string_append_c(buf, '\n');
 =

@@ -552,24 +705,24 @@ static void gather_groups(void *data, void *user_data)
 	struct group_data *group_data =3D data;
 	struct gather_data *gather =3D user_data;
 =

-	gather->v[gather->cur++] =3D l_strdup(group_data->name);
+	if (!group_data->settings)
+		return;
+
+	gather->v =3D l_strv_append(gather->v, group_data->name);
 }
 =

 LIB_EXPORT char **l_settings_get_groups(const struct l_settings *settings)
 {
-	char **ret;
 	struct gather_data gather;
 =

 	if (unlikely(!settings))
 		return NULL;
 =

-	ret =3D l_new(char *, l_queue_length(settings->groups) + 1);
-	gather.v =3D ret;
-	gather.cur =3D 0;
+	gather.v =3D l_strv_new();
 =

 	l_queue_foreach(settings->groups, gather_groups, &gather);
 =

-	return ret;
+	return gather.v;
 }
 =

 LIB_EXPORT bool l_settings_has_group(const struct l_settings *settings,
@@ -1176,3 +1329,59 @@ LIB_EXPORT bool l_settings_remove_key(struct l_setti=
ngs *settings,
 =

 	return true;
 }
+
+static void gather_embedded_groups(void *data, void *user_data)
+{
+	struct group_data *group_data =3D data;
+	struct gather_data *gather =3D user_data;
+
+	if (!group_data->embedded_data)
+		return;
+
+	gather->v =3D l_strv_append(gather->v, group_data->name);
+}
+
+LIB_EXPORT char **l_settings_get_embedded_groups(struct l_settings *settin=
gs)
+{
+	struct gather_data gather;
+
+	if (unlikely(!settings))
+		return NULL;
+
+	gather.v =3D l_strv_new();
+
+	l_queue_foreach(settings->groups, gather_embedded_groups, &gather);
+
+	return gather.v;
+}
+
+LIB_EXPORT bool l_settings_has_embedded_group(struct l_settings *settings,
+						const char *group)
+{
+	struct group_data *group_data;
+
+	if (unlikely(!settings))
+		return false;
+
+	group_data =3D l_queue_find(settings->groups, group_match, group);
+
+	return group_data->embedded_data !=3D NULL;
+}
+
+LIB_EXPORT const char *l_settings_get_embedded_value(struct l_settings *se=
ttings,
+							const char *group_name,
+							const char **out_type)
+{
+	struct group_data *group;
+
+	if (unlikely(!settings))
+		return false;
+
+	group =3D l_queue_find(settings->groups, group_match, group_name);
+	if (!group || !group->embedded_data)
+		return NULL;
+
+	*out_type =3D group->embedded_data->type;
+
+	return group->embedded_data->data;
+}
diff --git a/ell/settings.h b/ell/settings.h
index 0da9f55..e4203af 100644
--- a/ell/settings.h
+++ b/ell/settings.h
@@ -123,6 +123,13 @@ bool l_settings_remove_key(struct l_settings *settings=
, const char *group_name,
 				const char *key);
 bool l_settings_remove_group(struct l_settings *settings,
 				const char *group_name);
+
+char **l_settings_get_embedded_groups(struct l_settings *settings);
+bool l_settings_has_embedded_group(struct l_settings *settings,
+					const char *group);
+const char *l_settings_get_embedded_value(struct l_settings *settings,
+						const char *group_name,
+						const char **out_type);
 #ifdef __cplusplus
 }
 #endif
-- =

2.17.1

--===============7156918211812105018==--

