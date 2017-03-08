Content-Type: multipart/mixed; boundary="===============1649256229360255843=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 2/2] log: Fixed missing L_STRINGIFY macro definition
Date: Wed, 08 Mar 2017 12:29:25 -0800
Message-ID: <1489004965-19931-3-git-send-email-ossama.othman@intel.com>
In-Reply-To: <1489004965-19931-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1649256229360255843==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The l_log() macro in the <ell/log.h> header uses the L_STRINGIFY
macro defined in <ell/util.h> but doesn't include that header.  That
triggered a compile-time error in some cases where <ell/util.h> was
not indirectly pulled in before <ell/log.h>.
---
 ell/log.c | 1 -
 ell/log.h | 2 ++
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/log.c b/ell/log.c
index 8891d0a..e6682cf 100644
--- a/ell/log.c
+++ b/ell/log.c
@@ -34,7 +34,6 @@
 #include <sys/socket.h>
 #include <sys/un.h>
 =

-#include "util.h"
 #include "log.h"
 #include "private.h"
 =

diff --git a/ell/log.h b/ell/log.h
index 670cef2..916f08b 100644
--- a/ell/log.h
+++ b/ell/log.h
@@ -26,6 +26,8 @@
 #include <stdarg.h>
 #include <stdbool.h>
 =

+#include <ell/util.h>
+
 #ifdef __cplusplus
 extern "C" {
 #endif
-- =

2.7.4


--===============1649256229360255843==--

