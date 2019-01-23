Content-Type: multipart/mixed; boundary="===============2328525420739738163=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] key: Work around keyctl_dh_params breakage in certain stable
 kernels
Date: Wed, 23 Jan 2019 14:43:23 -0800
Message-ID: <20190123224323.18586-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2328525420739738163==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

These stable kernels had a change which renamed one of the members of
struct keyctl_dh_params and broke the ELL build:

v4.14.70, v4.14.71, v4.14.72
v4.18.8, v4.18.9, v4.18.10

Later stable releases in the v4.14.x and v4.18.x series reverted to the
previous member name.

This change allows ELL to build using the kernel declaration of the
struct for v4.20 and later, and provides a correct structure declaration
for older kernels.
---
 ell/key.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index bd5b4ea..6c36655 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -39,12 +39,6 @@
 =

 #ifndef KEYCTL_DH_COMPUTE
 #define KEYCTL_DH_COMPUTE 23
-
-struct keyctl_dh_params {
-	int32_t private;
-	int32_t prime;
-	int32_t base;
-};
 #endif
 =

 #ifndef KEYCTL_PKEY_QUERY
@@ -79,6 +73,20 @@ struct keyctl_pkey_params {
 	};
 	uint32_t __spare[7];
 };
+
+/* Work around the missing (pre-4.7) or broken (4.14.{70,71,72} and
+ * 4.18.{8,9,10}) kernel declaration of struct keyctl_dh_params
+ */
+struct dh_params {
+	int32_t private;
+	int32_t prime;
+	int32_t base;
+};
+#else
+/* When KEYCTL_PKEY_QUERY is defined by the kernel, the
+ * struct keyctl_dh_params declaration is valid.
+ */
+#define dh_params keyctl_dh_params
 #endif
 =

 #ifndef KEYCTL_RESTRICT_KEYRING
@@ -201,9 +209,9 @@ static long kernel_dh_compute(int32_t private, int32_t =
prime, int32_t base,
 {
 	long result;
 =

-	struct keyctl_dh_params params =3D { .private =3D private,
-					   .prime =3D prime,
-					   .base =3D base };
+	struct dh_params params =3D { .private =3D private,
+				    .prime =3D prime,
+				    .base =3D base };
 =

 	result =3D syscall(__NR_keyctl, KEYCTL_DH_COMPUTE, &params, payload, len,
 			NULL);
-- =

2.20.1


--===============2328525420739738163==--

