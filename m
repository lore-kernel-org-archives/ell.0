Content-Type: multipart/mixed; boundary="===============8219658093562915376=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: ELL building broken for 32bit systems
Date: Fri, 31 May 2019 14:53:31 -0500
Message-ID: <02aaf068-03dc-57f5-08f8-a3743c43ddb9@gmail.com>
In-Reply-To: <cb7cb78f01fb933780c895ef93e065f7266d2f93.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8219658093562915376==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

> build (and when doing a build of *only* unit/test-cipher) I get the
> following error when building ell/genl.c:
> =


Uhh, no idea why only test-cipher, but okay...

> [ell]$ make -k unit/test-cipher
>    CC       ell/genl.lo
> In file included from /usr/include/string.h:494,
>                   from ell/util.h:26,
>                   from ell/genl.c:32:
> In function =E2=80=98strncpy=E2=80=99,
>      inlined from =E2=80=98family_add_mcast=E2=80=99 at ell/genl.c:240:2,
>      inlined from =E2=80=98family_add_mcast.isra.0=E2=80=99 at ell/genl.c=
:224:13:
> /usr/include/bits/string_fortified.h:106:10: error: =E2=80=98__builtin_st=
rncpy=E2=80=99
> specified bound 16 equals destination size [-Werror=3Dstringop-
> truncation]
>    106 |   return __builtin___strncpy_chk (__dest, __src, __len, __bos
> (__dest));
>        |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> ~~~~~~~~
> In function =E2=80=98strncpy=E2=80=99,
>      inlined from =E2=80=98get_family_callback=E2=80=99 at ell/genl.c:104=
9:4:
> /usr/include/bits/string_fortified.h:106:10: error: =E2=80=98__builtin_st=
rncpy=E2=80=99
> specified bound 16 equals destination size [-Werror=3Dstringop-
> truncation]
>    106 |   return __builtin___strncpy_chk (__dest, __src, __len, __bos
> (__dest));
>        |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> ~~~~~~~~
> In function =E2=80=98strncpy=E2=80=99,
>      inlined from =E2=80=98family_alloc=E2=80=99 at ell/genl.c:164:2:
> /usr/include/bits/string_fortified.h:106:10: error: =E2=80=98__builtin_st=
rncpy=E2=80=99
> specified bound 16 equals destination size [-Werror=3Dstringop-
> truncation]
>    106 |   return __builtin___strncpy_chk (__dest, __src, __len, __bos
> (__dest));
>        |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> ~~~~~~~~

What version are you using?  Upstream ell doesn't even use strncpy in =

genl.c anymore.

Regards,
-Denis

--===============8219658093562915376==--

