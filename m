Content-Type: multipart/mixed; boundary="===============0754244025256816919=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 2/5] settings: Include strings.h for strcasecmp() proto
Date: Mon, 29 Oct 2018 13:07:12 -0700
Message-ID: <20181029200715.28427-3-ossama.othman@intel.com>
In-Reply-To: <20181029200715.28427-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0754244025256816919==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Restricting the C standard supported by compiler, e.g. to C99, can
prevent some function prototypes from being indirectly pulled in, as
is the case for strcasecmp().  Include <strings.h> to explicitly pull
in its prototype.
---
 ell/settings.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/settings.c b/ell/settings.c
index 539263b..08a7748 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -26,6 +26,7 @@
 =

 #include <stdio.h>
 #include <stdlib.h>
+#include <strings.h>  // strcasecmp
 #include <errno.h>
 #include <sys/types.h>
 #include <sys/stat.h>
-- =

2.17.1


--===============0754244025256816919==--

