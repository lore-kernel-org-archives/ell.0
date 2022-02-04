Content-Type: multipart/mixed; boundary="===============8509712323818013684=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH 2/5] unit: add settings test for clone APIs
Date: Fri, 04 Feb 2022 09:05:59 -0800
Message-ID: <20220204170603.216439-2-prestwoj@gmail.com>
In-Reply-To: 20220204170603.216439-1-prestwoj@gmail.com

--===============8509712323818013684==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-settings.c | 40 +++++++++++++++++++++++++++++++++++++++-
 1 file changed, 39 insertions(+), 1 deletion(-)

diff --git a/unit/test-settings.c b/unit/test-settings.c
index a25197a..d9f25f9 100644
--- a/unit/test-settings.c
+++ b/unit/test-settings.c
@@ -559,6 +559,44 @@ static void test_invalid_data(const void *test_data)
 	l_settings_free(settings);
 }
 =

+static void check_clone_data(struct l_settings *settings)
+{
+	const char *value;
+	const char *type =3D NULL;
+
+	assert(l_settings_has_group(settings, "normal"));
+	assert(l_settings_has_key(settings, "normal", "key"));
+	value =3D l_settings_get_value(settings, "normal", "key");
+	assert(value);
+	assert(!strcmp(value, "value"));
+
+	assert(l_settings_has_embedded_group(settings, "single_cert"));
+	value =3D l_settings_get_embedded_value(settings, "single_cert",
+								&type);
+	assert(value && type);
+	assert(!strcmp(type, "pem"));
+	assert(!strcmp(value, TEST_CERTIFICATE));
+}
+
+static void test_clone(const void *data)
+{
+	const char *raw_data =3D
+			"[normal]\n"
+			"key=3Dvalue\n"
+			"[@pem(a)single_cert]\n"
+			TEST_CERTIFICATE;
+
+	struct l_settings *settings =3D l_settings_new();
+	struct l_settings *copy;
+
+	assert(l_settings_load_from_data(settings, raw_data, strlen(raw_data)));
+	check_clone_data(settings);
+
+	copy =3D l_settings_clone(settings);
+	check_clone_data(copy);
+	l_settings_free(copy);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -571,7 +609,7 @@ int main(int argc, char *argv[])
 	l_test_add("Invalid Data 2", test_invalid_data, key_before_group_data);
 	l_test_add("Test valid ext group", test_valid_extended_group, NULL);
 	l_test_add("Test invalid ext group", test_invalid_extended_group, NULL);
-
+	l_test_add("Test clone", test_clone, NULL);
 =

 	return l_test_run();
 }
-- =

2.31.1

--===============8509712323818013684==--

