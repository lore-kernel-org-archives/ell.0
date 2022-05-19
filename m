Content-Type: multipart/mixed; boundary="===============3410549803070085432=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 07/17] netconfig: Use an internal rtnl socket for
 l_netconfig_apply_rtnl
Date: Thu, 19 May 2022 15:28:48 -0500
Message-ID: <8e1935c0-c74d-1d59-cf01-6f7eb58a24d3@gmail.com>
In-Reply-To: CAOq732JFUWwpJpg7BNAWH4JT5CnN-EHNLD_7eDERYEqaRwEqmQ@mail.gmail.com

--===============3410549803070085432==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> Makes sense.  How about using a global rtnl object for all of the
> l_netconfig objects?  Do you still prefer that it be passed from
> outside?

I have no real preference on whether it is passed in from the outside vs no=
t. =

But, there's another thing to consider here.  Today the call to l_foo_set_r=
tnl =

is used determine whether the dhcp/icmp/dhcp6 object should set everything =
up =

directly vs letting the outside layer do this.  With l_netconfig I don't th=
ink =

this is a problem per se, but you should consider the other classes when yo=
u =

design this.

We can start by trying to come up with a nice ell API for obtaining the =

singleton rtnl object and go from there.

Regards,
-Denis
--===============3410549803070085432==--

