Content-Type: multipart/mixed; boundary="===============4936859955432598139=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH v3 2/4] gvariant: dbus.h need to be included before private
 header
Date: Wed, 18 Feb 2015 18:08:34 +0200
Message-ID: <1424275716-7198-3-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1424275716-7198-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4936859955432598139==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Needed by dbus watcher unit tests which add stuff to private
header file.
---
 ell/gvariant-util.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index 8fb32c7..7534509 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -37,9 +37,9 @@
 #include "queue.h"
 #include "string.h"
 #include "log.h"
+#include "dbus.h"
 #include "dbus-private.h"
 #include "gvariant-private.h"
-#include "dbus.h"
 =

 static const char *simple_types =3D "sogybnqiuxtdh";
 static const char *variable_types =3D "sogav";
-- =

2.1.0


--===============4936859955432598139==--

