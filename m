Content-Type: multipart/mixed; boundary="===============3560774411878429859=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: ELL unit test problem with Link Time Optimization, l_getrandom,
 test-ecdh
Date: Wed, 06 Nov 2019 16:50:30 +0000
Message-ID: <c5629468613b76d7fe650006c2276f7f49a42e2b.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3560774411878429859==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

While examining my BlueZ issues with building with LTO, I came accross =

the following issue in the ELL unit test of ECDH:


.../ell > export CFLAGS=3D"-flto=3Dauto"
.../ell > ./bootstrap-configure
.../ell > make
make --no-print-directory all-am
  CCLD     unit/test-ecdh
/usr/lib64/gcc/x86_64-suse-linux/9/../../../../x86_64-suse-linux/bin/ld: /t=
mp/test-
ecdh.XGzxNu.ltrans0.ltrans.o: in function `__wrap_l_getrandom':
/home/bgix/work/user_space/ell/unit/test-ecdh.c:52: undefined reference to =
`l_getrandom'
collect2: error: ld returned 1 exit status
make[1]: *** [Makefile:1541: unit/test-ecdh] Error 1
make: *** [Makefile:1190: all] Error 2


This is on an up-to-date openSUSE tumbleweed VM, and I have been told that =
building with the LTO flag is the
preferred build method on that system.  This problem does not seem to affec=
t anything *except* that one unit
test, and is probably related to the explicit link rule for it in Makefile.=
am:

unit_test_ecdh_LDFLAGS =3D -Wl,-wrap,l_getrandom

--===============3560774411878429859==--

