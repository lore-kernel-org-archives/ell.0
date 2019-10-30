Content-Type: multipart/mixed; boundary="===============3481808084512202873=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] genl: Include system header to fix build warning
Date: Wed, 30 Oct 2019 13:16:07 -0700
Message-ID: <20191030201607.21168-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3481808084512202873==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The l_genl_msg_append_attrv() declaration in genl.h uses struct iovec *,
but there's no guarantee that sys/uio.h has been included already (and
the genl user might not need that header itself). Within the ell code,
uio.h is already included by util.h which prevents build errors in ell
itself.
---
 ell/genl.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/genl.h b/ell/genl.h
index 5df688b..3a37ed5 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -26,6 +26,7 @@
 #include <stdbool.h>
 #include <stddef.h>
 #include <stdint.h>
+#include <sys/uio.h>
 =

 #ifdef __cplusplus
 extern "C" {
-- =

2.23.0

--===============3481808084512202873==--

