Content-Type: multipart/mixed; boundary="===============2976267968918094403=="
MIME-Version: 1.0
From: Natanael Copa <ncopa@alpinelinux.org>
Subject: Re: [PATCH] unit: fix build with musl libc
Date: Wed, 09 Oct 2019 11:33:12 +0200
Message-ID: <20191009113312.4c29d5a1@ncopa-desktop.copa.dup.pw>
In-Reply-To: <1b318150-9b2b-4c14-9f10-82e84601d4bb@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2976267968918094403==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 3 Oct 2019 10:58:53 -0500
Denis Kenzior <denkenz@gmail.com> wrote:

> Hi Natanael,
> =

> On 10/3/19 10:03 AM, Natanael Copa wrote:
> > Define WAIT_ANY if needed. It is not specified in POSIX so we cannot
> > expect it to be defined.
> > =

> > This fixes build with musl libc.
> > ---
> >   unit/test-dbus-message-fds.c | 4 ++++
> >   unit/test-dbus-properties.c  | 4 ++++
> >   unit/test-dbus.c             | 4 ++++
> >   3 files changed, 12 insertions(+)
> > =

> > diff --git a/unit/test-dbus-message-fds.c b/unit/test-dbus-message-fds.c
> > index 6f68bae..6a23141 100644
> > --- a/unit/test-dbus-message-fds.c
> > +++ b/unit/test-dbus-message-fds.c
> > @@ -41,6 +41,10 @@
> >   #define WAIT_ANY (-1) /* Any process */
> >   #endif
> >   =

> > +#ifndef WAIT_ANY
> > +#define WAIT_ANY (-1)
> > +#endif
> > +  =

> =

> I'm confused.  Don't we have the exact same 3 lines just above?
> =

> >   #define TEST_BUS_ADDRESS "unix:path=3D/tmp/ell-test-bus"
> >   =

> >   static pid_t dbus_daemon_pid =3D -1;  =


Yup, sorry, my bad.

This was fixed in commit 696c8eac917e (unit: Define WAIT_ANY if
necessary). I didn't pay enough attention when upstreaming the patch we
use in Alpine.

Sorry.

-nc
--===============2976267968918094403==--

