Content-Type: multipart/mixed; boundary="===============5388913490727231614=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: Re: [PATCH v2 3/3] unit: dbus: Add test for disconnect watch API
Date: Mon, 16 Feb 2015 12:53:22 +0200
Message-ID: <1424084002.4196.45.camel@linux.intel.com>
In-Reply-To: <54DE13A9.80003@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5388913490727231614==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On pe, 2015-02-13 at 09:09 -0600, Denis Kenzior wrote:
> Hi Jukka,
> =

>  >>
> >> Then test this functionality in the unit test.  If you're relying on
> >> semi-manual tests for this stuff, your test coverage will be pretty sm=
all.
> >>
> >
> > But don't we want to test this against dbus-daemon? Testing this watch
> > API without dbus-daemon interaction seems pointless to me.
> =

> Why?  In this case, what's the difference between getting a signal from =

> DBus Daemon vs simply making one up yourself?  Isolating the code and =

> unit testing the hell out of it is much simpler without dbus-daemon =

> involved.  Much faster and more compact too.

We have already tests for receiving signals so it seems pointless to
test them again. To me it looks more useful to test that we really get
NameOwnerChanged signal from dbus-daemon when we quit the test app.
Testing real interaction is more complex (as the code shows) but at
least we know that the watch support works in real life.


Jukka



--===============5388913490727231614==--

