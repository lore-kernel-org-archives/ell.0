Content-Type: multipart/mixed; boundary="===============1625625066611029998=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 4/5] util: add l_secure_select_byte
Date: Fri, 04 Feb 2022 09:51:29 -0800
Message-ID: <554cdd2aa640cc7ebb34768e9bdfe78dacef1ca3.camel@gmail.com>
In-Reply-To: de076f60-25d4-c950-799f-87327ce1cf2f@gmail.com

--===============1625625066611029998==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 2022-02-04 at 11:35 -0600, Denis Kenzior wrote:
> Hi James,
> =

> On 2/4/22 11:06, James Prestwood wrote:
> > This was taken from IWD and modified slightly to act off a boolean
> > rather than a 0xff/0x00 byte to stay consistent with
> > l_secure_select
> > ---
> > =C2=A0 ell/util.h | 15 +++++++++++++++
> > =C2=A0 1 file changed, 15 insertions(+)
> > =

> > diff --git a/ell/util.h b/ell/util.h
> > index 9d4e36c..d390d27 100644
> > --- a/ell/util.h
> > +++ b/ell/util.h
> > @@ -425,6 +425,21 @@ static inline void l_secure_select(bool
> > select_left,
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0o[i] =3D r[i] ^ ((l[i] ^ r[i]) & mask);
> > =C2=A0 }
> > =C2=A0 =

> > +/*
> > + * Returns either true_value or false_value (depending if mask is
> > 0xFF or 0x00
> > + * respectively).
> > + * This constant time selection method allows to keep an identical
> > memory
> > + * access pattern.
> > + */
> > +static inline uint8_t l_secure_select_byte(bool select_true,
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0const uint8_t true_value,
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0const uint8_t false_value)
> > +{
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0uint8_t mask =3D -(!!select_=
true);
> > +
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return (mask & true_value) |=
 (~mask & false_value);
> > +}
> > +
> =

> Why not use secure_select from ell/useful.h ?

Ugh, we should keep these things in one place, unless there was a
reason for doing it this way?

> =

> > =C2=A0 #ifdef __cplusplus
> > =C2=A0 }
> > =C2=A0 #endif
> > =

> =

> Regards,
> -Denis


--===============1625625066611029998==--

