Content-Type: multipart/mixed; boundary="===============8687783218674419666=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH 2/2] unit: Add l_uintset_foreach tests
Date: Wed, 06 Mar 2019 14:03:11 -0800
Message-ID: <20190306220311.18897-2-tim.a.kourt@linux.intel.com>
In-Reply-To: <20190306220311.18897-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8687783218674419666==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-uintset.c | 98 +++++++++++++++++++++++++++++++++++++++++++++++++=
+++-
 1 file changed, 97 insertions(+), 1 deletion(-)

diff --git a/unit/test-uintset.c b/unit/test-uintset.c
index 42d9698..4488cd9 100644
--- a/unit/test-uintset.c
+++ b/unit/test-uintset.c
@@ -2,7 +2,7 @@
  *
  *  Embedded Linux library
  *
- *  Copyright (C) 2015  Intel Corporation. All rights reserved.
+ *  Copyright (C) 2015-2019  Intel Corporation. All rights reserved.
  *
  *  This library is free software; you can redistribute it and/or
  *  modify it under the terms of the GNU Lesser General Public
@@ -167,6 +167,101 @@ static void test_uintset_find_unused(const void *data)
 	l_uintset_free(set);
 }
 =

+static void uintset_foreach(uint32_t number, void *user_data)
+{
+	struct l_uintset *check =3D user_data;
+
+	l_uintset_take(check, number);
+}
+
+static void test_uintset_foreach(const void *data)
+{
+	struct l_uintset *set;
+	struct l_uintset *check;
+	int i;
+
+	set =3D l_uintset_new_from_range(0, 63);
+	check =3D l_uintset_new_from_range(0, 63);
+	assert(set);
+	assert(check);
+
+	for (i =3D 0; i < 64; i++) {
+		assert(l_uintset_put(set, i));
+		assert(l_uintset_put(check, i));
+	}
+
+	l_uintset_foreach(set, uintset_foreach, check);
+	assert(l_uintset_find_max(check) =3D=3D 64);
+
+	l_uintset_free(set);
+	l_uintset_free(check);
+
+	set =3D l_uintset_new_from_range(0, 127);
+	check =3D l_uintset_new_from_range(0, 127);
+	assert(set);
+	assert(check);
+
+	assert(l_uintset_put(set, 127));
+	assert(l_uintset_put(check, 127));
+
+	l_uintset_foreach(set, uintset_foreach, check);
+	assert(l_uintset_find_max(check) =3D=3D 128);
+
+	l_uintset_free(set);
+	l_uintset_free(check);
+
+	set =3D l_uintset_new_from_range(0, 191);
+	check =3D l_uintset_new_from_range(0, 191);
+	assert(set);
+	assert(check);
+
+	assert(l_uintset_put(set, 50));
+	assert(l_uintset_put(check, 50));
+	assert(l_uintset_put(set, 150));
+	assert(l_uintset_put(check, 150));
+
+	l_uintset_foreach(set, uintset_foreach, check);
+	assert(l_uintset_find_max(check) =3D=3D 192);
+
+	l_uintset_free(set);
+	l_uintset_free(check);
+
+	set =3D l_uintset_new_from_range(0, 192);
+	check =3D l_uintset_new_from_range(0, 192);
+	assert(set);
+	assert(check);
+
+	assert(l_uintset_put(set, 0));
+	assert(l_uintset_put(check, 0));
+	assert(l_uintset_put(set, 63));
+	assert(l_uintset_put(check, 63));
+	assert(l_uintset_put(set, 120));
+	assert(l_uintset_put(check, 120));
+
+	l_uintset_foreach(set, uintset_foreach, check);
+	assert(l_uintset_find_max(check) =3D=3D 193);
+
+	l_uintset_free(set);
+	l_uintset_free(check);
+
+	set =3D l_uintset_new_from_range(0, 192);
+	check =3D l_uintset_new_from_range(0, 192);
+	assert(set);
+	assert(check);
+
+	assert(l_uintset_put(set, 0));
+	assert(l_uintset_put(check, 0));
+
+	assert(l_uintset_put(set, 192));
+	assert(l_uintset_put(check, 192));
+
+	l_uintset_foreach(set, uintset_foreach, check);
+	assert(l_uintset_find_max(check) =3D=3D 193);
+
+	l_uintset_free(set);
+	l_uintset_free(check);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -175,6 +270,7 @@ int main(int argc, char *argv[])
 	l_test_add("l_uintset sanity check #2", test_uintset_2, NULL);
 	l_test_add("l_uintset sanity check #3", test_uintset_3, NULL);
 	l_test_add("l_uintset sanity check #4", test_uintset_4, NULL);
+	l_test_add("l_uintset for each tests", test_uintset_foreach, NULL);
 	l_test_add("l_uintset find unused tests", test_uintset_find_unused,
 							NULL);
 =

-- =

2.13.6


--===============8687783218674419666==--

