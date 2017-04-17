Content-Type: multipart/mixed; boundary="===============1360900073582940499=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] key: Use keyring restriction keyctl
Date: Mon, 17 Apr 2017 11:39:54 -0500
Message-ID: <d3881001-2609-be46-19c6-9b5e1a42932d@gmail.com>
In-Reply-To: <20170414191649.3171-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1360900073582940499==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 04/14/2017 02:16 PM, Mat Martineau wrote:
> Now that the restricted keyring patches have been applied to keys-next
> and are on track for the v4.12 merge window, ELL needs to be updated for
> the final API.
>
> There are two significant changes from the previous API:
>
> 1. Key restrictions are now applied in a separate step after a keyring
> is created, not at creation time.
>
> 2. The first key added to an empty, "chain" restricted keyring no longer
> bypasses the signature check.

Interesting.  Why was there this behavior in the first place?

>
> The latter required a change to l_keyring_new() so that the root key
> could be added to a keyring after it is created but before it is
> restricted. There's a new l_keyring_restrict() function to restrict an
> existing keyring.
> ---
>  ell/key.c | 76 ++++++++++++++++++++++++++++++++++++++++-----------------=
------
>  ell/key.h | 13 ++++++-----
>  ell/tls.c | 20 ++++++++++++-----
>  3 files changed, 69 insertions(+), 40 deletions(-)
>

<snip>

> diff --git a/ell/tls.c b/ell/tls.c
> index 06e3341..cd85fad 100644
> --- a/ell/tls.c
> +++ b/ell/tls.c
> @@ -2471,7 +2471,8 @@ static void tls_key_cleanup(struct l_key **p)
>
>  static int tls_cert_verify_with_keyring(struct tls_cert *cert,
>  						struct l_keyring *ring,
> -						struct tls_cert *root)
> +						struct tls_cert *root,
> +						struct l_keyring *trusted)
>  {
>  	if (!cert)
>  		return true;
> @@ -2488,14 +2489,21 @@ static int tls_cert_verify_with_keyring(struct tl=
s_cert *cert,
>  			!memcmp(cert->asn1, root->asn1, root->size))
>  		return true;
>
> -	if (tls_cert_verify_with_keyring(cert->issuer, ring, root)) {
> +	if (tls_cert_verify_with_keyring(cert->issuer, ring, root, trusted)) {
> +		bool result;
>  		L_AUTO_CLEANUP_VAR(struct l_key *, key, tls_key_cleanup);
>
>  		key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->size);
>  		if (!key)
>  			return false;
>
> -		return l_keyring_link(ring, key);
> +		result =3D l_keyring_link(ring, key);
> +
> +		if (result && !cert->issuer)
> +			result =3D l_keyring_restrict(ring, L_KEYRING_RESTRICT_ASYM_CHAIN,
> +							trusted);
> +

So it looks like we are:

1. recursively calling tls_cert_verify_with_keyring() until we find the =

'root' of the certchain.
2. load the root of the certchain and link it into the verify_ring
3. restrict it to the trusted ca_ring
4. For all subsequent entries in the certchain, we try to link the cert =

into the verify_ring which will search the verify_ring or the trusted =

ca_ring for the key that can verify this one.

However, there's a comment captured a few lines above that states:

          * RFC5246 7.4.2:
          * "Because certificate validation requires that root keys be
          * distributed independently, the self-signed certificate that
          * specifies the root certificate authority MAY be omitted from
          * the chain, under the assumption that the remote end must
          * already possess it in order to validate it in any case."

So if the server omits the root CA key, and we blindly trust the first =

certificate in the chain, isn't there a problem?

> +		return result;
>  	}
>
>  	return false;
> @@ -2520,7 +2528,7 @@ bool tls_cert_verify_certchain(struct tls_cert *cer=
tchain,
>  		L_AUTO_CLEANUP_VAR(struct l_key *, ca_key, tls_key_cleanup);
>  		ca_key =3D NULL;
>
> -		ca_ring =3D l_keyring_new(L_KEYRING_SIMPLE, NULL);
> +		ca_ring =3D l_keyring_new();
>  		if (!ca_ring)
>  			return false;
>
> @@ -2529,11 +2537,11 @@ bool tls_cert_verify_certchain(struct tls_cert *c=
ertchain,
>  			return false;
>  	}
>
> -	verify_ring =3D l_keyring_new(L_KEYRING_TRUSTED_ASYM_CHAIN, ca_ring);
> +	verify_ring =3D l_keyring_new();
>  	if (!verify_ring)
>  		return false;
>
> -	return tls_cert_verify_with_keyring(certchain, verify_ring, ca_cert);
> +	return tls_cert_verify_with_keyring(certchain, verify_ring, ca_cert, ca=
_ring);
>  }
>
>  void tls_cert_free_certchain(struct tls_cert *cert)
>

Regards,
-Denis

--===============1360900073582940499==--

