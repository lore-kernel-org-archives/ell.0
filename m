Content-Type: multipart/mixed; boundary="===============2597744437749920080=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v7 1/2] settings: introduce extended groups concept
Date: Fri, 04 Oct 2019 10:39:19 -0700
Message-ID: <20191004173920.2180-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2597744437749920080==
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
 ell/settings.c | 258 ++++++++++++++++++++++++++++++++++++++++++++++++-
 ell/settings.h |   7 ++
 3 files changed, 265 insertions(+), 3 deletions(-)

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
index 98f0cfd..c1b766e 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -48,12 +48,20 @@
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
+	char *name;
+	char type[32];
+	size_t len;
+	char data[0];
+};
+
 struct group_data {
 	char *name;
 	struct l_queue *settings;
@@ -64,6 +72,7 @@ struct l_settings {
 	l_settings_destroy_cb_t debug_destroy;
 	void *debug_data;
 	struct l_queue *groups;
+	struct l_queue *embedded_groups;
 };
 =

 static void setting_destroy(void *data)
@@ -86,12 +95,21 @@ static void group_destroy(void *data)
 	l_free(group);
 }
 =

+static void embedded_group_destroy(void *data)
+{
+	struct embedded_group_data *group =3D data;
+
+	l_free(group->name);
+	l_free(group);
+}
+
 LIB_EXPORT struct l_settings *l_settings_new(void)
 {
 	struct l_settings *settings;
 =

 	settings =3D l_new(struct l_settings, 1);
 	settings->groups =3D l_queue_new();
+	settings->embedded_groups =3D l_queue_new();
 =

 	return settings;
 }
@@ -105,6 +123,7 @@ LIB_EXPORT void l_settings_free(struct l_settings *sett=
ings)
 		settings->debug_destroy(settings->debug_data);
 =

 	l_queue_destroy(settings->groups, group_destroy);
+	l_queue_destroy(settings->embedded_groups, embedded_group_destroy);
 =

 	l_free(settings);
 }
@@ -222,6 +241,140 @@ static char *escape_value(const char *value)
 	return ret;
 }
 =

+static ssize_t parse_pem(const char *data, size_t len)
+{
+	const char *ptr;
+	const char *end;
+	size_t count =3D 0;
+
+	ptr =3D data;
+	end =3D data + len;
+
+	while (ptr && ptr < end) {
+		const char *pem_start =3D ptr;
+
+		if (!pem_next(ptr, len, NULL, NULL, &ptr, true)) {
+			if (ptr)
+				return -EINVAL;
+
+			break;
+		}
+
+		len -=3D ptr - pem_start;
+		count +=3D ptr - pem_start;
+	}
+
+	return count;
+}
+
+struct group_extension {
+	char *name;
+	ssize_t (*parse)(const char *data, size_t len);
+};
+
+static const struct group_extension pem_extension =3D {
+	.name =3D "pem",
+	.parse =3D parse_pem,
+};
+
+static const struct group_extension *extensions[] =3D {
+	&pem_extension,
+	NULL
+};
+
+static const struct group_extension *find_group_extension(const char *type,
+								size_t len)
+{
+	unsigned int i;
+
+	for (i =3D 0; extensions[i]; i++) {
+		if (!strncmp(type, extensions[i]->name, len))
+			return extensions[i];
+	}
+
+	return NULL;
+}
+
+static ssize_t parse_embedded_group(struct l_settings *setting,
+					const char *data,
+					size_t line_len, size_t len,
+					size_t line)
+{
+	struct embedded_group_data *group;
+	const struct group_extension *ext;
+	const char *ptr;
+	const char *type;
+	size_t type_len;
+	const char *name;
+	size_t name_len;
+	ssize_t bytes;
+
+	/* Must be at least [@a(a)b] */
+	if (line_len < 6)
+		goto invalid_group;
+
+	/* caller checked data[1] =3D=3D '@', next char is type */
+	type =3D data + 2;
+
+	ptr =3D memchr(type, '@', line_len - 2);
+
+	type_len =3D ptr - type;
+
+	if (!ptr || type_len > 31 || type_len < 1)
+		goto invalid_group;
+
+	if (ptr + 1 > data + line_len)
+		goto invalid_group;
+
+	name =3D ptr + 1;
+
+	/* subtract [@@ + type */
+	ptr =3D memchr(name, ']', line_len - 3 - type_len);
+
+	name_len =3D ptr - name;
+
+	if (!ptr || name_len < 1)
+		goto invalid_group;
+
+	ext =3D find_group_extension(type, type_len);
+	if (!ext)
+		goto invalid_group;
+
+	if (ptr + 2 > data + len) {
+		l_util_debug(setting->debug_handler, setting->debug_data,
+				"Embedded group had no payload");
+		return -EINVAL;
+	}
+
+	bytes =3D ext->parse(ptr + 2, len - line_len);
+	if (bytes < 0) {
+		l_util_debug(setting->debug_handler, setting->debug_data,
+				"Failed to parse embedded group data");
+		return -EINVAL;
+	}
+
+	group =3D l_malloc(sizeof(struct embedded_group_data) + bytes + 1);
+
+	group->name =3D l_strndup(name, name_len);
+
+	memcpy(group->type, type, type_len);
+	group->type[type_len] =3D '\0';
+
+	group->len =3D bytes;
+	memcpy(group->data, ptr + 2, bytes);
+	group->data[bytes] =3D '\0';
+
+	l_queue_push_tail(setting->embedded_groups, group);
+
+	return bytes;
+
+invalid_group:
+	l_util_debug(setting->debug_handler, setting->debug_data,
+			"Invalid embedded group at line %zd", line);
+
+	return -EINVAL;
+}
+
 static bool parse_group(struct l_settings *settings, const char *data,
 			size_t len, size_t line)
 {
@@ -404,7 +557,21 @@ LIB_EXPORT bool l_settings_load_from_data(struct l_set=
tings *settings,
 =

 		line_len =3D eol - data - pos;
 =

-		if (data[pos] =3D=3D '[') {
+		if (line_len > 1 && data[pos] =3D=3D '[' && data[pos + 1] =3D=3D '@') {
+			ssize_t ret;
+
+			ret =3D parse_embedded_group(settings, data + pos,
+							line_len, len - pos,
+							line);
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
@@ -437,11 +604,12 @@ LIB_EXPORT char *l_settings_to_data(const struct l_se=
ttings *settings,
 	group_entry =3D l_queue_get_entries(settings->groups);
 	while (group_entry) {
 		struct group_data *group =3D group_entry->data;
-		const struct l_queue_entry *setting_entry =3D
-				l_queue_get_entries(group->settings);
+		const struct l_queue_entry *setting_entry;
 =

 		l_string_append_printf(buf, "[%s]\n", group->name);
 =

+		setting_entry =3D l_queue_get_entries(group->settings);
+
 		while (setting_entry) {
 			struct setting_data *setting =3D setting_entry->data;
 =

@@ -456,6 +624,21 @@ LIB_EXPORT char *l_settings_to_data(const struct l_set=
tings *settings,
 		group_entry =3D group_entry->next;
 	}
 =

+	group_entry =3D l_queue_get_entries(settings->embedded_groups);
+
+	while (group_entry) {
+		struct embedded_group_data *group =3D group_entry->data;
+
+		l_string_append_printf(buf, "\n[@%s@%s]\n%s",
+					group->type,
+					group->name,
+					group->data);
+		if (group_entry->next)
+			l_string_append_c(buf, '\n');
+
+		group_entry =3D group_entry->next;
+	}
+
 	ret =3D l_string_unwrap(buf);
 =

 	if (len)
@@ -1176,3 +1359,72 @@ LIB_EXPORT bool l_settings_remove_key(struct l_setti=
ngs *settings,
 =

 	return true;
 }
+
+static void gather_embedded_groups(void *data, void *user_data)
+{
+	struct embedded_group_data *group_data =3D data;
+	struct gather_data *gather =3D user_data;
+
+	gather->v[gather->cur++] =3D l_strdup(group_data->name);
+}
+
+LIB_EXPORT char **l_settings_get_embedded_groups(struct l_settings *settin=
gs)
+{
+	char **ret;
+	struct gather_data gather;
+
+	if (unlikely(!settings))
+		return NULL;
+
+	ret =3D l_new(char *, l_queue_length(settings->groups) + 1);
+	gather.v =3D ret;
+	gather.cur =3D 0;
+
+	l_queue_foreach(settings->embedded_groups, gather_embedded_groups,
+				&gather);
+
+	return ret;
+}
+
+static bool embedded_group_match(const void *a, const void *b)
+{
+	const struct embedded_group_data *group =3D a;
+	const char *name =3D b;
+
+	return !strcmp(group->name, name);
+}
+
+LIB_EXPORT bool l_settings_has_embedded_group(struct l_settings *settings,
+						const char *group)
+{
+	struct embedded_group_data *group_data;
+
+	if (unlikely(!settings))
+		return false;
+
+	group_data =3D l_queue_find(settings->embedded_groups,
+					embedded_group_match, group);
+
+	return group_data !=3D NULL;
+}
+
+LIB_EXPORT const char *l_settings_get_embedded_value(
+						struct l_settings *settings,
+						const char *group_name,
+						const char **out_type)
+{
+	struct embedded_group_data *group;
+
+	if (unlikely(!settings))
+		return false;
+
+	group =3D l_queue_find(settings->embedded_groups,
+					embedded_group_match, group_name);
+	if (!group)
+		return NULL;
+
+	if (out_type)
+		*out_type =3D group->type;
+
+	return group->data;
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

--===============2597744437749920080==--

