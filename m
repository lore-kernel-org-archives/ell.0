Content-Type: multipart/mixed; boundary="===============8801274005099112204=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 4/5] settings: introduce extended groups concept
Date: Fri, 27 Sep 2019 12:30:08 -0700
Message-ID: <20190927193009.30262-5-prestwoj@gmail.com>
In-Reply-To: <20190927193009.30262-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8801274005099112204==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This patch introduces a new extended format for settings files. This new
format allows raw data to be provided under a given group rather than
key/value pairs. A group using an extended format will contain both the
extended type and group name in the format, for example:

[@pem(a)certificate]

Where 'pem' is the type and 'certificate' is the name. The type of
format requries an extension specific parser implementation in settings
as the parser must know when to start/stop parsing data. This allows for
any textual characters to be present after the group is declared,
including special characters like [] (its completely up to the parser to
decide whats valid and what is not).

Two new l_settings APIs were added:

l_settings_is_extended_group
l_settings_get_extended_data

In this patch, the 'pem' extension type is also introduced, and for now
is the only extended type. The pem extended type expects a base64 encoded
PEM (or list of PEMs) after the group. The pem parser will stop after the
last PEM is found. Examples can be found in unit/test-settings.c
---
 ell/ell.sym    |   2 +
 ell/settings.c | 231 +++++++++++++++++++++++++++++++++++++++++++++++--
 ell/settings.h |   5 ++
 3 files changed, 233 insertions(+), 5 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index e02f0fe..13e3fd8 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -425,6 +425,8 @@ global:
 	l_settings_set_float;
 	l_settings_remove_group;
 	l_settings_remove_key;
+	l_settings_is_extended_group;
+	l_settings_get_extended_data;
 	/* signal */
 	l_signal_create;
 	l_signal_remove;
diff --git a/ell/settings.c b/ell/settings.c
index 98f0cfd..b8f61b4 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -48,6 +48,7 @@
 #include "settings.h"
 #include "private.h"
 #include "missing.h"
+#include "pem-private.h"
 =

 struct setting_data {
 	char *key;
@@ -57,6 +58,9 @@ struct setting_data {
 struct group_data {
 	char *name;
 	struct l_queue *settings;
+	/* settings and ext_data/type are mutually exclusive */
+	char *ext_type;
+	char *ext_data;
 };
 =

 struct l_settings {
@@ -81,7 +85,13 @@ static void group_destroy(void *data)
 	struct group_data *group =3D data;
 =

 	l_free(group->name);
-	l_queue_destroy(group->settings, setting_destroy);
+
+	if (group->settings)
+		l_queue_destroy(group->settings, setting_destroy);
+	else {
+		l_free(group->ext_data);
+		l_free(group->ext_type);
+	}
 =

 	l_free(group);
 }
@@ -222,6 +232,168 @@ static char *escape_value(const char *value)
 	return ret;
 }
 =

+/*
+ * The PEM APIs deal with unsigned bytes since they ultimately end up deco=
ding
+ * the base64 into a raw buffer. Since we are using these to just return t=
he
+ * already encoded PEMs as textual data we are using char *. These macros =
just
+ * take care of the casting between the two.
+ */
+#define IS_PEM_START(buf, len, llen) \
+	(const char *)pem_is_start_boundary((const uint8_t *)buf, len, llen)
+
+#define IS_PEM_END(buf, len, label, llen) \
+	pem_is_end_boundary((const uint8_t *)buf, len, \
+				(const uint8_t *)label, label_len)
+
+static const char *next_eol(const char *data, size_t len)
+{
+	const char *eol;
+
+	for (eol =3D data; eol < data + len; eol++)
+		if (*eol =3D=3D '\r' || *eol =3D=3D '\n')
+			break;
+
+	return eol;
+}
+
+/*
+ * This was modeled after pem_load_buffer, except actually decoding the da=
ta
+ * is not done. Support for parsing multiple PEMS in a row (chain) was also
+ * added.
+ */
+static bool parse_pem(const char *data, size_t total_len, size_t *data_len)
+{
+	const char *eol;
+	const char *label;
+	size_t label_len;
+	const char *start =3D NULL;
+
+	while (total_len) {
+		eol =3D next_eol(data, total_len);
+
+		if (!start) {
+			label =3D IS_PEM_START(data, eol - data, &label_len);
+			if (label)
+				start =3D label - strlen("-----BEGIN ");
+		} else if (start && IS_PEM_END(data, eol - data,
+						label, label_len)) {
+			const char *new_eol;
+
+			new_eol =3D next_eol(eol + 1, total_len - (eol - data));
+
+			label =3D IS_PEM_START(eol + 1, new_eol - eol - 1,
+							&label_len);
+			if (!label) {
+				/* No more PEMs in chain */
+				*data_len =3D eol - start + 1;
+				return true;
+			}
+
+			/* Continue to next PEM */
+			eol =3D new_eol;
+		}
+
+		if (eol =3D=3D data + total_len)
+			break;
+
+		total_len -=3D eol + 1 - data;
+		data =3D eol + 1;
+
+		if (total_len && *eol =3D=3D '\r' && *data =3D=3D '\n') {
+			data++;
+			total_len--;
+		}
+	}
+
+	return false;
+}
+
+struct group_extension {
+	char *name;
+	bool (*parse)(const char *data, size_t total_len, size_t *data_len);
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
+static bool parse_extended_group(struct l_settings *setting, const char *d=
ata,
+					size_t line_len, size_t total_len,
+					size_t *offset)
+{
+	struct group_data *group;
+	struct group_extension *ext;
+	char *ptr1, *ptr2;
+	char *type, *name;
+
+	/* Must be at least [@a(a)b]\n */
+	if (line_len < 7)
+		return false;
+
+	/* extended type */
+	ptr1 =3D strchr(data, '@');
+	if (!ptr1)
+		return false;
+
+	ptr2 =3D strchr(ptr1 + 1, '@');
+	if (!ptr2)
+		return false;
+
+	type =3D l_strndup(ptr1 + 1, ptr2 - ptr1 - 1);
+
+	ptr1 =3D strchr(ptr2, ']');
+	if (!ptr1)
+		goto free_type;
+
+	if (ptr1[1] !=3D '\n')
+		goto free_type;
+
+	if (ptr1 - ptr2 - 1 < 1)
+		goto free_type;
+
+	name =3D l_strndup(ptr2 + 1, ptr1 - ptr2 - 1);
+
+	ext =3D find_group_extension(type);
+	if (!ext)
+		goto free_name;
+
+	if (!ext->parse(ptr1 + 2, total_len - line_len, offset))
+		goto free_name;
+
+	group =3D l_new(struct group_data, 1);
+	group->name =3D name;
+	group->ext_type =3D type;
+	group->ext_data =3D l_strndup(ptr1 + 2, *offset);
+
+	l_queue_push_tail(setting->groups, group);
+
+	return true;
+
+free_name:
+	l_free(name);
+free_type:
+	l_free(type);
+	return false;
+}
+
 static bool parse_group(struct l_settings *settings, const char *data,
 			size_t len, size_t line)
 {
@@ -382,6 +554,7 @@ LIB_EXPORT bool l_settings_load_from_data(struct l_sett=
ings *settings,
 	const char *eol;
 	size_t line =3D 1;
 	size_t line_len;
+	size_t ext_offset =3D 0;
 =

 	if (unlikely(!settings || !data || !len))
 		return false;
@@ -404,7 +577,19 @@ LIB_EXPORT bool l_settings_load_from_data(struct l_set=
tings *settings,
 =

 		line_len =3D eol - data - pos;
 =

-		if (data[pos] =3D=3D '[') {
+		if (data[pos] =3D=3D '[' && data[pos + 1] =3D=3D '@') {
+			r =3D parse_extended_group(settings, data + pos,
+							line_len, len - pos,
+							&ext_offset);
+			if (!r)
+				return false;
+
+			/*
+			 * This is the offset for the actual raw data, the
+			 * group line will be offset below
+			 */
+			pos +=3D ext_offset;
+		} else if (data[pos] =3D=3D '[') {
 			r =3D parse_group(settings, data + pos, line_len, line);
 			if (r)
 				has_group =3D true;
@@ -437,10 +622,17 @@ LIB_EXPORT char *l_settings_to_data(const struct l_se=
ttings *settings,
 	group_entry =3D l_queue_get_entries(settings->groups);
 	while (group_entry) {
 		struct group_data *group =3D group_entry->data;
-		const struct l_queue_entry *setting_entry =3D
-				l_queue_get_entries(group->settings);
+		const struct l_queue_entry *setting_entry;
+
+		if (group->ext_data) {
+			l_string_append_printf(buf, "[@%s@%s]\n%s",
+						group->ext_type, group->name,
+						group->ext_data);
+			goto group_done;
+		} else
+			l_string_append_printf(buf, "[%s]\n", group->name);
 =

-		l_string_append_printf(buf, "[%s]\n", group->name);
+		setting_entry =3D l_queue_get_entries(group->settings);
 =

 		while (setting_entry) {
 			struct setting_data *setting =3D setting_entry->data;
@@ -450,6 +642,7 @@ LIB_EXPORT char *l_settings_to_data(const struct l_sett=
ings *settings,
 			setting_entry =3D setting_entry->next;
 		}
 =

+group_done:
 		if (group_entry->next)
 			l_string_append_c(buf, '\n');
 =

@@ -1176,3 +1369,31 @@ LIB_EXPORT bool l_settings_remove_key(struct l_setti=
ngs *settings,
 =

 	return true;
 }
+
+LIB_EXPORT bool l_settings_is_extended_group(struct l_settings *settings,
+							const char *group)
+{
+	struct group_data *group_data;
+
+	if (unlikely(!settings))
+		return false;
+
+	group_data =3D l_queue_find(settings->groups, group_match, group);
+
+	return group_data->ext_data !=3D NULL;
+}
+
+LIB_EXPORT const char *l_settings_get_extended_data(struct l_settings *set=
tings,
+							const char *group_name)
+{
+	struct group_data *group;
+
+	if (unlikely(!settings))
+		return false;
+
+	group =3D l_queue_find(settings->groups, group_match, group_name);
+	if (!group || !group->ext_data)
+		return NULL;
+
+	return group->ext_data;
+}
diff --git a/ell/settings.h b/ell/settings.h
index 0da9f55..bf7bc44 100644
--- a/ell/settings.h
+++ b/ell/settings.h
@@ -123,6 +123,11 @@ bool l_settings_remove_key(struct l_settings *settings=
, const char *group_name,
 				const char *key);
 bool l_settings_remove_group(struct l_settings *settings,
 				const char *group_name);
+
+bool l_settings_is_extended_group(struct l_settings *settings,
+					const char *group);
+const char *l_settings_get_extended_data(struct l_settings *settings,
+						const char *group);
 #ifdef __cplusplus
 }
 #endif
-- =

2.17.1


--===============8801274005099112204==--

