Content-Type: multipart/mixed; boundary="===============5527265614827021887=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 5/5] tools: Only include required ELL headers.
Date: Mon, 29 Oct 2018 13:07:15 -0700
Message-ID: <20181029200715.28427-6-ossama.othman@intel.com>
In-Reply-To: <20181029200715.28427-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5527265614827021887==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Limit build side effects caused by enabling or disabling C library
features through C standard related compiler flags (e.g. -std=3Dc99) by
only including the required ELL headers.
---
 tools/certchain-verify.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/tools/certchain-verify.c b/tools/certchain-verify.c
index 1800f68..e8d8374 100644
--- a/tools/certchain-verify.c
+++ b/tools/certchain-verify.c
@@ -26,13 +26,16 @@
 #include <errno.h>
 #include <stdint.h>
 #include <stdbool.h>
+#include <stdlib.h>
+#include <string.h>
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <fcntl.h>
 #include <unistd.h>
 #include <sys/mman.h>
 =

-#include <ell/ell.h>
+#include <ell/log.h>
+#include <ell/util.h>
 #include "ell/tls-private.h"
 =

 static int load_cert_chain(const char *file, struct tls_cert **certchain)
-- =

2.17.1


--===============5527265614827021887==--

