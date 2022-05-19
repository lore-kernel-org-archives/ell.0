Content-Type: multipart/mixed; boundary="===============6779428143639357119=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 07/17] netconfig: Use an internal rtnl socket for
 l_netconfig_apply_rtnl
Date: Thu, 19 May 2022 23:38:59 +0200
Message-ID: <CAOq732LhennE6fXjZf2xoWBRtpeegpfZZBKGwij9=28zek42sg@mail.gmail.com>
In-Reply-To: 522021c7-6b24-674c-f139-832624217ff0@gmail.com

--===============6779428143639357119==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 19 May 2022 at 23:28, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 5/19/22 15:53, Andrew Zaborowski wrote:
> > On Thu, 19 May 2022 at 22:28, Denis Kenzior <denkenz(a)gmail.com> wrote:
> >>> Makes sense.  How about using a global rtnl object for all of the
> >>> l_netconfig objects?  Do you still prefer that it be passed from
> >>> outside?
> >>
> >> I have no real preference on whether it is passed in from the outside =
vs not.
> >> But, there's another thing to consider here.  Today the call to l_foo_=
set_rtnl
> >> is used determine whether the dhcp/icmp/dhcp6 object should set everyt=
hing up
> >> directly vs letting the outside layer do this.  With l_netconfig I don=
't think
> >> this is a problem per se, but you should consider the other classes wh=
en you
> >> design this.
> >
> > Right but with l_netconfig you make this choice by either calling
> > l_netconfig_apply_rtnl or not, and you shouldn't call l_foo_set_rtnl
> > on the underlying dhcp/icmp objects.
> >
>
> Sure, but are you assuming we will not have any further classes using rtnl
> besides netconfig?
>
> >>
> >> We can start by trying to come up with a nice ell API for obtaining the
> >> singleton rtnl object and go from there.
> >
> > The global rtnl object I meant is to be used only by l_netconfig
> > instances so there's no need for a getter, or I'm misunderstanding
> > what you're saying.
> >
>
> We use rtnl all over the place in iwd, like netdev, p2p, ap, etc.  All th=
ese +
> netconfig should share the same one.

That's different than what I did in patch 11/17 but it would work.
I'll put it in rtnl.c then, with a _get() and a _put() since we have
no generic refcounting for l_netlink.

Best refards
--===============6779428143639357119==--

