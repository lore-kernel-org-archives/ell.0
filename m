Content-Type: multipart/mixed; boundary="===============6627939926460958382=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH] idle: Include stdbool.h by default in the header
Date: Wed, 12 Nov 2014 15:53:34 +0200
Message-ID: <1415800414-1391-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6627939926460958382==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
idlers use bool, but it's not included by their header.
Figured that one when playing with a unit test.

 ell/idle.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/idle.h b/ell/idle.h
index a75bc9b..19ae4d3 100644
--- a/ell/idle.h
+++ b/ell/idle.h
@@ -23,6 +23,8 @@
 #ifndef __ELL_IDLE_H
 #define __ELL_IDLE_H
 =

+#include <stdbool.h>
+
 #ifdef __cplusplus
 extern "C" {
 #endif
-- =

2.0.4


--===============6627939926460958382==--

