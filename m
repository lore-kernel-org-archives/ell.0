Content-Type: multipart/mixed; boundary="===============1828075448958467045=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 1/7] key: Consistently return errno from syscall wrappers
Date: Fri, 29 Jul 2016 11:11:55 -0700
Message-ID: <20160729181201.16446-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1828075448958467045==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/key.c | 44 +++++++++++++++++++++++++++++++++++++-------
 1 file changed, 37 insertions(+), 7 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index 6117e31..a8d011a 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -29,6 +29,7 @@
 #include <stdint.h>
 #include <sys/syscall.h>
 #include <linux/keyctl.h>
+#include <errno.h>
 =

 #include "private.h"
 #include "util.h"
@@ -64,43 +65,72 @@ static const char * const key_type_names[] =3D {
 static long kernel_add_key(const char *type, const char *description,
 				const void *payload, size_t len, int32_t keyring)
 {
-	return syscall(__NR_add_key, type, description, payload, len, keyring);
+	long result;
+
+	result =3D syscall(__NR_add_key, type, description, payload, len,
+				keyring);
+
+	return result >=3D 0 ? result : -errno;
 }
 =

 static long kernel_read_key(int32_t serial, const void *payload, size_t le=
n)
 {
-	return syscall(__NR_keyctl, KEYCTL_READ, serial, payload, len);
+	long result;
+
+	result =3D syscall(__NR_keyctl, KEYCTL_READ, serial, payload, len);
+
+	return result >=3D 0 ? result : -errno;
 }
 =

 static long kernel_update_key(int32_t serial, const void *payload, size_t =
len)
 {
-	return syscall(__NR_keyctl, KEYCTL_UPDATE, serial, payload, len);
+	long result;
+
+	result =3D syscall(__NR_keyctl, KEYCTL_UPDATE, serial, payload, len);
+
+	return result >=3D 0 ? result : -errno;
 }
 =

 static long kernel_revoke_key(int32_t serial)
 {
-	return syscall(__NR_keyctl, KEYCTL_REVOKE, serial);
+	long result;
+
+	result =3D syscall(__NR_keyctl, KEYCTL_REVOKE, serial);
+
+	return result >=3D 0 ? result : -errno;
 }
 =

 static long kernel_link_key(int32_t key_serial, int32_t ring_serial)
 {
-	return syscall(__NR_keyctl, KEYCTL_LINK, key_serial, ring_serial);
+	long result;
+
+	result =3D syscall(__NR_keyctl, KEYCTL_LINK, key_serial, ring_serial);
+
+	return result >=3D 0 ? result : -errno;
 }
 =

 static long kernel_unlink_key(int32_t key_serial, int32_t ring_serial)
 {
-	return syscall(__NR_keyctl, KEYCTL_UNLINK, key_serial, ring_serial);
+	long result;
+
+	result =3D syscall(__NR_keyctl, KEYCTL_UNLINK, key_serial, ring_serial);
+
+	return result >=3D 0 ? result : -errno;
 }
 =

 static long kernel_dh_compute(int32_t private, int32_t prime, int32_t base,
 			      void *payload, size_t len)
 {
+	long result;
+
 	struct keyctl_dh_params params =3D { .private =3D private,
 					   .prime =3D prime,
 					   .base =3D base };
 =

-	return syscall(__NR_keyctl, KEYCTL_DH_COMPUTE, &params, payload, len,
+	result =3D syscall(__NR_keyctl, KEYCTL_DH_COMPUTE, &params, payload, len,
 			NULL);
+
+	return result >=3D 0 ? result : -errno;
 }
 =

 static bool setup_internal_keyring(void)
-- =

2.9.2


--===============1828075448958467045==--

