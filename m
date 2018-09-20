Content-Type: multipart/mixed; boundary="===============8866793781015105568=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] key: Change initialization of struct keyctl_dh_params
Date: Thu, 20 Sep 2018 16:14:05 -0700
Message-ID: <20180920231405.3177-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8866793781015105568==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Using a designated initializer with struct keyctl_dh_params has broken
due to a kernel header file change to one of the member names,
introduced in kernel v4.19-rc3:

https://lore.kernel.org/lkml/1735b3a4-2792-0ce4-3bf4-94fee5b50ff6(a)infrade=
ad.org/

If the member names are dropped from the initializer then the code will
compile and work correctly before or after the kernel header change.
---

Thanks for reporting the breakage, Andreas.


 ell/key.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index 6b16e55..b45ebc6 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -202,9 +202,7 @@ static long kernel_dh_compute(int32_t private, int32_t =
prime, int32_t base,
 {
 	long result;
 =

-	struct keyctl_dh_params params =3D { .private =3D private,
-					   .prime =3D prime,
-					   .base =3D base };
+	struct keyctl_dh_params params =3D { private, prime, base };
 =

 	result =3D syscall(__NR_keyctl, KEYCTL_DH_COMPUTE, &params, payload, len,
 			NULL);
-- =

2.19.0


--===============8866793781015105568==--

