Content-Type: multipart/mixed; boundary="===============1995257653653951136=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: Re: [PATCH 3/9] ecdh: moved ECDH from IWD
Date: Mon, 03 Dec 2018 10:31:44 -0800
Message-ID: <bb8e881bfcf957df7554b21278921cbffa79046e.camel@linux.intel.com>
In-Reply-To: <08aa5ae9-b4e4-d4b8-1554-54070a411d95@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1995257653653951136==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 2018-11-29 at 21:38 -0600, Denis Kenzior wrote:
> Hi James,
> =

> =

> > + * Generate a private/public key pair. All inputs are expected in
> > little-endian.
> > + */
> > +bool l_ecdh_generate_key_pair(struct l_ecc_curve *curve, void
> > *private,
> > +					size_t priv_len, void *public,
> > +					size_t pub_len);
> =

> Public is just a point on the curve right? So should this be
> something like:
> =

> bool l_ecdh_generate_key_pair(const struct l_ecc_curve *curve,
> 				struct l_ecc_point *out_public,
> 				struct l_ecc_constant *out_private);
> ?
Yes it is just a point on the curve, but I don't think that most users
of this API need or care to know to that level of detail. Also,
generating the shared secret supports compressed coordinates where only
the X coordinate is given. In this case the half public key is coming
from the network, so its much more convenient just feeding it that raw
data that converting it to a point.

> =

> > +/*
> > + * Generate a shared secret from a private/public key. All inputs
> > are expected
> > + * in little-endian.
> > + */
> > +bool l_ecdh_generate_shared_secret(struct l_ecc_curve *curve,
> > +						const void *private,
> > +						const void
> > *other_public,
> > +						size_t pub_len, void
> > *secret,
> > +						size_t secret_len);
> =

> Similarly here maybe:
> =

> struct l_ecc_point *other_public =3D l_ecc_point_new(curve, data, len);
> =

> bool l_ecdh_generate_shared_secret(struct l_ecc_constant *private,
> 				struct l_ecc_point *other_public,
> 				void *out_secret,
> 				size_t out_secret_len);
> =

> ?
> =

> Regards,
> -Denis


--===============1995257653653951136==--

