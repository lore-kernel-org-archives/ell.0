Content-Type: multipart/mixed; boundary="===============4939554016240020740=="
MIME-Version: 1.0
From: Inga Stotland <inga.stotland@intel.com>
Subject: [PATCH] tester: Fix includes
Date: Wed, 17 Mar 2021 12:36:34 -0700
Message-ID: <20210317193634.263341-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4939554016240020740==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Include proper header files, only those that are required.
---
 ell/tester.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/ell/tester.c b/ell/tester.c
index ebebc1d..eedd66b 100644
--- a/ell/tester.c
+++ b/ell/tester.c
@@ -24,6 +24,7 @@
 #include <config.h>
 #endif
 =

+#define _GNU_SOURCE
 #include <getopt.h>
 #include <stdio.h>
 #include <stdlib.h>
@@ -31,10 +32,12 @@
 =

 #include <sys/time.h>
 =

-#include <ell/ell.h>
-
+#include "idle.h"
 #include "log.h"
 #include "private.h"
+#include "queue.h"
+#include "time.h"
+#include "timeout.h"
 #include "useful.h"
 #include "tester.h"
 =

-- =

2.26.2

--===============4939554016240020740==--

