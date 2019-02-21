Content-Type: multipart/mixed; boundary="===============3009547625066665852=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 2/2] unit: test-settings: added test with no group
Date: Thu, 21 Feb 2019 10:22:16 -0800
Message-ID: <20190221182216.29956-2-james.prestwood@linux.intel.com>
In-Reply-To: <20190221182216.29956-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3009547625066665852==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-settings.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/unit/test-settings.c b/unit/test-settings.c
index c31c379..71f3341 100644
--- a/unit/test-settings.c
+++ b/unit/test-settings.c
@@ -290,6 +290,20 @@ static void test_to_data(const void *test_data)
 	l_settings_free(settings);
 }
 =

+static const char *no_group_data =3D "key_without_group=3Dvalue\n";
+
+static void test_invalid_data(const void *test_data)
+{
+	struct l_settings *settings;
+	bool r;
+
+	settings =3D l_settings_new();
+
+	r =3D l_settings_load_from_data(settings, no_group_data,
+					strlen(no_group_data));
+	assert(r =3D=3D false);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -298,6 +312,7 @@ int main(int argc, char *argv[])
 	l_test_add("Load from File", test_load_from_file, NULL);
 	l_test_add("Set Methods", test_set_methods, NULL);
 	l_test_add("Export to Data 1", test_to_data, data2);
+	l_test_add("Invalid Data (no group)", test_invalid_data, NULL);
 =

 	return l_test_run();
 }
-- =

2.17.1


--===============3009547625066665852==--

