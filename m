Content-Type: multipart/mixed; boundary="===============2833994517615237834=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: ELL unit test problem with Link Time Optimization, l_getrandom,
 test-ecdh
Date: Wed, 06 Nov 2019 09:17:11 -0800
Message-ID: <CAPyD+=DM5Gg4JieKittU9e7bcTaBHvJu3-+EzQpiJ1f4XP-P+g@mail.gmail.com>
In-Reply-To: <c5629468613b76d7fe650006c2276f7f49a42e2b.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2833994517615237834==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 6, 2019 at 8:50 AM Gix, Brian <brian.gix@intel.com> wrote:
>   CCLD     unit/test-ecdh
> /usr/lib64/gcc/x86_64-suse-linux/9/../../../../x86_64-suse-linux/bin/ld: =
/tmp/test-
> ecdh.XGzxNu.ltrans0.ltrans.o: in function `__wrap_l_getrandom':
> /home/bgix/work/user_space/ell/unit/test-ecdh.c:52: undefined reference t=
o `l_getrandom'
> collect2: error: ld returned 1 exit status
> make[1]: *** [Makefile:1541: unit/test-ecdh] Error 1
> make: *** [Makefile:1190: all] Error 2

FWIW, I can reproduce this issue on my Ubuntu 19.10 box:

$ make CFLAGS=3D-flto check
...
  CC       unit/test-ecdh.o
 CCLD     unit/test-ecdh
/usr/bin/ld: /tmp/test-ecdh.guYgVf.ltrans0.ltrans.o: in function `__wrap_l_=
getra
ndom':
<artificial>:(.text+0x2a): undefined reference to `l_getrandom'
collect2: error: ld returned 1 exit status
make[3]: *** [Makefile:1542: unit/test-ecdh] Error 1

-Ossama
--===============2833994517615237834==--

