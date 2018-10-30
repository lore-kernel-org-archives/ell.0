Content-Type: multipart/mixed; boundary="===============1497185331668735142=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: [PATCH 0/5] C99 related fixes
Date: Tue, 30 Oct 2018 10:59:01 -0700
Message-ID: <CAPyD+=DaS_KzAccwr41vWPh2eH8vwA7y_nSC6t6qhZo5m_WJSA@mail.gmail.com>
In-Reply-To: <5EC086C3-CF79-444C-B1B4-629A29ADCDE2@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1497185331668735142==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

> > In file included from /usr/local/include/ell/ell.h:32:0,
> >                from foo.c:1:
> > /usr/local/include/ell/signal.h:39:40: error: unknown type name =E2=80=
=98__sigset_t=E2=80=99
> > struct l_signal *l_signal_create(const __sigset_t *mask,
> >                                       ^~~~~~~~~~
> >
> > Should the appropriate feature test macro be added to ELL's Cflags
> > variable in the ell.pc pkg-config file?
>
> not in the pkg-config since that should really just only list include pat=
hs and library dependencies. What test feature is this behind anyway?

In glibc, it looks like sigset_t requires __USE_POSIX, which is
defined when _POSIX_SOURCE, _POSIX_C_SOURCE >=3D1, or _XOPEN_SOURCE is
defined.  From glibc's <features.h>:

#if (defined _POSIX_SOURCE \
     || (defined _POSIX_C_SOURCE && _POSIX_C_SOURCE >=3D 1) \
     || defined _XOPEN_SOURCE)
# define __USE_POSIX 1
#endif

> Also I am debating to actually change the API anyway and use ELL
> specific values for the signals. I think that exposing sigset_t is
> not a good idea. In wired/dbus.c of iwd, I have a full wrapper
> around this anyway and with the addition of exposing SIGUSR1,
> SIGUSR2 and SIGHUP, I doubt any application should deal with any
> other signals. At least not from a daemon perspective. There might
> be SIGCHLD if it spawns (which we discourage since we want to stay
> single process), but that we handled internally with a proper API
> anyway. Since child reaping is something really hard to get right so
> that code better be only written once anyway.

That sounds like a good plan.

Thanks,
-Ossama

--===============1497185331668735142==--

