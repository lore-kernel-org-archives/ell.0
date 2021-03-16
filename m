Content-Type: multipart/mixed; boundary="===============7574951113555851506=="
MIME-Version: 1.0
From: Inga Stotland <inga.stotland@intel.com>
Subject: [PATCH] tester: Add missing include for useful.h
Date: Tue, 16 Mar 2021 14:02:57 -0700
Message-ID: <20210316210257.118138-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7574951113555851506==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tester.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/tester.c b/ell/tester.c
index 5c5386e..ebebc1d 100644
--- a/ell/tester.c
+++ b/ell/tester.c
@@ -35,6 +35,7 @@
 =

 #include "log.h"
 #include "private.h"
+#include "useful.h"
 #include "tester.h"
 =

 /**
-- =

2.26.2

--===============7574951113555851506==--

