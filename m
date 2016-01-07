Content-Type: multipart/mixed; boundary="===============0937850009046193399=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] util: Fix skipped characters in strsplit functions
Date: Thu, 07 Jan 2016 13:43:39 -0800
Message-ID: <1452203019-3232-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0937850009046193399==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_strsplit and l_strsplit_sep were skipping an extra character after
each delimiter because len was incremented after being set to 0 but
before the next iteration of the loop began. This caused problems with
trailing and consecutive delimiters. Added strings with varying
delimiters to tests and made sure len is set back to 0.
---
 ell/util.c         | 36 ++++++++++++++++++++++--------------
 unit/test-string.c | 32 +++++++++++++++++++++++++++++++-
 2 files changed, 53 insertions(+), 15 deletions(-)

diff --git a/ell/util.c b/ell/util.c
index 5bd7b3b..d1e7079 100644
--- a/ell/util.c
+++ b/ell/util.c
@@ -293,13 +293,17 @@ LIB_EXPORT char **l_strsplit(const char *str, const c=
har sep)
 =

 	ret =3D l_new(char *, len + 1);
 =

-	for (i =3D 0, p =3D str, len =3D 0; p[len]; len++) {
-		if (p[len] !=3D sep)
-			continue;
-
-		ret[i++] =3D l_strndup(p, len);
-		p +=3D len + 1;
-		len =3D 0;
+	i =3D 0;
+	p =3D str;
+	len =3D 0;
+	while (p[len]) {
+		if (p[len] !=3D sep) {
+			len++;
+		} else {
+			ret[i++] =3D l_strndup(p, len);
+			p +=3D len + 1;
+			len =3D 0;
+		}
 	}
 =

 	ret[i++] =3D l_strndup(p, len);
@@ -347,13 +351,17 @@ LIB_EXPORT char **l_strsplit_set(const char *str, con=
st char *separators)
 =

 	ret =3D l_new(char *, len + 1);
 =

-	for (i =3D 0, p =3D str, len =3D 0; p[len]; len++) {
-		if (sep_table[(unsigned char) p[len]] !=3D true)
-			continue;
-
-		ret[i++] =3D l_strndup(p, len);
-		p +=3D len + 1;
-		len =3D 0;
+	i =3D 0;
+	p =3D str;
+	len =3D 0;
+	while (p[len]) {
+		if (sep_table[(unsigned char) p[len]] !=3D true) {
+			len++;
+		} else {
+			ret[i++] =3D l_strndup(p, len);
+			p +=3D len + 1;
+			len =3D 0;
+		}
 	}
 =

 	ret[i++] =3D l_strndup(p, len);
diff --git a/unit/test-string.c b/unit/test-string.c
index 388e90f..d2f8bd4 100644
--- a/unit/test-string.c
+++ b/unit/test-string.c
@@ -124,6 +124,22 @@ static void test_strsplit(const void *test_data)
 	assert(!strcmp(strv[2], "bz"));
 	assert(strv[3] =3D=3D NULL);
 	l_strfreev(strv);
+
+	l_strsplit(":bar:bz", ':');
+	assert(strv);
+	assert(!strcmp(strv[0], ""));
+	assert(!strcmp(strv[1], "bar"));
+	assert(!strcmp(strv[2], "bz"));
+	assert(strv[3] =3D=3D NULL);
+	l_strfreev(strv);
+
+	l_strsplit("Foo:bar:", ':');
+	assert(strv);
+	assert(!strcmp(strv[0], "Foo"));
+	assert(!strcmp(strv[1], "bar"));
+	assert(!strcmp(strv[2], ""));
+	assert(strv[3] =3D=3D NULL);
+	l_strfreev(strv);
 }
 =

 static void test_strsplit_set(const void *test_data)
@@ -137,6 +153,20 @@ static void test_strsplit_set(const void *test_data)
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
@@ -175,7 +205,7 @@ int main(int argc, char *argv[])
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


--===============0937850009046193399==--

