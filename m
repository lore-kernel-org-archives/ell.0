Content-Type: multipart/mixed; boundary="===============0241833890144092918=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 11/21] unit: Apply the DBus interface properties API change to
 the tests
Date: Thu, 13 Nov 2014 12:36:15 +0200
Message-ID: <1415874985-13034-12-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0241833890144092918==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use constant properties array instead of function calls.
---
 unit/test-dbus-service.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/unit/test-dbus-service.c b/unit/test-dbus-service.c
index 25b0951..825a159 100644
--- a/unit/test-dbus-service.c
+++ b/unit/test-dbus-service.c
@@ -143,7 +143,7 @@ static void test_introspect_signal(const void *test_dat=
a)
 static void test_introspect_property(const void *test_data)
 {
 	const struct introspect_test *test =3D test_data;
-	struct _dbus_property *property;
+	const struct l_dbus_property *property;
 	struct l_string *buf;
 	char *xml;
 =

@@ -342,6 +342,11 @@ static const struct l_dbus_signal sample_signals[] =3D=
 {
 	{ },
 };
 =

+static const struct l_dbus_property sample_properties[] =3D {
+	{ L_DBUS_RW_PROPERTY("Bar", "y") },
+	{ },
+};
+
 int main(int argc, char *argv[])
 {
 	int ret;
@@ -354,7 +359,7 @@ int main(int argc, char *argv[])
 =

 	_dbus_interface_signals(interface, sample_signals);
 =

-	l_dbus_interface_rw_property(interface, "Bar", "y");
+	_dbus_interface_properties(interface, sample_properties);
 =

 	l_test_add("Test Frobate Introspection", test_introspect_method,
 			&frobate_test);
-- =

2.0.4


--===============0241833890144092918==--

