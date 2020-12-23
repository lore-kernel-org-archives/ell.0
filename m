Content-Type: multipart/mixed; boundary="===============5162911215582421752=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 6/8] unit: Add an L_IN_SET test
Date: Thu, 24 Dec 2020 00:14:35 +0100
Message-ID: <20201223231437.1078130-6-andrew.zaborowski@intel.com>
In-Reply-To: <20201223231437.1078130-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5162911215582421752==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-util.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/unit/test-util.c b/unit/test-util.c
index 883319c..dc74913 100644
--- a/unit/test-util.c
+++ b/unit/test-util.c
@@ -124,6 +124,25 @@ static void test_strlcpy(const void *test_data)
 	do_strlcpy(10, 12);
 }
 =

+static void test_in_set(const void *test_data)
+{
+	char a[2] =3D "a";
+
+	assert(L_IN_SET(1, 1, 2, 3));
+	assert(L_IN_SET(2U, 1, 2, 3));
+	assert(L_IN_SET(3LL, 1, 2, 3));
+	assert(!L_IN_SET(4, 1, 2, 3));
+	assert(!L_IN_SET(4));
+
+	assert(L_IN_STRSET(a, a, "b"));
+	assert(L_IN_STRSET("b", "a", "b"));
+	assert(!L_IN_STRSET("c", "a", "b"));
+	assert(L_IN_STRSET(NULL, "a", NULL));
+	assert(!L_IN_STRSET(NULL, "a", "b"));
+	assert(!L_IN_STRSET("a", NULL, NULL));
+	assert(!L_IN_STRSET("a"));
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -136,5 +155,7 @@ int main(int argc, char *argv[])
 =

 	l_test_add("l_strlcpy", test_strlcpy, NULL);
 =

+	l_test_add("L_IN_SET", test_in_set, NULL);
+
 	return l_test_run();
 }
-- =

2.27.0

--===============5162911215582421752==--

