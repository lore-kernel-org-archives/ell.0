Content-Type: multipart/mixed; boundary="===============1890810349684917311=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/11] net: Add l_net_subnet_matches
Date: Mon, 18 Apr 2022 19:21:57 +0200
Message-ID: <CAOq732JnYMhs3rLhSYspyoKW53Ef+-DXH0g0oNaCTq1WF+FMXg@mail.gmail.com>
In-Reply-To: 8ce78b6d-b4f1-d5ca-d903-77a46ed61e46@gmail.com

--===============1890810349684917311==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Mon, 18 Apr 2022 at 19:04, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 4/18/22 12:01, Andrew Zaborowski wrote:
> >> There were a bit too many '()' for my liking.  I moved the casts to th=
e variable
> >> declaration block above which ended up being the same number of lines =
and looked
> >> a bit cleaner.
> >
> > Do we want to do the array[bytes] access after the !bits check to
> > avoid accessing the byte after the end of the address for weird cases
> > where the prefix_len is exactly the number of bits in the two buffers
> > we received.
>
> Aren't we guaranteed to be operating on 4 byte values?  So unless prefix_=
len =3D=3D
> 32, I don't see how we could perform out-of-bounds access?

4 or 16 bytes, in theory yes but I can imagine someone trying to use a
buffer of just long enough for the subnet address, or passing a
prefix_len of 32 / 128 for things like a route prefix.

Best regards
--===============1890810349684917311==--

