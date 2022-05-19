Content-Type: multipart/mixed; boundary="===============3844966273491451685=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 07/17] netconfig: Use an internal rtnl socket for
 l_netconfig_apply_rtnl
Date: Thu, 19 May 2022 13:52:47 +0200
Message-ID: <CAOq732JFUWwpJpg7BNAWH4JT5CnN-EHNLD_7eDERYEqaRwEqmQ@mail.gmail.com>
In-Reply-To: 378dbbda-7453-9a67-db2f-e098ba159388@gmail.com

--===============3844966273491451685==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Wed, 18 May 2022 at 20:58, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 5/13/22 17:47, Andrew Zaborowski wrote:
> >   LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t ifindex)
> >   {
> >       struct l_netconfig *nc;
> > +     struct l_netlink *rtnl =3D l_netlink_new(NETLINK_ROUTE);
> > +
> > +     if (!rtnl)
> > +             return NULL;
>
> I'm against this.  We will have multiple netconfig objects in play and ea=
ch one
> would be utilizing an fd.  We should be keeping our fd use to a minimum,
> particularly since we're limited to ~128 right now.  Passing in the rtnl =
object
> from outside is preferred.

Makes sense.  How about using a global rtnl object for all of the
l_netconfig objects?  Do you still prefer that it be passed from
outside?

I did this later in patch 11 and maybe should have merged that change
directly here.  We could also create it only after
l_netconfig_start().

Best regards
--===============3844966273491451685==--

