Content-Type: multipart/mixed; boundary="===============4120403156102887267=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] unit: Fix typos that make the assertions always true
Date: Fri, 29 Apr 2016 05:31:56 +0200
Message-ID: <1461900728-20662-4-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4120403156102887267==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-message.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/unit/test-dbus-message.c b/unit/test-dbus-message.c
index ce58769..c8e2059 100644
--- a/unit/test-dbus-message.c
+++ b/unit/test-dbus-message.c
@@ -1501,7 +1501,7 @@ static void parse_basic_5(const void *data)
 =

 	result =3D l_dbus_message_get_arguments(msg, "q", &val);
 	assert(result);
-	assert(val =3D 42);
+	assert(val =3D=3D 42);
 =

 	l_dbus_message_unref(msg);
 }
@@ -1524,7 +1524,7 @@ static void parse_basic_6(const void *data)
 =

 	result =3D l_dbus_message_get_arguments(msg, "u", &val);
 	assert(result);
-	assert(val =3D 4711);
+	assert(val =3D=3D 4711);
 =

 	l_dbus_message_unref(msg);
 }
@@ -1546,7 +1546,7 @@ static void parse_basic_7(const void *data)
 =

 	result =3D l_dbus_message_get_arguments(msg, "t", &val);
 	assert(result);
-	assert(val =3D 10000);
+	assert(val =3D=3D 10000);
 =

 	l_dbus_message_unref(msg);
 }
@@ -1614,7 +1614,7 @@ static void parse_basic_10(const void *data)
 =

 	result =3D l_dbus_message_get_arguments(msg, "x", &val);
 	assert(result);
-	assert(val =3D -10000);
+	assert(val =3D=3D -10000);
 =

 	l_dbus_message_unref(msg);
 }
@@ -1637,7 +1637,7 @@ static void parse_basic_11(const void *data)
 =

 	result =3D l_dbus_message_get_arguments(msg, "d", &val);
 	assert(result);
-	assert(val =3D M_PI);
+	assert(val =3D=3D M_PI);
 =

 	l_dbus_message_unref(msg);
 }
-- =

2.5.0


--===============4120403156102887267==--

