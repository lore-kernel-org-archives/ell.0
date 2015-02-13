Content-Type: multipart/mixed; boundary="===============0203288096414973591=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: Re: [PATCH v2 3/3] unit: dbus: Add test for disconnect watch API
Date: Fri, 13 Feb 2015 10:40:34 +0200
Message-ID: <1423816834.4196.31.camel@linux.intel.com>
In-Reply-To: <54DD714B.7080502@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0203288096414973591==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On to, 2015-02-12 at 21:36 -0600, Denis Kenzior wrote:
> On 02/12/2015 05:48 AM, Jukka Rissanen wrote:
> > Test the dbus disconnect watch support.
> > ---
> >   Makefile.am            |   3 +
> >   unit/test-dbus-watch.c | 388 ++++++++++++++++++++++++++++++++++++++++=
+++++++++
> >   2 files changed, 391 insertions(+)
> >   create mode 100644 unit/test-dbus-watch.c
> >
> =

> That seems like an awful lot of copy-paste. Can we isolate the actual =

> signal dispatcher and unit test it properly?  For example, you can =

> always make the message_filter function private (e.g. without =

> LIB_EXPORT) instead of static and feed it signals created using e.g. =

> l_dbus_message_new_signal or dbus_message_from_blob

I did not quite understand your comment about signal dispatcher and
message_filter here, please elaborate a bit more?

> =

> Alternatively, fold this into test-dbus.c if possible.

I thought about that but test-dbus.c was already quite big. But if you
are ok with that I can certainly do that too.

> =

> Regards,
> -Denis

Jukka


--===============0203288096414973591==--

