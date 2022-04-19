Content-Type: multipart/mixed; boundary="===============1319310323400466362=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/11] net: Add l_net_subnet_matches
Date: Tue, 19 Apr 2022 09:42:34 +0200
Message-ID: <CAOq732J0iJ5Vc8de1z_6TbFbj-ZCi+jiZ65X+Gmgx=_yVGaWSg@mail.gmail.com>
In-Reply-To: d347beb5-ac09-c641-bb62-b919da565d9f@gmail.com

--===============1319310323400466362==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Mon, 18 Apr 2022 at 20:00, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 4/18/22 12:21, Andrew Zaborowski wrote:
> > On Mon, 18 Apr 2022 at 19:04, Denis Kenzior <denkenz(a)gmail.com> wrote:
> >> On 4/18/22 12:01, Andrew Zaborowski wrote:
> >>> Do we want to do the array[bytes] access after the !bits check to
> >>> avoid accessing the byte after the end of the address for weird cases
> >>> where the prefix_len is exactly the number of bits in the two buffers
> >>> we received.
> >>
> >> Aren't we guaranteed to be operating on 4 byte values?  So unless pref=
ix_len =3D=3D
> >> 32, I don't see how we could perform out-of-bounds access?
> >
> > 4 or 16 bytes, in theory yes but I can imagine someone trying to use a
>
> IPv6 doesn't really use subnets like IPv4 does though?  I'm not even sure=
 this
> function would be relevant for IPv6?

You need it to check if an address is within a subnet prefix?

>  Is it?  Looks like we do this for FILS,
> but I'm not even certain that the check in ie.c in iwd is correct.
>
> > buffer of just long enough for the subnet address, or passing a
> > prefix_len of 32 / 128 for things like a route prefix.
>
> Well, prefix_len of 32/128 implies point-to-point routing (and even 31 in=
 IPv4
> would be special).  So I'm not sure calling this function with such prefi=
xes
> even makes sense?

While an IPv4 31/32-bit subnet might not be a valid subnet, with IPv6
I don't know of a reason that single-address prefixes should be
treated specially.  RFC4191 for example says that an onlink prefix
length "value ranges from 0 to 128".

Best regards
--===============1319310323400466362==--

