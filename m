Content-Type: multipart/mixed; boundary="===============8670831210148794691=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/5] unit: Update for l_string_free changes
Date: Wed, 02 Nov 2016 14:50:45 -0700
Message-ID: <20161102215048.19166-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20161102215048.19166-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8670831210148794691==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-service.c | 10 +++++-----
 unit/test-string.c       | 10 +++++-----
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/unit/test-dbus-service.c b/unit/test-dbus-service.c
index c27869b..269e0e6 100644
--- a/unit/test-dbus-service.c
+++ b/unit/test-dbus-service.c
@@ -116,7 +116,7 @@ static void test_introspect_method(const void *test_dat=
a)
 =

 	buf =3D l_string_new(0);
 	_dbus_method_introspection(method, buf);
-	xml =3D l_string_free(buf, false);
+	xml =3D l_string_unwrap(buf);
 =

 	assert(!strcmp(test->expected_xml, xml));
 	l_free(xml);
@@ -134,7 +134,7 @@ static void test_introspect_signal(const void *test_dat=
a)
 =

 	buf =3D l_string_new(0);
 	_dbus_signal_introspection(signal, buf);
-	xml =3D l_string_free(buf, false);
+	xml =3D l_string_unwrap(buf);
 =

 	assert(!strcmp(test->expected_xml, xml));
 	l_free(xml);
@@ -152,7 +152,7 @@ static void test_introspect_property(const void *test_d=
ata)
 =

 	buf =3D l_string_new(0);
 	_dbus_property_introspection(property, buf);
-	xml =3D l_string_free(buf, false);
+	xml =3D l_string_unwrap(buf);
 =

 	assert(!strcmp(test->expected_xml, xml));
 	l_free(xml);
@@ -166,7 +166,7 @@ static void test_introspect_interface(const void *test_=
data)
 =

 	buf =3D l_string_new(0);
 	_dbus_interface_introspection(interface, buf);
-	xml =3D l_string_free(buf, false);
+	xml =3D l_string_unwrap(buf);
 =

 	assert(!strcmp(test->expected_xml, xml));
 	l_free(xml);
@@ -358,7 +358,7 @@ static void test_dbus_object_tree_introspection(const v=
oid *test_data)
 =

 	buf =3D l_string_new(1024);
 	_dbus_object_tree_introspect(tree, "/", buf);
-	xml =3D l_string_free(buf, false);
+	xml =3D l_string_unwrap(buf);
 	assert(!strcmp(ofono_manager_introspection, xml));
 	l_free(xml);
 =

diff --git a/unit/test-string.c b/unit/test-string.c
index 4c6a38c..d5b0d9d 100644
--- a/unit/test-string.c
+++ b/unit/test-string.c
@@ -40,7 +40,7 @@ static void test_grow(const void *test_data)
 	assert(l_string_append(str, "BarFoo"));
 	assert(l_string_length(str) =3D=3D strlen("Foobar7BarFoo"));
 =

-	a =3D l_string_free(str, false);
+	a =3D l_string_unwrap(str);
 	assert(a);
 	assert(!strcmp(a, "Foobar7BarFoo"));
 =

@@ -60,7 +60,7 @@ static void test_printf(const void *test_data)
 =

 	assert(l_string_length(str) =3D=3D strlen("Foobar7100BarFoo"));
 =

-	a =3D l_string_free(str, false);
+	a =3D l_string_unwrap(str);
 	assert(a);
 	assert(!strcmp(a, "Foobar7100BarFoo"));
 =

@@ -107,7 +107,7 @@ static void test_fixed(const void *test_data)
 	l_string_append_fixed(str, test->input, test->input_len);
 	assert(l_string_length(str) =3D=3D strlen(test->expected));
 =

-	a =3D l_string_free(str, false);
+	a =3D l_string_unwrap(str);
 	assert(a);
 	assert(!strcmp(a, test->expected));
 =

@@ -125,7 +125,7 @@ static void test_truncate(const void *test_data)
 	assert(!l_string_truncate(NULL, 8));
 =

 	assert(l_string_truncate(str, 7));
-	a =3D l_string_free(str, false);
+	a =3D l_string_unwrap(str);
 	assert(a);
 	assert(!strcmp(a, "Foobar7"));
 	l_free(a);
@@ -134,7 +134,7 @@ static void test_truncate(const void *test_data)
 	l_string_append(str, "Foobar7");
 	assert(l_string_truncate(str, 3));
 	l_string_append_c(str, '4');
-	a =3D l_string_free(str, false);
+	a =3D l_string_unwrap(str);
 	assert(a);
 	assert(!strcmp(a, "Foo4"));
 	l_free(a);
-- =

2.10.2


--===============8670831210148794691==--

