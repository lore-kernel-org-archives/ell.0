Content-Type: multipart/mixed; boundary="===============8527047183966779987=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/4] unit: Add warning about key quota setting in test-tls
Date: Thu, 17 Jan 2019 18:19:16 +0100
Message-ID: <20190117171916.27960-4-andrew.zaborowski@intel.com>
In-Reply-To: <20190117171916.27960-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8527047183966779987==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index ebca9aa..a69e708 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -26,6 +26,7 @@
 =

 #include <assert.h>
 #include <stdio.h>
+#include <unistd.h>
 =

 #include <ell/ell.h>
 =

@@ -618,9 +619,26 @@ static void test_tls_suite_test(const void *data)
 	test_tls_with_ver(&test, 0, 0);
 }
 =

+static int read_int_from_file(const char *path)
+{
+	int ret;
+	FILE *file;
+
+	file =3D fopen(path, "r");
+	if (!file)
+		return 0;
+
+	if (fscanf(file, "%i", &ret) < 1)
+		ret =3D 0;
+
+	fclose(file);
+	return ret;
+}
+
 int main(int argc, char *argv[])
 {
 	unsigned int i;
+	int maxkeys;
 =

 	l_test_init(&argc, &argv);
 =

@@ -667,6 +685,13 @@ int main(int argc, char *argv[])
 		goto done;
 	}
 =

+	maxkeys =3D read_int_from_file(getuid() > 0 ?
+					"/proc/sys/kernel/keys/maxkeys" :
+					"/proc/sys/kernel/keys/root_maxkeys");
+	if (maxkeys && maxkeys < 2000)
+		printf("Running sysctl kernel.keys.%s=3D2000 is recommended\n",
+			getuid() > 0 ? "maxkeys" : "root_maxkeys");
+
 	l_test_add("TLS connection no auth", test_tls_test,
 			&tls_conn_test_no_auth);
 	l_test_add("TLS connection server auth", test_tls_test,
-- =

2.19.1


--===============8527047183966779987==--

