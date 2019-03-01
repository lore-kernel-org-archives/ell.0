Content-Type: multipart/mixed; boundary="===============1833893105752676855=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH 2/2] unit: Sanity check for NULL l_uintset
Date: Thu, 28 Feb 2019 16:51:30 -0800
Message-ID: <20190301005130.29851-2-tim.a.kourt@linux.intel.com>
In-Reply-To: <20190301005130.29851-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1833893105752676855==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-uintset.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/unit/test-uintset.c b/unit/test-uintset.c
index 35fc935..9f20939 100644
--- a/unit/test-uintset.c
+++ b/unit/test-uintset.c
@@ -120,6 +120,20 @@ static void test_uintset_3(const void *data)
 	l_uintset_free(set);
 }
 =

+static void test_uintset_4(const void *data)
+{
+	struct l_uintset *set;
+
+	set =3D l_uintset_new(2);
+	assert(set);
+
+	assert(!l_uintset_take(NULL, 1));
+	assert(!l_uintset_put(NULL, 1));
+	assert(!l_uintset_contains(NULL, 1));
+
+	l_uintset_free(set);
+}
+
 static void test_uintset_find_unused(const void *data)
 {
 	struct l_uintset *set;
@@ -167,6 +181,7 @@ int main(int argc, char *argv[])
 	l_test_add("l_uintset sanity check", test_uintset, NULL);
 	l_test_add("l_uintset sanity check #2", test_uintset_2, NULL);
 	l_test_add("l_uintset sanity check #3", test_uintset_3, NULL);
+	l_test_add("l_uintset sanity check #4", test_uintset_4, NULL);
 	l_test_add("l_uintset find unused tests", test_uintset_find_unused,
 							NULL);
 =

-- =

2.13.6


--===============1833893105752676855==--

