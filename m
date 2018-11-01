Content-Type: multipart/mixed; boundary="===============4217426679764759135=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: [PATCH] ell/signal.h: use sigset_t instead of internal libc
 implementation
Date: Thu, 01 Nov 2018 10:00:38 -0700
Message-ID: <CAPyD+=B0+UEJZO3m9o0kcZEe+nbvQqHAwm8DEqh_w61djUOkNQ@mail.gmail.com>
In-Reply-To: <39FDF977-0C4A-49DE-B086-6BC281495816@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4217426679764759135==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

Sorry about the duplicate e-mail.  I neglected to reply to all earlier.

On Thu, Nov 1, 2018 at 2:31 AM Marcel Holtmann <marcel@holtmann.org> wrot=
e:
> > On Nov 1, 2018, at 10:27, maxice8 <thinkabit.ukim@gmail.com> wrote:
> > Error message:
> >
> >  CC       ell/main.lo
> > In file included from ell/main.c:35:
> > ell/signal.h:39:40: error: unknown type name '__sigset_t'
> > struct l_signal *l_signal_create(const __sigset_t *mask,
> >                                        ^~~~~~~~~~
>
> I tried to make this work with -std=3Dc99 and I am kinda lost on what the=
 right approach here is. Define _USE_POSIX or what is the recommendation?

Ideally ELL's public API should not depend on the definition of a
feature test macro, but if one is going to be defined I'd avoid
__USE_POSIX since it's a glibc implementation detail.  I'd go with
_DEFAULT_SOURCE, which I think is specific to glibc, or one of the
standard _POSIX_SOURCE, _POSIX_C_SOURCE (>=3D 1), or _XOPEN_SOURCE.
Relevant feature test macro documentation:

http://man7.org/linux/man-pages/man7/feature_test_macros.7.html
http://pubs.opengroup.org/onlinepubs/007904975/functions/xsh_chap02_02.html
https://www.gnu.org/software/libc/manual/html_node/Feature-Test-Macros.html

BTW, this problem isn't specific to -std=3Dc99 builds.  It occurs with
-std=3Dc11 and -ansi, too.

HTH,
-Ossama

--===============4217426679764759135==--

