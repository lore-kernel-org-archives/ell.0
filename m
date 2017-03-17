Content-Type: multipart/mixed; boundary="===============5427086790742774403=="
MIME-Version: 1.0
From: Lukas Rusak <lrusak@libreelec.tv>
Subject: [PATCH 5/5] docs: remove kdbus
Date: Fri, 17 Mar 2017 13:10:31 -0700
Message-ID: <20170317201031.4927-5-lrusak@libreelec.tv>
In-Reply-To: <20170317201031.4927-1-lrusak@libreelec.tv>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5427086790742774403==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Lukas Rusak <lorusak@gmail.com>

---
 README | 9 ---------
 TODO   | 8 ++------
 2 files changed, 2 insertions(+), 15 deletions(-)

diff --git a/README b/README
index c1ac931..eaff57c 100644
--- a/README
+++ b/README
@@ -44,15 +44,6 @@ Kernel configuration checklist:
 =

 	CONFIG_KEY_DH_OPERATIONS=3Dy
 =

-For kernel D-Bus (kdbus) support, the appropriate kernel module is required
-and must be loaded. The development repositories can be found here:
-
-	https://github.com/gregkh/kdbus
-	https://code.google.com/p/d-bus/
-
-If /dev/kdbus/control device node is present, kernel D-Bus support can be
-used.
-
 Information
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
 =

diff --git a/TODO b/TODO
index 8ffa455..27bc35f 100644
--- a/TODO
+++ b/TODO
@@ -23,12 +23,8 @@ DBus API
   mechanisms specified in the DBus specification.  Whenever a given signal
   matches one of the filters, the relevant callback function should be cal=
led.
 =

-  For KDBus this implies calculating and installing proper bloom filters. =
 For
-  DBus classic this implies managing a set of appropriate filters with the=
 DBus
-  daemon as specified in the DBus specification.
-
-  Note that certain filtering mechanisms which are possible with DBus clas=
sic
-  are likely not possible with KDBus.
+  For DBus classic this implies managing a set of appropriate filters with=
 the =

+  DBus daemon as specified in the DBus specification.
 =

   Priority: Medium
   Complexity: C4
-- =

2.9.3


--===============5427086790742774403==--

