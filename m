Content-Type: multipart/mixed; boundary="===============7943063132625596166=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] genl: Initialize used memory to avoid valgrind report
Date: Mon, 02 Feb 2015 09:32:48 -0600
Message-ID: <54CF98A0.6000800@gmail.com>
In-Reply-To: <1422612674-6844-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7943063132625596166==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 01/30/2015 04:11 AM, Jukka Rissanen wrote:
> Valgrind reports following error for uninitialized memory usage:
>
>   =3D=3D4725=3D=3D Syscall param socketcall.sendto(msg) points to uniniti=
alised byte(s)
>   =3D=3D4725=3D=3D    at 0x33F5EF6B5D: send (in /usr/lib64/libc-2.17.so)
>   =3D=3D4725=3D=3D    by 0x40BF0E: can_write_data (genl.c:314)
>   =3D=3D4725=3D=3D    by 0x417806: io_callback (io.c:138)
>   =3D=3D4725=3D=3D    by 0x40A282: l_main_run (main.c:346)
>   =3D=3D4725=3D=3D    by 0x401F69: main (main.c:160)
>   =3D=3D4725=3D=3D  Address 0x4c3d092 is 18 bytes inside a block of size =
40 alloc'd
>   =3D=3D4725=3D=3D    at 0x4A06409: malloc (in /usr/lib64/valgrind/vgprel=
oad_memcheck-amd64-linux.so)
>   =3D=3D4725=3D=3D    by 0x40817D: l_malloc (util.c:62)
>   =3D=3D4725=3D=3D    by 0x40C46A: msg_alloc.constprop.13 (genl.c:243)
>   =3D=3D4725=3D=3D    by 0x40D454: l_genl_family_new (genl.c:641)
>   =3D=3D4725=3D=3D    by 0x405A44: wiphy_init (wiphy.c:1492)
>   =3D=3D4725=3D=3D    by 0x401EDD: main (main.c:154)
>   =3D=3D4725=3D=3D
> ---
>   ell/genl.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>

Patch has been applied, thanks.

Regards,
-Denis


--===============7943063132625596166==--

