Content-Type: multipart/mixed; boundary="===============8263197372867621005=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/5] cert: Fix verification of the 2nd certificate in chain
Date: Thu, 09 Apr 2020 15:46:27 +0000
Message-ID: <3c4255fa-0c56-87bd-b20d-69a7a04f4ce7@gmail.com>
In-Reply-To: <20200408233724.25721-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8263197372867621005==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/8/20 6:37 PM, Andrew Zaborowski wrote:
> In the case that the trusted CA certificates are provided to
> l_certchain_verify() and one of them binary-matches the top CA
> certificate in the chain being verified, we'd skip linking it to the
> keyring and we'd link the next certificate directly.  As a result
> that second certificate would be linked to an empty unrestricted keyring
> and would not be verified at all.
> =

> Instead add the top CA to the keyring and restrict it the same way we
> proceed when no trusted CAs are provided.
> ---
>   ell/cert.c | 33 +++++++++++++++++++--------------
>   1 file changed, 19 insertions(+), 14 deletions(-)
> =


<snip>

> @@ -477,19 +479,22 @@ LIB_EXPORT bool l_certchain_verify(struct l_certcha=
in *chain,
>   	 * already possess it in order to validate it in any case."
>   	 *
>   	 * The following is an optimization to skip verifying the root
> -	 * cert in the chain if it is identical to one of the trusted CA
> -	 * certificates.  It also happens to work around a kernel issue
> -	 * preventing self-signed certificates missing the AKID
> -	 * extension from being linked to a keyring.
> +	 * cert in the chain if it is bitwise-identical to one of the
> +	 * trusted CA certificates.  In that case we don't have to load
> +	 * all of the trusted certificates into the kernel, link them
> +	 * to @ca_ring or link @ca_ring to @verify_ring, instead we
> +	 * load the first certificate into @verify_ring before we set
> +	 * the restric mode on it, same as when no trusted CAs are
> +	 * provided.
> +	 *
> +	 * Note this happens to work around a kernel issue preventing
> +	 * self-signed certificates missing the optional AKID extension
> +	 * from being linked to a restricted keyring.  That issue would
> +	 * have affected us if the trusted CA set included such
> +	 * certificate and the same certificate was at the root of
> +	 * the chain.
>   	 */

This comment makes things _much_ clearer now.  I love it.

All applied, thanks.

Regards,
-Denis
--===============8263197372867621005==--

