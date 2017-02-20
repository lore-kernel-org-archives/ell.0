Content-Type: multipart/mixed; boundary="===============0364263998981539002=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/3] unit: Test dbus property setters returning method return
Date: Tue, 21 Feb 2017 00:30:36 +0100
Message-ID: <20170220233036.8741-3-andrew.zaborowski@intel.com>
In-Reply-To: <20170220233036.8741-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0364263998981539002==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The "String" property now tests that the complete callback works for
setters while the "Integer" property tests that a method return message
can be returned from the setter directly.
---
 unit/test-dbus-properties.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index 08916b3..a184deb 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -274,9 +274,7 @@ static struct l_dbus_message *test_int_setter(struct l_=
dbus *dbus,
 	setter_called =3D true;
 =

 done:
-	complete(dbus, message, NULL);
-
-	return NULL;
+	return l_dbus_message_new_method_return(message);
 }
 =

 static struct l_dbus_message *test_error_setter(struct l_dbus *dbus,
-- =

2.9.3


--===============0364263998981539002==--

