Content-Type: multipart/mixed; boundary="===============2451947389376529101=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 6/8] tls: Validate peer certificate's DNSNames against mask
Date: Fri, 23 Aug 2019 09:27:12 -0500
Message-ID: <f19e8119-346b-6a28-fe45-53cf98683ec3@gmail.com>
In-Reply-To: <20190823004138.5480-6-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2451947389376529101==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 8/22/19 7:41 PM, Andrew Zaborowski wrote:
> Also return success in the domain_mask check if any of the DNSNames in
> the peer certificate's subjectAltName extension matches any of the mask
> strings supplied.
> ---
>   ell/tls.c | 49 ++++++++++++++++++++++++++++++++++++++++++++-----
>   1 file changed, 44 insertions(+), 5 deletions(-)
> =

> diff --git a/ell/tls.c b/ell/tls.c
> index 3fe2ff5..f1d73bd 100644
> --- a/ell/tls.c
> +++ b/ell/tls.c
> @@ -675,6 +675,10 @@ ok_next:
>   =

>   static const struct asn1_oid dn_common_name_oid =3D
>   	{ 3, { 0x55, 0x04, 0x03 } };
> +static const struct asn1_oid subject_alt_name_oid =3D
> +	{ 3, { 0x55, 0x1d, 0x11 } };
> +
> +#define SAN_DNS_NAME_ID ASN1_CONTEXT_IMPLICIT(2)
>   =

>   static bool tls_cert_domains_match_mask(struct l_cert *cert, char **mas=
k)
>   {
> @@ -682,10 +686,14 @@ static bool tls_cert_domains_match_mask(struct l_ce=
rt *cert, char **mask)
>   	size_t dn_size;
>   	const char *cn =3D NULL;
>   	size_t cn_len;
> +	const uint8_t *san;
> +	size_t san_len;
> +	uint8_t san_tag;
> +	char **i;
>   =

>   	/*
>   	 * Retrieve the Common Name from the Subject DN and check if it
> -	 * matches.  TODO: possibly also look at SubjectAltName.
> +	 * matches.
>   	 */
>   =

>   	dn =3D l_cert_get_dn(cert, &dn_size);
> @@ -725,12 +733,43 @@ static bool tls_cert_domains_match_mask(struct l_ce=
rt *cert, char **mask)
>   		}
>   	}
>   =

> -	if (!cn)
> +	if (cn)
> +		for (i =3D mask; *i; i++)
> +			if (tls_domain_match_mask(cn, cn_len, *i, strlen(*i)))
> +				return true;
> +
> +	/*
> +	 * Locate SubjectAltName (RFC5280 Section 4.2.1.6) and descend into
> +	 * the sole SEQUENCE element, check if any DNSName matches.
> +	 */

So I think the recommended approach is to check all SubjectAltName =

dNSName tags first.  And only then try to match the CN, no?

> +	san =3D cert_get_extension(cert, &subject_alt_name_oid, NULL, &san_len);
> +	if (!san)
>   		return false;
>   =

> -	for (; *mask; mask++)
> -		if (tls_domain_match_mask(cn, cn_len, *mask, strlen(*mask)))
> -			return true;
> +	san =3D asn1_der_find_elem(san, san_len, 0, &san_tag, &san_len);
> +	if (unlikely(!san || san_tag !=3D ASN1_ID_SEQUENCE))
> +		return NULL;
> +
> +	end =3D san + san_len;
> +	while (san < end) {
> +		const uint8_t *value;
> +		uint8_t tag;
> +		size_t len;
> +
> +		value =3D asn1_der_find_elem(san, end - san, SAN_DNS_NAME_ID,
> +						&tag, &len);
> +		if (!value)
> +			return false;
> +
> +		/* Type is implicitly IA5STRING */
> +
> +		for (i =3D mask; *i; i++)
> +			if (tls_domain_match_mask((const char *) value, len,
> +							*i, strlen(*i)))
> +				return true;
> +
> +		san =3D value + len;
> +	}
>   =

>   	return false;
>   }
> =


Regards,
-Denis

--===============2451947389376529101==--

