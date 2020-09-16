Content-Type: multipart/mixed; boundary="===============0074106520278862501=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] settings: Add l_settings_{set,get}_bytes
Date: Wed, 16 Sep 2020 03:11:07 +0200
Message-ID: <20200916011108.508987-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0074106520278862501==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
I went for "bytes" instead of "hexstring" because the latter is the
encoding while the former is the type of data stored.
---
 ell/ell.sym    |  2 ++
 ell/settings.c | 37 +++++++++++++++++++++++++++++++++++++
 ell/settings.h |  7 +++++++
 3 files changed, 46 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 044cf3c..66e0f08 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -444,6 +444,8 @@ global:
 	l_settings_set_double;
 	l_settings_get_float;
 	l_settings_set_float;
+	l_settings_get_bytes;
+	l_settings_set_bytes;
 	l_settings_remove_group;
 	l_settings_remove_key;
 	l_settings_has_embedded_group;
diff --git a/ell/settings.c b/ell/settings.c
index dac45c9..68f7a4a 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -1325,6 +1325,43 @@ LIB_EXPORT bool l_settings_set_float(struct l_settin=
gs *settings,
 	return l_settings_set_value(settings, group_name, key, buf);
 }
 =

+LIB_EXPORT uint8_t *l_settings_get_bytes(const struct l_settings *settings,
+						const char *group_name,
+						const char *key,
+						size_t *out_len)
+{
+	const char *value =3D l_settings_get_value(settings, group_name, key);
+
+	if (!value)
+		return NULL;
+
+	if (value[0] =3D=3D '\0') {
+		*out_len =3D 0;
+
+		/* Return something that can be l_freed but is not a NULL */
+		return l_memdup("", 1);
+	}
+
+	return l_util_from_hexstring(value, out_len);
+}
+
+LIB_EXPORT bool l_settings_set_bytes(struct l_settings *settings,
+					const char *group_name, const char *key,
+					const uint8_t *value, size_t value_len)
+{
+	char *buf;
+
+	if (unlikely(!settings || !value))
+		return false;
+
+	if (value_len)
+		buf =3D l_util_hexstring(value, value_len);
+	else
+		buf =3D l_strdup("");
+
+	return set_value(settings, group_name, key, buf);
+}
+
 LIB_EXPORT bool l_settings_remove_group(struct l_settings *settings,
 					const char *group_name)
 {
diff --git a/ell/settings.h b/ell/settings.h
index e4203af..f95ed9b 100644
--- a/ell/settings.h
+++ b/ell/settings.h
@@ -119,6 +119,13 @@ bool l_settings_get_float(const struct l_settings *set=
tings,
 bool l_settings_set_float(struct l_settings *settings, const char *group_n=
ame,
 				const char *key, float in);
 =

+uint8_t *l_settings_get_bytes(const struct l_settings *settings,
+				const char *group_name, const char *key,
+				size_t *out_len);
+bool l_settings_set_bytes(struct l_settings *settings, const char *group_n=
ame,
+				const char *key,
+				const uint8_t *value, size_t value_len);
+
 bool l_settings_remove_key(struct l_settings *settings, const char *group_=
name,
 				const char *key);
 bool l_settings_remove_group(struct l_settings *settings,
-- =

2.25.1

--===============0074106520278862501==--

