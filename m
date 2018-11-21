Content-Type: multipart/mixed; boundary="===============0023778147826993691=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 02/16] cert: Accept lists of CA certificates instead of one
Date: Wed, 21 Nov 2018 11:23:35 -0600
Message-ID: <04ca0423-906a-afd2-2845-8168148d4d23@gmail.com>
In-Reply-To: <20181121150903.24437-2-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0023778147826993691==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> -	/*
> -	 * If a CA cert was supplied, restrict verify_ring now so
> -	 * everything else in certchain is validated against the CA.
> -	 * Otherwise, verify_ring will be restricted after the root of
> -	 * certchain is added to verify_ring by
> -	 * cert_verify_with_keyring().
> -	 */
> -	if (ca_ring && !l_keyring_restrict(verify_ring,
> -						L_KEYRING_RESTRICT_ASYM_CHAIN,
> -						ca_ring)) {
> -		return false;
> +			ca_key =3D l_cert_get_pubkey(ca);
> +			if (!ca_key)
> +				return false;
> +
> +			if (!l_keyring_link(ca_ring, ca_key)) {
> +				l_key_free(ca_key);
> +				return false;
> +			}
> +		}
> +
> +		if (!l_keyring_restrict(verify_ring,
> +					L_KEYRING_RESTRICT_ASYM_CHAIN,
> +					ca_ring))
> +			return false;
>   	}
>   =

> -	return certchain_verify_with_keyring(chain->leaf, verify_ring, ca_cert,
> +	return certchain_verify_with_keyring(chain->leaf, verify_ring, ca_certs,
>   						ca_ring);
>   }

So can we switch to a non-recursive version now?

Regards,
-Denis

--===============0023778147826993691==--

