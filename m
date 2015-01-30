Content-Type: multipart/mixed; boundary="===============8647547370280969339=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH] genl: Initialize used memory to avoid valgrind report
Date: Fri, 30 Jan 2015 12:11:14 +0200
Message-ID: <1422612674-6844-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8647547370280969339==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Valgrind reports following error for uninitialized memory usage:

 =3D=3D4725=3D=3D Syscall param socketcall.sendto(msg) points to uninitiali=
sed byte(s)
 =3D=3D4725=3D=3D    at 0x33F5EF6B5D: send (in /usr/lib64/libc-2.17.so)
 =3D=3D4725=3D=3D    by 0x40BF0E: can_write_data (genl.c:314)
 =3D=3D4725=3D=3D    by 0x417806: io_callback (io.c:138)
 =3D=3D4725=3D=3D    by 0x40A282: l_main_run (main.c:346)
 =3D=3D4725=3D=3D    by 0x401F69: main (main.c:160)
 =3D=3D4725=3D=3D  Address 0x4c3d092 is 18 bytes inside a block of size 40 =
alloc'd
 =3D=3D4725=3D=3D    at 0x4A06409: malloc (in /usr/lib64/valgrind/vgpreload=
_memcheck-amd64-linux.so)
 =3D=3D4725=3D=3D    by 0x40817D: l_malloc (util.c:62)
 =3D=3D4725=3D=3D    by 0x40C46A: msg_alloc.constprop.13 (genl.c:243)
 =3D=3D4725=3D=3D    by 0x40D454: l_genl_family_new (genl.c:641)
 =3D=3D4725=3D=3D    by 0x405A44: wiphy_init (wiphy.c:1492)
 =3D=3D4725=3D=3D    by 0x401EDD: main (main.c:154)
 =3D=3D4725=3D=3D
---
 ell/genl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/genl.c b/ell/genl.c
index d2c1784..2ef6a34 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -239,7 +239,7 @@ static struct l_genl_msg *msg_alloc(uint8_t cmd, uint8_=
t version, uint32_t size)
 	msg->len =3D NLMSG_HDRLEN + GENL_HDRLEN;
 	msg->size =3D msg->len + NLMSG_ALIGN(size);
 =

-	msg->data =3D l_malloc(msg->size);
+	msg->data =3D l_new(unsigned char, msg->size);
 =

 	return l_genl_msg_ref(msg);
 }
-- =

1.8.3.1


--===============8647547370280969339==--

