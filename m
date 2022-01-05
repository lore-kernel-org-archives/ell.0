Content-Type: multipart/mixed; boundary="===============8766894527640264409=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 3/4] icmp6: Respect lifetime values in a RA
Date: Wed, 05 Jan 2022 15:30:34 +0100
Message-ID: <CAOq732+CXpXbPxzKJTd77_rf8dFHCquCp_C81DGQ4+5qWB1h3g@mail.gmail.com>
In-Reply-To: 13e7bc94-5030-085f-a084-4672950c568b@gmail.com

--===============8766894527640264409==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Mon, 3 Jan 2022 at 20:01, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 1/3/22 08:18, Andrew Zaborowski wrote:
> > "A value of zero indicates that the router is not to be used as a
> > default router."
> >
>
> You may want to put this into the code directly.

Ok, for some reason we don't quote the RFC in this file.

>
> > Also set the lifetime values on the routes to those received so that the
> > user of, say, l_icmp6_client_get_router(), can also determine whether
> > there is a default router.
>
> Note that we do not re-upload the routes to the kernel on every RA receiv=
ed.
> See the TODO comment in icmp6_client_handle_message().  Once lifetime exp=
ires,
> the route will be removed -> internet is broke.  Please at least sanity t=
est the
> changes you're sending out or label them as RFC if you haven't done so.

Ok, I've dropped the l_icmp6_client_set_rtnl() use locally in IWD so
this wouldn't have shown up even if the router had set a short
lifetime.  But I need some way for the user to check if there's a
default gateway.

Best regards
--===============8766894527640264409==--

