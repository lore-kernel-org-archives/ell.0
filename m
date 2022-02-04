Content-Type: multipart/mixed; boundary="===============3937108490615917635=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 2/5] unit: add settings test for clone APIs
Date: Fri, 04 Feb 2022 11:29:54 -0600
Message-ID: <fcffef82-bd0c-830f-7054-6a73905c1b5c@gmail.com>
In-Reply-To: 20220204170603.216439-2-prestwoj@gmail.com

--===============3937108490615917635==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 2/4/22 11:05, James Prestwood wrote:
> ---
>   unit/test-settings.c | 40 +++++++++++++++++++++++++++++++++++++++-
>   1 file changed, 39 insertions(+), 1 deletion(-)
> =


There seems to be a leak somewhere?

TEST: Test clone
=3D=3D22270=3D=3D
=3D=3D22270=3D=3D HEAP SUMMARY:
=3D=3D22270=3D=3D     in use at exit: 1,860 bytes in 14 blocks
=3D=3D22270=3D=3D   total heap usage: 599 allocs, 585 frees, 25,152 bytes a=
llocated
=3D=3D22270=3D=3D
=3D=3D22270=3D=3D 1,860 (40 direct, 1,820 indirect) bytes in 1 blocks are d=
efinitely =

lost in loss record 14 of 14
=3D=3D22270=3D=3D    at 0x483F7B5: malloc (in =

/usr/libexec/valgrind/vgpreload_memcheck-amd64-linux.so)
=3D=3D22270=3D=3D    by 0x10D88D: l_malloc (util.c:62)
=3D=3D22270=3D=3D    by 0x10FCDB: l_settings_new (settings.c:112)
=3D=3D22270=3D=3D    by 0x10D565: test_clone (test-settings.c:589)
=3D=3D22270=3D=3D    by 0x10E438: l_test_run (test.c:84)
=3D=3D22270=3D=3D    by 0x10B5D9: main (test-settings.c:614)

Regards,
-Denis
--===============3937108490615917635==--

