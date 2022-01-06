Content-Type: multipart/mixed; boundary="===============4885125070725336109=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 2/5] icmp6: Free ra in icmp6_client_read_handler on ECANCELED
Date: Thu, 06 Jan 2022 16:05:26 +0100
Message-ID: <20220106150529.458775-2-andrew.zaborowski@intel.com>
In-Reply-To: 20220106150529.458775-1-andrew.zaborowski@intel.com

--===============4885125070725336109==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make sure we free @ra in in icmp6_client_read_handler even when
icmp6_client_handle_message returns -ECANCELED.

Fixes this:
=3D=3D1088=3D=3D 1,176 bytes in 9 blocks are definitely lost in loss record=
 28 of 29
=3D=3D1088=3D=3D    at 0x4843839: malloc (in /usr/libexec/valgrind/vgpreloa=
d_memcheck-amd64-linux.so)
=3D=3D1088=3D=3D    by 0x4808A1: l_malloc (util.c:62)
=3D=3D1088=3D=3D    by 0x4C0966: icmp6_client_read_handler (icmp6.c:659)
=3D=3D1088=3D=3D    by 0x4877AF: io_callback (io.c:120)
=3D=3D1088=3D=3D    by 0x48693C: l_main_iterate (main.c:478)
=3D=3D1088=3D=3D    by 0x486A0B: l_main_run (main.c:525)
=3D=3D1088=3D=3D    by 0x486A0B: l_main_run (main.c:507)
=3D=3D1088=3D=3D    by 0x486C3F: l_main_run_with_signal (main.c:647)
=3D=3D1088=3D=3D    by 0x404755: main (main.c:532)
---
 ell/icmp6.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/ell/icmp6.c b/ell/icmp6.c
index 6b1652c..87e46d1 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -401,9 +401,7 @@ static bool icmp6_client_read_handler(struct l_io *io, =
void *userdata)
 	}
 =

 	r =3D icmp6_client_handle_message(client, ra, l, &src);
-	if (r =3D=3D -ECANCELED)
-		return true;
-	else if (r < 0)
+	if (r < 0)
 		goto done;
 =

 	/* Stop solicitations */
-- =

2.32.0

--===============4885125070725336109==--

