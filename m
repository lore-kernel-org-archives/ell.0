Content-Type: multipart/mixed; boundary="===============7114940329407683381=="
MIME-Version: 1.0
From: Ravi kumar Veeramally <ravikumar.veeramally@linux.intel.com>
Subject: [PATCH] genl: Fix memory leak
Date: Mon, 15 Dec 2014 13:07:01 +0200
Message-ID: <1418641621-11950-1-git-send-email-ravikumar.veeramally@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7114940329407683381==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

=3D=3D7322=3D=3D Command: unit/test-genl
=3D=3D7322=3D=3D
=3D=3D7322=3D=3D
=3D=3D7322=3D=3D HEAP SUMMARY:
=3D=3D7322=3D=3D     in use at exit: 192 bytes in 5 blocks
=3D=3D7322=3D=3D   total heap usage: 17 allocs, 12 frees, 1,672 bytes alloc=
ated
=3D=3D7322=3D=3D
=3D=3D7322=3D=3D 192 (104 direct, 88 indirect) bytes in 1 blocks are defini=
tely lost in loss record 5 of 5
=3D=3D7322=3D=3D    at 0x4C2ABA0: malloc (in /usr/lib/valgrind/vgpreload_me=
mcheck-amd64-linux.so)
=3D=3D7322=3D=3D    by 0x403D1D: l_malloc (util.c:62)
=3D=3D7322=3D=3D    by 0x402653: family_alloc (genl.c:144)
=3D=3D7322=3D=3D    by 0x4029FA: l_genl_new (genl.c:506)
=3D=3D7322=3D=3D    by 0x402BEF: l_genl_new_default (genl.c:548)
=3D=3D7322=3D=3D    by 0x400FDA: main (test-genl.c:49)
=3D=3D7322=3D=3D
=3D=3D7322=3D=3D LEAK SUMMARY:
=3D=3D7322=3D=3D    definitely lost: 104 bytes in 1 blocks
=3D=3D7322=3D=3D    indirectly lost: 88 bytes in 4 blocks
=3D=3D7322=3D=3D      possibly lost: 0 bytes in 0 blocks
=3D=3D7322=3D=3D    still reachable: 0 bytes in 0 blocks
=3D=3D7322=3D=3D         suppressed: 0 bytes in 0 blocks
---
 ell/genl.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/genl.c b/ell/genl.c
index 88f73bc..dca8e1b 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -593,6 +593,8 @@ void l_genl_unref(struct l_genl *genl)
 	l_io_destroy(genl->io);
 	genl->io =3D NULL;
 =

+	l_genl_family_unref(genl->nlctrl);
+
 	l_queue_destroy(genl->family_list, family_free);
 =

 	if (genl->close_on_unref)
-- =

2.1.0


--===============7114940329407683381==--

