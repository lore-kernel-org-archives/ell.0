Content-Type: multipart/mixed; boundary="===============1800344613446271324=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v3 2/2] unit: settings: add another invalid data case
Date: Thu, 21 Feb 2019 14:33:55 -0800
Message-ID: <20190221223355.31790-2-james.prestwood@linux.intel.com>
In-Reply-To: <20190221223355.31790-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1800344613446271324==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This case has an ungrouped value come before a group, which is
invalid and should not load.
---
 unit/test-settings.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/unit/test-settings.c b/unit/test-settings.c
index 71f3341..4d4fb68 100644
--- a/unit/test-settings.c
+++ b/unit/test-settings.c
@@ -291,17 +291,22 @@ static void test_to_data(const void *test_data)
 }
 =

 static const char *no_group_data =3D "key_without_group=3Dvalue\n";
+static const char *key_before_group_data =3D "key_without_group=3Dvalue\n"
+						"[GROUP]\n"
+						"valid_key=3Dvalue\n";
 =

 static void test_invalid_data(const void *test_data)
 {
+	const char *data =3D test_data;
 	struct l_settings *settings;
 	bool r;
 =

 	settings =3D l_settings_new();
 =

-	r =3D l_settings_load_from_data(settings, no_group_data,
-					strlen(no_group_data));
+	r =3D l_settings_load_from_data(settings, data, strlen(data));
 	assert(r =3D=3D false);
+
+	l_settings_free(settings);
 }
 =

 int main(int argc, char *argv[])
@@ -312,7 +317,8 @@ int main(int argc, char *argv[])
 	l_test_add("Load from File", test_load_from_file, NULL);
 	l_test_add("Set Methods", test_set_methods, NULL);
 	l_test_add("Export to Data 1", test_to_data, data2);
-	l_test_add("Invalid Data (no group)", test_invalid_data, NULL);
+	l_test_add("Invalid Data 1", test_invalid_data, no_group_data);
+	l_test_add("Invalid Data 2", test_invalid_data, key_before_group_data);
 =

 	return l_test_run();
 }
-- =

2.17.1


--===============1800344613446271324==--

