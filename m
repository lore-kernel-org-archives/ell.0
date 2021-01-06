Content-Type: multipart/mixed; boundary="===============0377506836849101207=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/8] unit: Add an L_IN_SET test
Date: Wed, 06 Jan 2021 20:54:40 +0100
Message-ID: <20210106195446.1428769-2-andrew.zaborowski@intel.com>
In-Reply-To: <20210106195446.1428769-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0377506836849101207==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-util.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/unit/test-util.c b/unit/test-util.c
index 883319c..067a708 100644
--- a/unit/test-util.c
+++ b/unit/test-util.c
@@ -124,6 +124,27 @@ static void test_strlcpy(const void *test_data)
 	do_strlcpy(10, 12);
 }
 =

+static void test_in_set(const void *test_data)
+{
+	char *a1 =3D "a";
+	const char *a2 =3D a1;
+
+	assert(L_IN_SET(1, 1, 2, 3));
+	assert(L_IN_SET(2U, 1, 2, 3));
+	assert(L_IN_SET(3LL, 1, 2, 3));
+	assert(!L_IN_SET(4, 1, 2, 3));
+	assert(!L_IN_SET(4));
+
+	assert(L_IN_STRSET(a1, a2, "b"));
+	assert(L_IN_STRSET(a2, a1, "b"));
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
@@ -136,5 +157,7 @@ int main(int argc, char *argv[])
 =

 	l_test_add("l_strlcpy", test_strlcpy, NULL);
 =

+	l_test_add("L_IN_SET", test_in_set, NULL);
+
 	return l_test_run();
 }
-- =

2.27.0

--===============0377506836849101207==--

