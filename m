Content-Type: multipart/mixed; boundary="===============8983774513036004260=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH 1/5] settings: add l_settings_clone
Date: Fri, 04 Feb 2022 09:05:58 -0800
Message-ID: <20220204170603.216439-1-prestwoj@gmail.com>

--===============8983774513036004260==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Returns identical copy of settings
---
 ell/ell.sym    |  1 +
 ell/settings.c | 62 ++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/settings.h |  2 ++
 3 files changed, 65 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 60c5525..827e68c 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -452,6 +452,7 @@ global:
 	l_ringbuf_append;
 	/* settings */
 	l_settings_new;
+	l_settings_clone;
 	l_settings_free;
 	l_settings_load_from_data;
 	l_settings_to_data;
diff --git a/ell/settings.c b/ell/settings.c
index 6958e12..a553ec0 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -116,6 +116,68 @@ LIB_EXPORT struct l_settings *l_settings_new(void)
 	return settings;
 }
 =

+static void copy_key_value_foreach(void *data, void *user_data)
+{
+	struct setting_data *s =3D data;
+	struct l_queue *settings =3D user_data;
+	struct setting_data *copy =3D l_new(struct setting_data, 1);
+
+	copy->key =3D l_strdup(s->key);
+	copy->value =3D l_strdup(s->value);
+
+	l_queue_push_head(settings, copy);
+}
+
+static void copy_group_foreach(void *data, void *user_data)
+{
+	struct group_data *group =3D data;
+	struct l_queue *groups =3D user_data;
+	struct group_data *copy =3D l_new(struct group_data, 1);
+
+	copy->name =3D l_strdup(group->name);
+	copy->settings =3D l_queue_new();
+
+	l_queue_push_head(groups, copy);
+
+	l_queue_foreach(group->settings, copy_key_value_foreach,
+				copy->settings);
+}
+
+static void copy_embedded_foreach(void *data, void *user_data)
+{
+	struct embedded_group_data *embedded =3D data;
+	struct l_queue *groups =3D user_data;
+	struct embedded_group_data *copy;
+
+	copy =3D l_malloc(sizeof(struct embedded_group_data) +
+					embedded->len + 1);
+	copy->name =3D l_strdup(embedded->name);
+
+	memcpy(copy->type, embedded->type, sizeof(embedded->type));
+	copy->len =3D embedded->len;
+	memcpy(copy->data, embedded->data, embedded->len);
+	copy->data[embedded->len] =3D '\0';
+
+	l_queue_push_tail(groups, copy);
+}
+
+LIB_EXPORT struct l_settings *l_settings_clone(
+					const struct l_settings *settings)
+{
+	struct l_settings *copy;
+
+	if (unlikely(!settings))
+		return NULL;
+
+	copy =3D l_settings_new();
+
+	l_queue_foreach(settings->groups, copy_group_foreach, copy->groups);
+	l_queue_foreach(settings->embedded_groups, copy_embedded_foreach,
+				copy->embedded_groups);
+
+	return copy;
+}
+
 LIB_EXPORT void l_settings_free(struct l_settings *settings)
 {
 	if (unlikely(!settings))
diff --git a/ell/settings.h b/ell/settings.h
index 9262ab9..f094ef5 100644
--- a/ell/settings.h
+++ b/ell/settings.h
@@ -37,6 +37,8 @@ typedef void (*l_settings_debug_cb_t) (const char *str, v=
oid *user_data);
 typedef void (*l_settings_destroy_cb_t) (void *user_data);
 =

 struct l_settings *l_settings_new(void);
+struct l_settings *l_settings_clone(const struct l_settings *settings);
+
 void l_settings_free(struct l_settings *settings);
 DEFINE_CLEANUP_FUNC(l_settings_free);
 =

-- =

2.31.1

--===============8983774513036004260==--

