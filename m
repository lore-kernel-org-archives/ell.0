Content-Type: multipart/mixed; boundary="===============6304575257654860849=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 5/6] netconfig: Add l_netconfig_apply_rtnl
Date: Tue, 08 Feb 2022 19:23:23 +0100
Message-ID: <CAOq732+SYSuUpUCVtNiuSt-FFbX9zY7K00CAdkSd91WY6Uro1A@mail.gmail.com>
In-Reply-To: CAOq732JZjHBF5oC4Wbn=5O=uCGZf_YD946Ae0RW5omNRx=63cQ@mail.gmail.com

--===============6304575257654860849==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Tue, 8 Feb 2022 at 19:19, Andrew Zaborowski
<andrew.zaborowski(a)intel.com> wrote:
> On Tue, 8 Feb 2022 at 18:42, Denis Kenzior <denkenz(a)gmail.com> wrote:
> > On 2/7/22 09:07, Andrew Zaborowski wrote:
> > > Add l_netconfig_apply_rtnl and the getters for current lists of routes
> > > and addresses for the netconfig user to be able to commit address and
> > > route changes.
> > > ---
> > >   ell/ell.sym     |  3 ++
> > >   ell/netconfig.c | 73 ++++++++++++++++++++++++++++++++++++++++++++++=
+++
> > >   ell/netconfig.h | 11 ++++++++
> > >   3 files changed, 87 insertions(+)
> > >
> >
> > <snip>
> >
> > >
> > > +void l_netconfig_apply_rtnl(struct l_netconfig *netconfig,
> > > +                             struct l_netlink *rtnl);
> > > +struct l_queue *l_netconfig_get_addresses(struct l_netconfig *netcon=
fig,
> > > +                                     struct l_queue **out_added,
> > > +                                     struct l_queue **out_updated,
> > > +                                     struct l_queue **out_removed);
> > > +struct l_queue *l_netconfig_get_routes(struct l_netconfig *netconfig,
> > > +                                     struct l_queue **out_added,
> > > +                                     struct l_queue **out_updated,
> > > +                                     struct l_queue **out_removed);
> > > +
> >
> > I wonder if we can use const l_queue_entry * instead.  Or maybe some so=
rt of
> > iterator concept?  Returning a pointer to the internal data structure is
> > something we should only do as a last resort.
>
> "const l_queue_entry *" would work.  We can also just transfer the
> ownership of those three lists to the caller and drop our references
> to those three lists when we return them.  They're actually temporary,
> I just used l_queue_clear instead of destroying and recreating them.

(This doesn't apply to the complete list of addresses/routes that we
also return, you're right that we'd need to return an iterator.
struct l_queue_entry is pretty much an iterator except that the
.next/.data members are public)

Best regards
--===============6304575257654860849==--

