Content-Type: multipart/mixed; boundary="===============4838911060029490954=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/11] net: Add l_net_subnet_matches
Date: Thu, 21 Apr 2022 13:02:01 +0200
Message-ID: <CAOq732LP7Gsfsgoq463zMSpJKiiG3BNu7V1nm+Upx=WW1yrbfQ@mail.gmail.com>
In-Reply-To: 07a346d3-574e-b1e8-15a6-0a04784d4b38@gmail.com

--===============4838911060029490954==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Thu, 21 Apr 2022 at 04:37, Denis Kenzior <denkenz(a)gmail.com> wrote:
> > I put the following comment in one of the patches:
> >
> > +        * TODO: check if we have a prefix route covering the IP,
> > +        * l_dhcp6_client doesn't guarantee that the received IP is in
> > +        * on of the subnets marked as on-link in the RA.
> >
>
> You keep repeating this, but I still don't believe this is true.  You cou=
ld have
> RA gateway address being link-local, or subnet C.  The prefix info in the=
 RA
> could be subnet B and the DHCPv6 address obtained could be in subnet A wi=
th no
> overlap.  Why would you want to? Who knows ;)

However complicated the setup is, you have access to all the routes on
the interface so it's not a problem.

But the point really is that whoever implements a check like this, and
other possible scenarios, if they choose to use ell they might end up
with an out of bounds access.

Best regards
--===============4838911060029490954==--

