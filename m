Content-Type: multipart/mixed; boundary="===============0817879688275093051=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/2] unit: Additional strsplit cases with more delimiter
 variety
Date: Thu, 07 Jan 2016 16:26:51 -0800
Message-ID: <1452212811-7026-2-git-send-email-mathew.j.martineau@linux.intel.com>
In-Reply-To: <1452212811-7026-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0817879688275093051==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-string.c | 34 +++++++++++++++++++++++++++++++++-
 1 file changed, 33 insertions(+), 1 deletion(-)

diff --git a/unit/test-string.c b/unit/test-string.c
index 388e90f..156f658 100644
--- a/unit/test-string.c
+++ b/unit/test-string.c
@@ -124,6 +124,24 @@ static void test_strsplit(const void *test_data)
 	assert(!strcmp(strv[2], "bz"));
 	assert(strv[3] =3D=3D NULL);
 	l_strfreev(strv);
+
+	strv =3D l_strsplit(":bar:::bz", ':');
+	assert(strv);
+	assert(!strcmp(strv[0], ""));
+	assert(!strcmp(strv[1], "bar"));
+	assert(!strcmp(strv[2], ""));
+	assert(!strcmp(strv[3], ""));
+	assert(!strcmp(strv[4], "bz"));
+	assert(strv[5] =3D=3D NULL);
+	l_strfreev(strv);
+
+	strv =3D l_strsplit("Foo:bar:", ':');
+	assert(strv);
+	assert(!strcmp(strv[0], "Foo"));
+	assert(!strcmp(strv[1], "bar"));
+	assert(!strcmp(strv[2], ""));
+	assert(strv[3] =3D=3D NULL);
+	l_strfreev(strv);
 }
 =

 static void test_strsplit_set(const void *test_data)
@@ -137,6 +155,20 @@ static void test_strsplit_set(const void *test_data)
 	assert(!strcmp(strv[3], "Blu"));
 	assert(strv[4] =3D=3D NULL);
 	l_strfreev(strv);
+
+	strv =3D l_strsplit_set("Foo:bar,Baz Blu,:,Fee:Fie ", ":, ");
+	assert(strv);
+	assert(!strcmp(strv[0], "Foo"));
+	assert(!strcmp(strv[1], "bar"));
+	assert(!strcmp(strv[2], "Baz"));
+	assert(!strcmp(strv[3], "Blu"));
+	assert(!strcmp(strv[4], ""));
+	assert(!strcmp(strv[5], ""));
+	assert(!strcmp(strv[6], "Fee"));
+	assert(!strcmp(strv[7], "Fie"));
+	assert(!strcmp(strv[8], ""));
+	assert(strv[9] =3D=3D NULL);
+	l_strfreev(strv);
 }
 =

 static void test_joinv(const void *test_data)
@@ -175,7 +207,7 @@ int main(int argc, char *argv[])
 	l_test_add("append_fixed test 2", test_fixed, &fixed_test2);
 	l_test_add("append_fixed test 3", test_fixed, &fixed_test3);
 =

-	l_test_add("strplit", test_strsplit, NULL);
+	l_test_add("strsplit", test_strsplit, NULL);
 	l_test_add("strsplit_set", test_strsplit_set, NULL);
 =

 	l_test_add("joinv", test_joinv, NULL);
-- =

2.7.0


--===============0817879688275093051==--

