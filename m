Content-Type: multipart/mixed; boundary="===============3416999740651214029=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 08/11] tls: Stricter certificate chain verification
Date: Thu, 01 Nov 2018 14:56:29 -0500
Message-ID: <b9811470-6ccf-b7ba-92ed-4f34a18347e9@gmail.com>
In-Reply-To: <20181101115453.10373-8-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3416999740651214029==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/01/2018 06:54 AM, Andrew Zaborowski wrote:
> Rewrite tls_cert_verify_certchain to fix a long standing issue where it
> didn't verify that each certificate in the chain was trusted by the next
> one.  Since certificates were only being added to the two keyrings and
> never removed the order in the chain was not being verified.  Now use a
> single ring and remove the previously added certificates from it once
> they've been used to show that the next certificate was signed with one
> of them.  Add lots of comments.

So I actually like this approach a lot.  Few nitpicks:

> ---
>   ell/tls.c | 206 +++++++++++++++++++++++++++++++++---------------------
>   1 file changed, 125 insertions(+), 81 deletions(-)
> =

> diff --git a/ell/tls.c b/ell/tls.c
> index fbbc1bf..7f42240 100644
> --- a/ell/tls.c
> +++ b/ell/tls.c
> @@ -2687,27 +2687,99 @@ static const struct pkcs1_encryption_oid {
>   	},
>   };
>   =

> +static struct l_key *tls_cert_verify_root(struct l_key *key,
> +						struct l_keyring *ring,
> +						struct l_queue *roots)
> +{
> +	const struct l_queue_entry *entry;
> +	unsigned int i, n =3D l_queue_length(roots);
> +	struct l_key *root_keys[n];

So Marcel will likely hunt you down for VLA usage.  So maybe you want to =

rethink this.

> +	bool success =3D true;
> +
> +	/*
> +	 * Check that @key is trusted by one of @roots by linking it
> +	 * to a restricted ring containing only the roots.  If successful
> +	 * return @key leaving only @key in the keyring.
> +	 */
> +
> +	for (entry =3D l_queue_get_entries(roots), i =3D 0; i < n;
> +			entry =3D entry->next, i++) {
> +		const struct tls_cert *root =3D entry->data;
> +
> +		root_keys[i] =3D l_key_new(L_KEY_RSA, root->asn1, root->size);
> +		if (!root_keys[i] || !l_keyring_link(ring, root_keys[i]))
> +			success =3D false;

So why are we loading the CA keys into the verify ring?  Can't we just =

load all the CA keys into a temporary ring and then remove it when we're =

done?  E.g. the ca ring.

> +	}
> +
> +	if (!l_keyring_restrict(ring, L_KEYRING_RESTRICT_ASYM_CHAIN, NULL) ||
> +			!l_keyring_link(ring, key))
> +		success =3D false;

And here we could restrict the ring against the ca_ring.  If that =

succeeds, then what we can do is call l_keyring_restrict, this time with =

last argument being NULL.  Or is that not possible? Mat?

> +
> +	for (i =3D 0; i < n; i++)
> +		l_key_free(root_keys[i]);
> +

Then this just becomes l_keyring_free(ca_ring);

> +	if (success)
> +		return key;
> +
> +	l_key_free(key);
> +	return NULL;
> +}
> +
>   static void tls_key_cleanup(struct l_key **p)
>   {
> -	l_key_free_norevoke(*p);
> +	l_key_free(*p);
>   }
>   =

> -static bool tls_cert_link(struct tls_cert *cert, struct l_keyring *ring)

<snip>

> @@ -2772,43 +2840,19 @@ static void tls_keyring_cleanup(struct l_keyring =
**p)
>   bool tls_cert_verify_certchain(struct tls_cert *certchain,
>   				struct l_queue *ca_certs)
>   {
> -	L_AUTO_CLEANUP_VAR(struct l_keyring *, ca_ring, tls_keyring_cleanup);
>   	L_AUTO_CLEANUP_VAR(struct l_keyring *, verify_ring,
> -				tls_keyring_cleanup);
> +				tls_keyring_cleanup) =3D l_keyring_new();
> +	struct l_key *trusted;

This function is so simple I would consider dropping the =

L_AUTO_CLEANUP_VAR completely.

>   =

> -	ca_ring =3D NULL;
> -
> -	verify_ring =3D l_keyring_new();
>   	if (!verify_ring)
>   		return false;
>   =

> -	/*
> -	 * If CA cert(s) were supplied, restrict verify_ring now so
> -	 * everything else in certchain is validated against the CA(s).
> -	 * Otherwise, verify_ring will be restricted after the root of
> -	 * certchain is added to verify_ring by
> -	 * tls_cert_verify_with_keyring().
> -	 */
> -	if (ca_certs) {
> -		const struct l_queue_entry *entry;
> -
> -		ca_ring =3D l_keyring_new();
> -		if (!ca_ring)
> -			return false;
> -
> -		for (entry =3D l_queue_get_entries(ca_certs); entry;
> -				entry =3D entry->next)
> -			if (!tls_cert_link(entry->data, ca_ring))
> -				return false;
> -
> -		if (!l_keyring_restrict(verify_ring,
> -					L_KEYRING_RESTRICT_ASYM_CHAIN,
> -					ca_ring))
> -			return false;
> -	}
> +	trusted =3D tls_cert_verify_with_keyring(certchain, verify_ring, ca_cer=
ts);
> +	if (!trusted)
> +		return false;
>   =

> -	return tls_cert_verify_with_keyring(certchain, verify_ring, ca_certs,
> -						ca_ring);
> +	l_key_free(trusted);
> +	return true;
>   }
>   =

>   void tls_cert_free_certchain(struct tls_cert *cert)
> =


Regards,
-Denis

--===============3416999740651214029==--

