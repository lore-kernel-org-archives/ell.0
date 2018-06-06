Content-Type: multipart/mixed; boundary="===============7121230681499109245=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] genl: Include <stddef.h> for size_t typedef.
Date: Wed, 06 Jun 2018 15:34:23 -0700
Message-ID: <20180606223423.30240-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7121230681499109245==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The l_genl_msg_append_attrv() prototype in the ELL genl.h header uses
the size_t typedef.  Explicitly include <stddef.h> to pull in the
size_t typedef declaration in case the user directly includes
<ell/genl.h> without, or prior to, other headers that would have done
the same.  This addresses an "unknown type name" compile-time error in
such a case.
---
 ell/genl.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/genl.h b/ell/genl.h
index bddf1d4..ff5687c 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -24,6 +24,7 @@
 #define __ELL_GENL_H
 =

 #include <stdbool.h>
+#include <stddef.h>
 #include <stdint.h>
 =

 #ifdef __cplusplus
-- =

2.17.1


--===============7121230681499109245==--

