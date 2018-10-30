Content-Type: multipart/mixed; boundary="===============8809210794399589438=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 0/5] C99 related fixes
Date: Tue, 30 Oct 2018 18:37:36 +0100
Message-ID: <5EC086C3-CF79-444C-B1B4-629A29ADCDE2@holtmann.org>
In-Reply-To: <CAPyD+=AyNM4b_EvYMReG7GAChoK+Z-cfg1NxrLdDq4Bn6ZA4=Q@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8809210794399589438==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

>> so besides including two of your patches, I fixed the rest by adding
>> the correct headers and using _GNU_SOURCE to active the features. So
>> with -std99 we should be fine now. I have to look into -ansi and if
>> that is worth while supporting. However I hope that I didn=E2=80=99t bre=
ak
>> things for the musl builds.
> =

> Thanks for making those changes.  ELL itself now builds with -std=3Dc99
> for me.  However, the __sigset_t type used in <ell/signal.h> is still
> flagged as an unknown type in my code when compiling with -std=3Dc99,
> without explicitly defining any feature test macros.  For example, a
> trivial code snippet that only includes <ell/ell.h> fails:
> =

> foo.c:
> #include <ell/ell.h>
> =

> $ gcc -std=3Dc99 -fsyntax-only foo.c
> In file included from /usr/local/include/ell/ell.h:32:0,
>                from foo.c:1:
> /usr/local/include/ell/signal.h:39:40: error: unknown type name =E2=80=98=
__sigset_t=E2=80=99
> struct l_signal *l_signal_create(const __sigset_t *mask,
>                                       ^~~~~~~~~~
> =

> Should the appropriate feature test macro be added to ELL's Cflags
> variable in the ell.pc pkg-config file?

not in the pkg-config since that should really just only list include paths=
 and library dependencies. What test feature is this behind anyway?

Also I am debating to actually change the API anyway and use ELL specific v=
alues for the signals. I think that exposing sigset_t is not a good idea. I=
n wired/dbus.c of iwd, I have a full wrapper around this anyway and with th=
e addition of exposing SIGUSR1, SIGUSR2 and SIGHUP, I doubt any application=
 should deal with any other signals. At least not from a daemon perspective=
. There might be SIGCHLD if it spawns (which we discourage since we want to=
 stay single process), but that we handled internally with a proper API any=
way. Since child reaping is something really hard to get right so that code=
 better be only written once anyway.

Regards

Marcel


--===============8809210794399589438==--

