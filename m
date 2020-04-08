Content-Type: multipart/mixed; boundary="===============0956822713557964235=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] cert: Fix verification of the 2nd certificate in chain
Date: Wed, 08 Apr 2020 15:09:59 +0000
Message-ID: <f21cc353-a9cc-f03f-a78d-01a6a47cbc94@gmail.com>
In-Reply-To: <20200407174551.9505-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0956822713557964235==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/7/20 12:45 PM, Andrew Zaborowski wrote:
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
>   ell/cert.c | 17 ++++++-----------
>   1 file changed, 6 insertions(+), 11 deletions(-)
> =

> diff --git a/ell/cert.c b/ell/cert.c
> index d1f58d7..dc6b845 100644
> --- a/ell/cert.c
> +++ b/ell/cert.c
> @@ -454,6 +454,7 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain=
 *chain,
>   	struct l_cert *cert;
>   	struct l_key *prev_key =3D NULL;
>   	int verified =3D 0;
> +	bool ca_match;
>   	static char error_buf[200];
>   =

>   	if (unlikely(!chain || !chain->leaf))
> @@ -464,6 +465,7 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain=
 *chain,
>   		RETURN_ERROR("Can't create verify keyring");
>   =

>   	cert =3D chain->ca;
> +	ca_match =3D cert_is_in_set(cert, ca_certs);
>   =

>   	/*
>   	 * For TLS compatibility the trusted root CA certificate is
> @@ -480,16 +482,9 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchai=
n *chain,
>   	 * cert in the chain if it is identical to one of the trusted CA
>   	 * certificates.  It also happens to work around a kernel issue
>   	 * preventing self-signed certificates missing the AKID
> -	 * extension from being linked to a keyring.
> +	 * extension from being linked to a restricted keyring.
>   	 */

So is this comment still valid now that you've taken out the if block =

that takes care of this?  At the very least it seems completely out of =

place now.

Do we have a unit test with a certchain where the root cert doesn't have =

AKID extension?

> -	if (cert_is_in_set(cert, ca_certs)) {
> -		verified++;
> -		cert =3D cert->issued;
> -		if (!cert)
> -			return true;
> -
> -		prev_key =3D cert_try_link(cert, verify_ring);

So remind me again what the actual problem was? The code here is =

'optimizing' by not trying to link the root cert at all, supposedly =

because it might be self-signed and missing the AKID extension.

> -	} else if (ca_certs) {
> +	if (ca_certs && !ca_match) {
>   		ca_ring =3D cert_set_to_keyring(ca_certs, error_buf);
>   		if (!ca_ring) {
>   			if (error)

But now you link it always?

Regards,
-Denis
--===============0956822713557964235==--

