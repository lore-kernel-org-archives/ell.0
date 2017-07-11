Content-Type: multipart/mixed; boundary="===============4554188099979671662=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/5] settings: Fix string escaping bug
Date: Tue, 11 Jul 2017 16:04:57 -0700
Message-ID: <20170711230501.5419-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20170711230501.5419-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4554188099979671662==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

A missing 'break' in escape_value() was causing a backslash to be
escaped as three backslash characters instead of two. It also triggered
an address sanitizer error when ELL was configured with --enable-asan
and a string value with a backslash was passed to
l_settings_set_string():

=3D=3D7654=3D=3DERROR: AddressSanitizer: heap-buffer-overflow on address 0x=
60200000d100 at pc 0x000000406c07 bp 0x7ffc15b1c500 sp 0x7ffc15b1c4f0
WRITE of size 1 at 0x60200000d100 thread T0
    #0 0x406c06 in escape_value ell/settings.c:203
    #1 0x40ab2d in l_settings_set_string ell/settings.c:976
    #2 0x4031b5 in test_set_methods unit/test-settings.c:247
    #3 0x405d85 in l_test_run ell/test.c:83
    #4 0x4035df in main unit/test-settings.c:289
    #5 0x7fdad3086400 in __libc_start_main (/lib64/libc.so.6+0x20400)
    #6 0x4018f9 in _start (/home/mjmartin/work/ell/unit/test-settings+0x401=
8f9)

0x60200000d100 is located 0 bytes to the right of 16-byte region [0x6020000=
0d0f0,0x60200000d100)
allocated by thread T0 here:
    #0 0x7fdad34f2e60 in malloc (/lib64/libasan.so.3+0xc6e60)
    #1 0x40363d in l_malloc ell/util.c:62
    #2 0x406692 in escape_value ell/settings.c:167
    #3 0x40ab2d in l_settings_set_string ell/settings.c:976
    #4 0x4031b5 in test_set_methods unit/test-settings.c:247
    #5 0x405d85 in l_test_run ell/test.c:83
    #6 0x4035df in main unit/test-settings.c:289
    #7 0x7fdad3086400 in __libc_start_main (/lib64/libc.so.6+0x20400)

SUMMARY: AddressSanitizer: heap-buffer-overflow ell/settings.c:203 in escap=
e_value

Discovered thanks to the new -Wimplicit-fallthrough compiler warning.
---
 ell/settings.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/settings.c b/ell/settings.c
index 967989f..9609e77 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -198,6 +198,7 @@ static char *escape_value(const char *value)
 			ret[j++] =3D '\\';
 			ret[j++] =3D '\\';
 			lead_whitespace =3D false;
+			break;
 		default:
 			ret[j++] =3D value[i];
 			lead_whitespace =3D false;
-- =

2.13.2


--===============4554188099979671662==--

