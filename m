Content-Type: multipart/mixed; boundary="===============8210713177730732134=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2][RFC] unit: Emit PropertyChanged in setters in
 test-dbus-service
Date: Thu, 30 Aug 2018 03:05:41 +0200
Message-ID: <20180830010541.8687-2-andrew.zaborowski@intel.com>
In-Reply-To: <20180830010541.8687-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8210713177730732134==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Send the property change signals in the setter now that it's not done
automatically.  Note that the signals are now sent before the Set method
return message.
---
 unit/test-dbus-properties.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index db89ec5..e0a2bfe 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -211,6 +211,9 @@ static struct l_dbus_message *test_string_setter(struct=
 l_dbus *dbus,
 =

 	setter_called =3D true;
 =

+	l_dbus_property_changed(dbus, l_dbus_message_get_path(message),
+				"org.test", "String");
+
 done:
 	complete(dbus, message, NULL);
 =

@@ -248,6 +251,9 @@ static struct l_dbus_message *test_int_setter(struct l_=
dbus *dbus,
 =

 	setter_called =3D true;
 =

+	l_dbus_property_changed(dbus, l_dbus_message_get_path(message),
+				"org.test", "Integer");
+
 done:
 	return l_dbus_message_new_method_return(message);
 }
-- =

2.17.1


--===============8210713177730732134==--

