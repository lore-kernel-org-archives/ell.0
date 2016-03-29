Content-Type: multipart/mixed; boundary="===============3599209978201851195=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] dbus: Fix compile error for 32-bit platforms
Date: Tue, 29 Mar 2016 15:36:06 -0700
Message-ID: <1459290966-18779-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3599209978201851195==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Error encountered with 32-bit gcc 5.3.1:

ell/dbus-kernel.c:412:20: error: cast from pointer to integer of
different size [-Werror=3Dpointer-to-int-cast]

Casting the pointer to uintptr_t instead of uint64_t works on both
32-bit and 64-bit platforms.
---
 ell/dbus-kernel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 7124c33..863e8e7 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -409,7 +409,7 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint8_=
t bloom_n_hash,
 =

 	memset(&cmd, 0, sizeof(cmd));
 	cmd.size =3D sizeof(cmd);
-	cmd.msg_address =3D (uint64_t) kmsg;
+	cmd.msg_address =3D (uintptr_t) kmsg;
 =

 	ret =3D ioctl(fd, KDBUS_CMD_SEND, &cmd);
 	if (ret < 0)
-- =

2.8.0


--===============3599209978201851195==--

