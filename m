Content-Type: multipart/mixed; boundary="===============7169810272364108145=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/2] unit: Remove unused header include
Date: Wed, 05 Oct 2016 11:25:52 -0700
Message-ID: <20161005182552.8850-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20161005182552.8850-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7169810272364108145==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-cipher.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/unit/test-cipher.c b/unit/test-cipher.c
index a958402..eaf97a0 100644
--- a/unit/test-cipher.c
+++ b/unit/test-cipher.c
@@ -27,7 +27,6 @@
 #include <assert.h>
 =

 #include <ell/ell.h>
-#include <ell/cipher-private.h>
 =

 #define FIXED_STR  "The quick brown fox jumps over the lazy dog. " \
 		   "Jackdaws love my big sphinx of quartz. "       \
-- =

2.10.1


--===============7169810272364108145==--

