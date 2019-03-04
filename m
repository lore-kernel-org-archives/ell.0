Content-Type: multipart/mixed; boundary="===============8732907102970953903=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 3/5] settings: Explicitly enable strto{u}ll() for C89.
Date: Mon, 04 Mar 2019 10:42:57 -0800
Message-ID: <20190304184259.22809-4-ossama.othman@intel.com>
In-Reply-To: <20190304184259.22809-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8732907102970953903==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The strtoll() and strtoull() functions were introduced in C99.  Define
_DEFAULT_SOURCE to enable them when building ELL with older C
standards, such as C89.  This addresses a run-time failure in
unit/test-settings when setting and getting 64 bit integers.
---
 ell/settings.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ell/settings.c b/ell/settings.c
index 0c06fe7..98823a2 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -24,6 +24,10 @@
 #include <config.h>
 #endif
 =

+#if __STDC_VERSION__ <=3D 199409L
+#define _DEFAULT_SOURCE  /* for strto{u}ll() */
+#endif
+
 #include <stdio.h>
 #include <stdlib.h>
 #include <strings.h>
-- =

2.17.1


--===============8732907102970953903==--

