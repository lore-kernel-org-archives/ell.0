Content-Type: multipart/mixed; boundary="===============8218791795817518647=="
MIME-Version: 1.0
From: Patrik Flykt <Patrik.Flykt@linux.intel.com>
Subject: Re: [PATCH] netlink: Allow NLM_F_DUMP on netlink requests
Date: Fri, 26 Sep 2014 13:13:07 +0300
Message-ID: <1411726387.6771.50.camel@pflykt-mobl1>
In-Reply-To: <5422E2F6.7030702@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8218791795817518647==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-09-24 at 10:27 -0500, Denis Kenzior wrote:
> > -     if (flags & 0xff)
> > +     if (flags & 0xff & ~NLM_F_DUMP)
> >               return 0;
> =

> Maybe a nitpick, but should this be simply:
> =

> if (flags & ~NLM_F_DUMP)

Oh, I misread netlink.h on this one!

NLM_F_DUMP has a value of 0x300 (and not 16, that's actually
NLM_F_DUMP_INTR) so it is not affected by the mask. Let's NACK this
patch instead.

Cheers,

	Patrik



--===============8218791795817518647==--

