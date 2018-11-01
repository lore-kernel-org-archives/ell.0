Content-Type: multipart/mixed; boundary="===============8789767294837208419=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] ell/signal.h: use sigset_t instead of internal libc
 implementation
Date: Thu, 01 Nov 2018 10:31:25 +0100
Message-ID: <39FDF977-0C4A-49DE-B086-6BC281495816@holtmann.org>
In-Reply-To: <20181101092742.24873-1-thinkabit.ukim@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8789767294837208419==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Maxwell,

> On Nov 1, 2018, at 10:27, maxice8 <thinkabit.ukim@gmail.com> wrote:

Please use full name in author information.

> Fixes compilation on musl libc which doesn't show up the internal
> implementation.
> =

> Error message:
> =

>  CC       ell/main.lo
> In file included from ell/main.c:35:
> ell/signal.h:39:40: error: unknown type name '__sigset_t'
> struct l_signal *l_signal_create(const __sigset_t *mask,
>                                        ^~~~~~~~~~

I tried to make this work with -std=3Dc99 and I am kinda lost on what the r=
ight approach here is. Define _USE_POSIX or what is the recommendation?

Regards

Marcel


--===============8789767294837208419==--

