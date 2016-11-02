Content-Type: multipart/mixed; boundary="===============7267734176808265151=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH] settings: Make getters const correct
Date: Wed, 02 Nov 2016 12:49:24 -0700
Message-ID: <1478116164-41113-1-git-send-email-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7267734176808265151==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/settings.c | 31 ++++++++++++++++---------------
 ell/settings.h | 44 ++++++++++++++++++++++++++------------------
 2 files changed, 42 insertions(+), 33 deletions(-)

diff --git a/ell/settings.c b/ell/settings.c
index c6eec35..078150a 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -394,7 +394,8 @@ LIB_EXPORT bool l_settings_load_from_data(struct l_sett=
ings *settings,
 	return r;
 }
 =

-LIB_EXPORT char *l_settings_to_data(struct l_settings *settings, size_t *l=
en)
+LIB_EXPORT char *l_settings_to_data(const struct l_settings *settings,
+								size_t *len)
 {
 	struct l_string *buf;
 	char *ret;
@@ -520,7 +521,7 @@ static void gather_groups(void *data, void *user_data)
 	gather->v[gather->cur++] =3D l_strdup(group_data->name);
 }
 =

-LIB_EXPORT char **l_settings_get_groups(struct l_settings *settings)
+LIB_EXPORT char **l_settings_get_groups(const struct l_settings *settings)
 {
 	char **ret;
 	struct gather_data gather;
@@ -537,7 +538,7 @@ LIB_EXPORT char **l_settings_get_groups(struct l_settin=
gs *settings)
 	return ret;
 }
 =

-LIB_EXPORT bool l_settings_has_group(struct l_settings *settings,
+LIB_EXPORT bool l_settings_has_group(const struct l_settings *settings,
 					const char *group_name)
 {
 	struct group_data *group;
@@ -566,7 +567,7 @@ static void gather_keys(void *data, void *user_data)
 	gather->v[gather->cur++] =3D l_strdup(setting_data->key);
 }
 =

-LIB_EXPORT char **l_settings_get_keys(struct l_settings *settings,
+LIB_EXPORT char **l_settings_get_keys(const struct l_settings *settings,
 					const char *group_name)
 {
 	char **ret;
@@ -589,7 +590,7 @@ LIB_EXPORT char **l_settings_get_keys(struct l_settings=
 *settings,
 	return ret;
 }
 =

-LIB_EXPORT bool l_settings_has_key(struct l_settings *settings,
+LIB_EXPORT bool l_settings_has_key(const struct l_settings *settings,
 					const char *group_name, const char *key)
 {
 	struct group_data *group;
@@ -607,7 +608,7 @@ LIB_EXPORT bool l_settings_has_key(struct l_settings *s=
ettings,
 	return !!setting;
 }
 =

-LIB_EXPORT const char *l_settings_get_value(struct l_settings *settings,
+LIB_EXPORT const char *l_settings_get_value(const struct l_settings *setti=
ngs,
 						const char *group_name,
 						const char *key)
 {
@@ -719,7 +720,7 @@ LIB_EXPORT bool l_settings_set_value(struct l_settings =
*settings,
 	return set_value(settings, group_name, key, l_strdup(value));
 }
 =

-LIB_EXPORT bool l_settings_get_bool(struct l_settings *settings,
+LIB_EXPORT bool l_settings_get_bool(const struct l_settings *settings,
 					const char *group_name, const char *key,
 					bool *out)
 {
@@ -765,7 +766,7 @@ LIB_EXPORT bool l_settings_set_bool(struct l_settings *=
settings,
 	return l_settings_set_value(settings, group_name, key, v);
 }
 =

-LIB_EXPORT bool l_settings_get_int(struct l_settings *settings,
+LIB_EXPORT bool l_settings_get_int(const struct l_settings *settings,
 					const char *group_name,
 					const char *key, int *out)
 {
@@ -812,7 +813,7 @@ LIB_EXPORT bool l_settings_set_int(struct l_settings *s=
ettings,
 	return l_settings_set_value(settings, group_name, key, buf);
 }
 =

-LIB_EXPORT bool l_settings_get_uint(struct l_settings *settings,
+LIB_EXPORT bool l_settings_get_uint(const struct l_settings *settings,
 					const char *group_name, const char *key,
 					unsigned int *out)
 {
@@ -859,7 +860,7 @@ LIB_EXPORT bool l_settings_set_uint(struct l_settings *=
settings,
 	return l_settings_set_value(settings, group_name, key, buf);
 }
 =

-LIB_EXPORT bool l_settings_get_int64(struct l_settings *settings,
+LIB_EXPORT bool l_settings_get_int64(const struct l_settings *settings,
 					const char *group_name, const char *key,
 					int64_t *out)
 {
@@ -905,7 +906,7 @@ LIB_EXPORT bool l_settings_set_int64(struct l_settings =
*settings,
 	return l_settings_set_value(settings, group_name, key, buf);
 }
 =

-LIB_EXPORT bool l_settings_get_uint64(struct l_settings *settings,
+LIB_EXPORT bool l_settings_get_uint64(const struct l_settings *settings,
 					const char *group_name, const char *key,
 					uint64_t *out)
 {
@@ -951,7 +952,7 @@ LIB_EXPORT bool l_settings_set_uint64(struct l_settings=
 *settings,
 	return l_settings_set_value(settings, group_name, key, buf);
 }
 =

-LIB_EXPORT char *l_settings_get_string(struct l_settings *settings,
+LIB_EXPORT char *l_settings_get_string(const struct l_settings *settings,
 					const char *group_name, const char *key)
 {
 	const char *value =3D l_settings_get_value(settings, group_name, key);
@@ -976,7 +977,7 @@ LIB_EXPORT bool l_settings_set_string(struct l_settings=
 *settings,
 	return set_value(settings, group_name, key, buf);
 }
 =

-LIB_EXPORT char **l_settings_get_string_list(struct l_settings *settings,
+LIB_EXPORT char **l_settings_get_string_list(const struct l_settings *sett=
ings,
 						const char *group_name,
 						const char *key,
 						const char delimiter)
@@ -1015,7 +1016,7 @@ LIB_EXPORT bool l_settings_set_string_list(struct l_s=
ettings *settings,
 	return set_value(settings, group_name, key, buf);
 }
 =

-LIB_EXPORT bool l_settings_get_double(struct l_settings *settings,
+LIB_EXPORT bool l_settings_get_double(const struct l_settings *settings,
 					const char *group_name, const char *key,
 					double *out)
 {
@@ -1061,7 +1062,7 @@ LIB_EXPORT bool l_settings_set_double(struct l_settin=
gs *settings,
 	return l_settings_set_value(settings, group_name, key, buf);
 }
 =

-LIB_EXPORT bool l_settings_get_float(struct l_settings *settings,
+LIB_EXPORT bool l_settings_get_float(const struct l_settings *settings,
 					const char *group_name, const char *key,
 					float *out)
 {
diff --git a/ell/settings.h b/ell/settings.h
index 718c1d7..0da9f55 100644
--- a/ell/settings.h
+++ b/ell/settings.h
@@ -40,7 +40,7 @@ void l_settings_free(struct l_settings *settings);
 =

 bool l_settings_load_from_data(struct l_settings *settings,
 						const char *data, size_t len);
-char *l_settings_to_data(struct l_settings *settings, size_t *len);
+char *l_settings_to_data(const struct l_settings *settings, size_t *len);
 =

 bool l_settings_load_from_file(struct l_settings *settings,
 					const char *filename);
@@ -50,50 +50,56 @@ bool l_settings_set_debug(struct l_settings *settings,
 				void *user_data,
 				l_settings_destroy_cb_t destroy);
 =

-char **l_settings_get_groups(struct l_settings *settings);
-char **l_settings_get_keys(struct l_settings *settings, const char *group_=
name);
+char **l_settings_get_groups(const struct l_settings *settings);
+char **l_settings_get_keys(const struct l_settings *settings,
+							const char *group_name);
 =

-bool l_settings_has_group(struct l_settings *settings, const char *group_n=
ame);
-bool l_settings_has_key(struct l_settings *settings, const char *group_nam=
e,
-			const char *key);
+bool l_settings_has_group(const struct l_settings *settings,
+							const char *group_name);
+bool l_settings_has_key(const struct l_settings *settings,
+				const char *group_name, const char *key);
 =

-const char *l_settings_get_value(struct l_settings *settings,
+const char *l_settings_get_value(const struct l_settings *settings,
 					const char *group_name,
 					const char *key);
 bool l_settings_set_value(struct l_settings *settings, const char *group_n=
ame,
 				const char *key, const char *value);
 =

-bool l_settings_get_bool(struct l_settings *settings, const char *group_na=
me,
+bool l_settings_get_bool(const struct l_settings *settings,
+				const char *group_name,
 				const char *key, bool *out);
 bool l_settings_set_bool(struct l_settings *settings, const char *group_na=
me,
 				const char *key, bool in);
 =

-bool l_settings_get_int(struct l_settings *settings, const char *group_nam=
e,
-				const char *key, int *out);
+bool l_settings_get_int(const struct l_settings *settings,
+			const char *group_name, const char *key, int *out);
 bool l_settings_set_int(struct l_settings *settings, const char *group_nam=
e,
 				const char *key, int in);
 =

-bool l_settings_get_uint(struct l_settings *settings, const char *group_na=
me,
+bool l_settings_get_uint(const struct l_settings *settings,
+				const char *group_name,
 				const char *key, unsigned int *out);
 bool l_settings_set_uint(struct l_settings *settings, const char *group_na=
me,
 				const char *key, unsigned int in);
 =

-bool l_settings_get_int64(struct l_settings *settings, const char *group_n=
ame,
+bool l_settings_get_int64(const struct l_settings *settings,
+				const char *group_name,
 				const char *key, int64_t *out);
 bool l_settings_set_int64(struct l_settings *settings, const char *group_n=
ame,
 				const char *key, int64_t in);
 =

-bool l_settings_get_uint64(struct l_settings *settings, const char *group_=
name,
+bool l_settings_get_uint64(const struct l_settings *settings,
+				const char *group_name,
 				const char *key, uint64_t *out);
 bool l_settings_set_uint64(struct l_settings *settings, const char *group_=
name,
 				const char *key, uint64_t in);
 =

-char *l_settings_get_string(struct l_settings *settings, const char *group=
_name,
-				const char *key);
+char *l_settings_get_string(const struct l_settings *settings,
+				const char *group_name, const char *key);
 bool l_settings_set_string(struct l_settings *settings, const char *group_=
name,
 				const char *key, const char *value);
 =

-char **l_settings_get_string_list(struct l_settings *settings,
+char **l_settings_get_string_list(const struct l_settings *settings,
 					const char *group_name,
 					const char *key, char delimiter);
 bool l_settings_set_string_list(struct l_settings *settings,
@@ -101,12 +107,14 @@ bool l_settings_set_string_list(struct l_settings *se=
ttings,
 					const char *key, char **list,
 					char delimiter);
 =

-bool l_settings_get_double(struct l_settings *settings, const char *group_=
name,
+bool l_settings_get_double(const struct l_settings *settings,
+				const char *group_name,
 				const char *key, double *out);
 bool l_settings_set_double(struct l_settings *settings, const char *group_=
name,
 				const char *key, double in);
 =

-bool l_settings_get_float(struct l_settings *settings, const char *group_n=
ame,
+bool l_settings_get_float(const struct l_settings *settings,
+				const char *group_name,
 				const char *key, float *out);
 bool l_settings_set_float(struct l_settings *settings, const char *group_n=
ame,
 				const char *key, float in);
-- =

2.5.5


--===============7267734176808265151==--

