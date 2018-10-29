Content-Type: multipart/mixed; boundary="===============7622432528116599462=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 3/5] dbus-client: Only include required ELL headers.
Date: Mon, 29 Oct 2018 13:07:13 -0700
Message-ID: <20181029200715.28427-4-ossama.othman@intel.com>
In-Reply-To: <20181029200715.28427-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7622432528116599462==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Reduce dependencies in ell/dbus-client.c by only including the ELL
headers it requires rather than the <ell/ell.h> convenience header.
This also limits build side effects caused by enabling or disabling
C library features through C standard related compiler flags
(e.g. -std=3Dc99).
---
 ell/dbus-client.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/ell/dbus-client.c b/ell/dbus-client.c
index 1628b67..d2eb70f 100644
--- a/ell/dbus-client.c
+++ b/ell/dbus-client.c
@@ -25,7 +25,9 @@
 #include <config.h>
 #endif
 =

-#include "ell.h"
+#include "dbus.h"
+#include "dbus-client.h"
+#include "queue.h"
 #include "private.h"
 =

 struct l_dbus_client {
-- =

2.17.1


--===============7622432528116599462==--

