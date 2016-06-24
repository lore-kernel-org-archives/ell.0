Content-Type: multipart/mixed; boundary="===============8895076840401233256=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] key: Add placeholder arg to Diffie-Hellman syscall
Date: Fri, 24 Jun 2016 15:16:34 -0700
Message-ID: <20160624221634.5711-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8895076840401233256==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The final version of the syscall that went in to kernel 4.7 added a
reserved arg to the KEYCTL_DH_COMPUTE syscall. In the future, this arg
will be used to optionally specify a key derivation function. For now,
it's needed so the system call doesn't return -1 (errno =3D=3D EINVAL)
every time.
---
 ell/key.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/key.c b/ell/key.c
index adeac04..e6ae92a 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -99,7 +99,8 @@ static long kernel_dh_compute(int32_t private, int32_t pr=
ime, int32_t base,
 					   .prime =3D prime,
 					   .base =3D base };
 =

-	return syscall(__NR_keyctl, KEYCTL_DH_COMPUTE, &params, payload, len);
+	return syscall(__NR_keyctl, KEYCTL_DH_COMPUTE, &params, payload, len,
+			NULL);
 }
 =

 static bool setup_internal_keyring(void)
-- =

2.9.0


--===============8895076840401233256==--

