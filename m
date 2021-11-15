Content-Type: multipart/mixed; boundary="===============4522026815078728139=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/3] rtnl: Fix address conversion buffer overflow.
Date: Mon, 15 Nov 2021 11:10:59 -0800
Message-ID: <CAE+88WPC-Mg-o5vbHeuuqP_e2tOyWr3CvwnRb=zMBn0NjiyByA@mail.gmail.com>
In-Reply-To: ac6e7c2c-c8ea-a10c-20a3-f3c8d5ee2031@gmail.com

--===============4522026815078728139==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Re-sending to the mailing list.  My original response was inadvertently sen=
t to
Denis alone.  Apologies.

Hi Denis,

On Wed, Nov 10, 2021 at 8:13 AM Denis Kenzior <denkenz(a)gmail.com> wrote:
> So I'm a little torn about this.  On the one hand, specifying the buffer =
len is
> indeed safer.  However, simply passing a buffer of size INET6_ADDRSTRLEN =
is also
> guaranteed to work for any address that we support and saves the need for=
 the
> extra argument.  Alternatively, if you know the family or can look it up =
via
> l_rtnl_*_get_family(), you can use INET_ADDRSTRLEN for ipv4 getters.  May=
be this
> is more of a documentation issue?
>
> If you look at how iwd uses these functions, the extra argument is unnece=
ssary.
>
> Can you share more info about what made you propose this change?  Are you=
 using
> these functions in ways where the buffer size argument would be advantage=
ous?

My own usage for the ELL l_rtnl API is still experimental since I was
looking to replace direct rtnetlink calls in mptcpd's network
monitoring code with l_rtnl based ones.  In this particular case, I
was using l_rtnl_address_get_address() solely for logging purposes.

I agree that passing a buffer of length INET6_ADDRSTRLEN is sufficient
for both IPv4 and IPv6 cases.  Mptcpd does this, too.  Regardless, I
felt that a public library API shouldn't be making assumptions about
user supplied buffer lengths.  Other than making the user responsible
for potential buffer overrun issues, there is no other advantage I can
think of.

-Ossama

On Wed, Nov 10, 2021 at 8:13 AM Denis Kenzior <denkenz(a)gmail.com> wrote:
>
> Hi Ossama,
>
> On 11/9/21 6:14 PM, Ossama Othman wrote:
> > Some l_rtnl functions that return a stringified address could
> > potentially overrun a user supplied buffer of insufficient length.
> > Add a buffer length argument to prevent ELL from making incorrect
> > assumptions.  Impacted functions are l_rtnl_address_get_address(),
> > l_rtnl_route_get_gateway(), and l_rtnl_route_get_prefsrc().
> > ---
> >   ell/rtnl.c | 28 +++++++++++++++++-----------
> >   ell/rtnl.h |  8 +++++---
> >   2 files changed, 22 insertions(+), 14 deletions(-)
> >
>
> <snip>
>
> >   bool l_rtnl_address_get_address(const struct l_rtnl_address *addr,
> > -                             char *out_buf);
> > +                             char *out_buf, size_t buflen);
>
> So I'm a little torn about this.  On the one hand, specifying the buffer =
len is
> indeed safer.  However, simply passing a buffer of size INET6_ADDRSTRLEN =
is also
> guaranteed to work for any address that we support and saves the need for=
 the
> extra argument.  Alternatively, if you know the family or can look it up =
via
> l_rtnl_*_get_family(), you can use INET_ADDRSTRLEN for ipv4 getters.  May=
be this
> is more of a documentation issue?
>
> If you look at how iwd uses these functions, the extra argument is unnece=
ssary.
>
> Can you share more info about what made you propose this change?  Are you=
 using
> these functions in ways where the buffer size argument would be advantage=
ous?
>
> Regards,
> -Denis
--===============4522026815078728139==--

