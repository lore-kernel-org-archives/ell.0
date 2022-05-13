Content-Type: multipart/mixed; boundary="===============5376453240485539930=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/13] net: Add l_net_clear_host_bits utility
Date: Fri, 13 May 2022 14:26:26 +0200
Message-ID: <CAOq732+eiU7dB=8ZDrej9BkaiTKv_U_18Y5gz=2=UYUxosYWYA@mail.gmail.com>
In-Reply-To: 9ebeb857-4ac0-9d3f-e47f-182b1758ebf9@gmail.com

--===============5376453240485539930==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Thu, 12 May 2022 at 18:02, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 5/5/22 18:15, Andrew Zaborowski wrote:
> > Add function that zeros bits after prefix_len'th bit in an address.  Put
> > it in net.h so it can be use by both netconfig.c and icmp6.c,
> > potentially others.
> > ---
> >   ell/net.h | 13 +++++++++++++
> >   1 file changed, 13 insertions(+)
> >
> > diff --git a/ell/net.h b/ell/net.h
> > index 0521d75..e193eef 100644
> > --- a/ell/net.h
> > +++ b/ell/net.h
> > @@ -61,6 +61,19 @@ static inline bool l_net_prefix_matches(const void *=
a, const void *b,
> >       return !bits || ((left ^ right) & (0xff00u >> bits)) =3D=3D 0;
> >   }
> >
> > +static inline void l_net_clear_host_bits(uint8_t *address, uint8_t pre=
fix_len,
> > +                                             uint8_t bytes)
>
> I'm not super excited about the naming.  What about l_net_prefix_from_add=
ress()?

Ok, I guess host mask is an IPv4 term with the v6 term being interface
ID.  l_net_prefix_from_address sounds good, or how about
l_net_mask_prefix?

Best regards
--===============5376453240485539930==--

