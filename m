Content-Type: multipart/mixed; boundary="===============5681424528272647929=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 07/17] netconfig: Use an internal rtnl socket for
 l_netconfig_apply_rtnl
Date: Thu, 19 May 2022 22:53:36 +0200
Message-ID: <CAOq732+u2uG9t6eikhZWkaqV7UEc3DLO6ox7fP3J718N2KvNwQ@mail.gmail.com>
In-Reply-To: 8e1935c0-c74d-1d59-cf01-6f7eb58a24d3@gmail.com

--===============5681424528272647929==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 19 May 2022 at 22:28, Denis Kenzior <denkenz(a)gmail.com> wrote:
> > Makes sense.  How about using a global rtnl object for all of the
> > l_netconfig objects?  Do you still prefer that it be passed from
> > outside?
>
> I have no real preference on whether it is passed in from the outside vs =
not.
> But, there's another thing to consider here.  Today the call to l_foo_set=
_rtnl
> is used determine whether the dhcp/icmp/dhcp6 object should set everythin=
g up
> directly vs letting the outside layer do this.  With l_netconfig I don't =
think
> this is a problem per se, but you should consider the other classes when =
you
> design this.

Right but with l_netconfig you make this choice by either calling
l_netconfig_apply_rtnl or not, and you shouldn't call l_foo_set_rtnl
on the underlying dhcp/icmp objects.

>
> We can start by trying to come up with a nice ell API for obtaining the
> singleton rtnl object and go from there.

The global rtnl object I meant is to be used only by l_netconfig
instances so there's no need for a getter, or I'm misunderstanding
what you're saying.

Best regards
--===============5681424528272647929==--

