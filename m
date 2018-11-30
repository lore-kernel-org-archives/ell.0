Content-Type: multipart/mixed; boundary="===============4262366226217259963=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/9] ecdh: moved ECDH from IWD
Date: Thu, 29 Nov 2018 21:38:58 -0600
Message-ID: <08aa5ae9-b4e4-d4b8-1554-54070a411d95@gmail.com>
In-Reply-To: <20181129220808.22151-3-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4262366226217259963==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,


> + * Generate a private/public key pair. All inputs are expected in little=
-endian.
> + */
> +bool l_ecdh_generate_key_pair(struct l_ecc_curve *curve, void *private,
> +					size_t priv_len, void *public,
> +					size_t pub_len);

Public is just a point on the curve right? So should this be something like:

bool l_ecdh_generate_key_pair(const struct l_ecc_curve *curve,
				struct l_ecc_point *out_public,
				struct l_ecc_constant *out_private);
?

> +/*
> + * Generate a shared secret from a private/public key. All inputs are ex=
pected
> + * in little-endian.
> + */
> +bool l_ecdh_generate_shared_secret(struct l_ecc_curve *curve,
> +						const void *private,
> +						const void *other_public,
> +						size_t pub_len, void *secret,
> +						size_t secret_len);

Similarly here maybe:

struct l_ecc_point *other_public =3D l_ecc_point_new(curve, data, len);

bool l_ecdh_generate_shared_secret(struct l_ecc_constant *private,
				struct l_ecc_point *other_public,
				void *out_secret,
				size_t out_secret_len);

?

Regards,
-Denis

--===============4262366226217259963==--

