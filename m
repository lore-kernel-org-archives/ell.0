Content-Type: multipart/mixed; boundary="===============6644080684721605868=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 1/2] main: Fixed missing uint32_t typedef error
Date: Wed, 08 Mar 2017 12:29:24 -0800
Message-ID: <1489004965-19931-2-git-send-email-ossama.othman@intel.com>
In-Reply-To: <1489004965-19931-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6644080684721605868==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Include <stdint.h> in <ell/main.h> to address a compile-time error
that occurred when including the latter header alone.
---
 ell/main.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/main.h b/ell/main.h
index c23ec55..ed0c76f 100644
--- a/ell/main.h
+++ b/ell/main.h
@@ -24,6 +24,7 @@
 #define __ELL_MAIN_H
 =

 #include <stdbool.h>
+#include <stdint.h>
 =

 #ifdef __cplusplus
 extern "C" {
-- =

2.7.4


--===============6644080684721605868==--

