Content-Type: multipart/mixed; boundary="===============5688934895275142080=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 2/5] icmp6: Free ra in icmp6_client_read_handler on
 ECANCELED
Date: Thu, 06 Jan 2022 12:58:33 -0600
Message-ID: <32dc0d69-a87b-2560-a7d5-b2c302281e48@gmail.com>
In-Reply-To: 20220106150529.458775-2-andrew.zaborowski@intel.com

--===============5688934895275142080==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 1/6/22 09:05, Andrew Zaborowski wrote:
> Make sure we free @ra in in icmp6_client_read_handler even when
> icmp6_client_handle_message returns -ECANCELED.
> =

> Fixes this:
> =3D=3D1088=3D=3D 1,176 bytes in 9 blocks are definitely lost in loss reco=
rd 28 of 29
> =3D=3D1088=3D=3D    at 0x4843839: malloc (in /usr/libexec/valgrind/vgprel=
oad_memcheck-amd64-linux.so)
> =3D=3D1088=3D=3D    by 0x4808A1: l_malloc (util.c:62)
> =3D=3D1088=3D=3D    by 0x4C0966: icmp6_client_read_handler (icmp6.c:659)
> =3D=3D1088=3D=3D    by 0x4877AF: io_callback (io.c:120)
> =3D=3D1088=3D=3D    by 0x48693C: l_main_iterate (main.c:478)
> =3D=3D1088=3D=3D    by 0x486A0B: l_main_run (main.c:525)
> =3D=3D1088=3D=3D    by 0x486A0B: l_main_run (main.c:507)
> =3D=3D1088=3D=3D    by 0x486C3F: l_main_run_with_signal (main.c:647)
> =3D=3D1088=3D=3D    by 0x404755: main (main.c:532)
> ---
>   ell/icmp6.c | 4 +---
>   1 file changed, 1 insertion(+), 3 deletions(-)
> =


I added an additional Fixes tag:

8cef9c50c9f4 ("icmp6: Don't crash if client was stopped")

Applied, thanks.

Regards,
-Denis
--===============5688934895275142080==--

