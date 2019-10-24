Content-Type: multipart/mixed; boundary="===============0396236929071293427=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] random: Seed the fallback random number generator
Date: Thu, 24 Oct 2019 09:57:49 -0700
Message-ID: <20191024165749.19904-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0396236929071293427==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The random() PRNG is used as a fallback in case of getrandom() syscall
failure.  However, the PRNG was not seeded prior to initial use,
resulting in the same predictable sequence of numbers being generated.
Explicitly seed the PRNG on initial use with random data retrieved
from the ELF binary loader to decrease predictability.
---
 ell/random.c | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/ell/random.c b/ell/random.c
index 0b5b09e..99aa06e 100644
--- a/ell/random.c
+++ b/ell/random.c
@@ -28,6 +28,8 @@
 #include <errno.h>
 #include <unistd.h>
 #include <stdlib.h>
+#include <time.h>
+#include <sys/auxv.h>
 #include <sys/syscall.h>
 =

 #include "random.h"
@@ -95,11 +97,26 @@ LIB_EXPORT uint32_t l_getrandom_uint32(void)
 {
 	int ret;
 	uint32_t u;
+	static unsigned int seed =3D 0;  /* For fallback PRNG. */
 =

 	ret =3D getrandom(&u, sizeof(u), GRND_NONBLOCK);
 =

 	if (ret =3D=3D sizeof(u))
 		return u;
 =

-        return random() * RAND_MAX + random();
+	if (seed =3D=3D 0) {
+		/*
+		 * Seed the fallback PRNG below with the
+		 * process-specific random data supplied by the
+		 * kernel, skipping the canary in the first half.
+		 */
+		unsigned long addr =3D
+			getauxval(AT_RANDOM) + sizeof(void *);
+
+		seed =3D *((unsigned long *) addr) ^ time(NULL);
+
+		srandom(seed);
+	}
+
+	return random() * RAND_MAX + random();
 }
-- =

2.20.1

--===============0396236929071293427==--

