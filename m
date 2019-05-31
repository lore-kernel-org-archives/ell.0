Content-Type: multipart/mixed; boundary="===============5157102682710949204=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: RE: ELL building broken for 32bit systems
Date: Fri, 31 May 2019 20:28:40 +0000
Message-ID: <DEBB0CAA2616974FAE35E4B560B9A4376CB656EC@ORSMSX103.amr.corp.intel.com>
In-Reply-To: <02aaf068-03dc-57f5-08f8-a3743c43ddb9@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5157102682710949204==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

> =

> Hi Brian,
> =

> > build (and when doing a build of *only* unit/test-cipher) I get the
> > following error when building ell/genl.c:
> >
> =

> Uhh, no idea why only test-cipher, but okay...

Sorry... I was trying to short-cut my own needs to be able to recommend the=
 running of test-cipher in the README file of Bluetooth mesh to determine i=
f the known "old kernel" AEAD problem existed...  But yes, this is an ELL w=
ide problem.

> =

> > [ell]$ make -k unit/test-cipher
> >    CC       ell/genl.lo
> > In file included from /usr/include/string.h:494,
> >                   from ell/util.h:26,
> >                   from ell/genl.c:32:
> > In function =E2=80=98strncpy=E2=80=99,
> >      inlined from =E2=80=98family_add_mcast=E2=80=99 at ell/genl.c:240:=
2,
> >      inlined from =E2=80=98family_add_mcast.isra.0=E2=80=99 at ell/genl=
.c:224:13:
> > /usr/include/bits/string_fortified.h:106:10: error: =E2=80=98__builtin_=
strncpy=E2=80=99
> > specified bound 16 equals destination size [-Werror=3Dstringop-
> > truncation]
> >    106 |   return __builtin___strncpy_chk (__dest, __src, __len, __bos
> > (__dest));
> >        |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > ~~~~~~~~
> > In function =E2=80=98strncpy=E2=80=99,
> >      inlined from =E2=80=98get_family_callback=E2=80=99 at ell/genl.c:1=
049:4:
> > /usr/include/bits/string_fortified.h:106:10: error: =E2=80=98__builtin_=
strncpy=E2=80=99
> > specified bound 16 equals destination size [-Werror=3Dstringop-
> > truncation]
> >    106 |   return __builtin___strncpy_chk (__dest, __src, __len, __bos
> > (__dest));
> >        |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > ~~~~~~~~
> > In function =E2=80=98strncpy=E2=80=99,
> >      inlined from =E2=80=98family_alloc=E2=80=99 at ell/genl.c:164:2:
> > /usr/include/bits/string_fortified.h:106:10: error: =E2=80=98__builtin_=
strncpy=E2=80=99
> > specified bound 16 equals destination size [-Werror=3Dstringop-
> > truncation]
> >    106 |   return __builtin___strncpy_chk (__dest, __src, __len, __bos
> > (__dest));
> >        |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > ~~~~~~~~
> =

> What version are you using?  Upstream ell doesn't even use strncpy in gen=
l.c
> anymore.

This is unmodified Fedora-30 for i686 32-bit.  I tried chasing down the nes=
ting rabbit-hole to find exactly where the strncpy's were coming from, and =
came up empty... I can only assume that some inlined function in string.h r=
esolves to some version of strncpy on 32-bit fedora...   perhaps relating t=
o the strlcpy calls.

For what it's worth, this does not appear to be *new*  per se...  Checking =
out the first labeled ELL version from Jan-2019 causes the same errors.

I do know that F30 introduced a number of alignment warnings (which are thr=
own as errors) that did not exist in F29.



--===============5157102682710949204==--

