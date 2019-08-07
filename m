Content-Type: multipart/mixed; boundary="===============3059758021055998996=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] tls: Pass full Subject DN contents to "ready" callback
Date: Wed, 07 Aug 2019 17:52:01 -0500
Message-ID: <70bd8438-78ab-31be-c766-314b643578ae@gmail.com>
In-Reply-To: <20190806134514.6340-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3059758021055998996==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 8/6/19 8:45 AM, Andrew Zaborowski wrote:
> Until now the ready callback would receive a displayable string as
> peer_identity (if peer was authenticated) which was either the Common
> Name or the Organization Name extracted from the subject DN in the
> peer's certificate.
> =

> In order to implement functionality similat to wpa_supplicant's
> substring_match=3D option for EAP-TLS, we need to look specifically at
> Common Name although if we have the full contents of the Subject DN
> that's even better as wpa_supplicant allows configurations to match
> against any element in the Subject DN, so if we do that iwd and wpa_s
> config files may be easier to convert in either direction.
> =

> We could also just pass the whole certificate struct to the callback but
> then we'd need to also have utilities for parsing the DN so instead we
> parse it in tls.c and convert it into the same string format that is
> used by wpa_s, openssl, etc.  Parsing that string in user code is easier
> than parsing the original DER struct.
> ---
>   ell/asn1-private.h |  1 +
>   ell/tls.c          | 76 ++++++++++++++++++++++++++++++++--------------
>   2 files changed, 55 insertions(+), 22 deletions(-)
> =


Applied, but..

> @@ -2009,45 +2034,52 @@ static char *tls_get_peer_identity_str(struct l_c=
ert *cert)
>   	if (!dn)
>   		return NULL;
>   =

> +	id_str =3D l_string_new(200);
> +
>   	end =3D dn + dn_size;
>   	while (dn < end) {
>   		const uint8_t *set, *seq, *oid, *name;
>   		uint8_t tag;
>   		size_t len, oid_len, name_len;
> +		const struct dn_element_info *info;
>   =

>   		set =3D asn1_der_find_elem(dn, end - dn, 0, &tag, &len);
>   		if (!set || tag !=3D ASN1_ID_SET)
> -			return NULL;
> +			goto error;
>   =

>   		dn =3D set + len;
>   =

>   		seq =3D asn1_der_find_elem(set, len, 0, &tag, &len);
>   		if (!seq || tag !=3D ASN1_ID_SEQUENCE)
> -			return NULL;
> +			goto error;
>   =

>   		oid =3D asn1_der_find_elem(seq, len, 0, &tag, &oid_len);
>   		if (!oid || tag !=3D ASN1_ID_OID)
> -			return NULL;
> +			goto error;
>   =

>   		name =3D asn1_der_find_elem(seq, len, 1, &tag, &name_len);
>   		if (!oid || (tag !=3D ASN1_ID_PRINTABLESTRING &&

Should this be !name and not !oid?

> -					tag !=3D ASN1_ID_UTF8STRING))
> +					tag !=3D ASN1_ID_UTF8STRING &&
> +					tag !=3D ASN1_ID_IA5STRING))
>   			continue;
>   =

> -		/* organizationName takes priority, commonName is second */
> -		if (asn1_oid_eq(&dn_organization_name_oid, oid_len, oid) ||
> -				(!printable_str &&
> -				 asn1_oid_eq(&dn_common_name_oid,
> -						oid_len, oid))) {
> -			printable_str =3D name;
> -			printable_str_len =3D name_len;
> -		}
> +		for (info =3D dn_elements; info->str; info++)
> +			if (asn1_oid_eq(&info->oid, oid_len, oid))
> +				break;
> +		if (!info->str)
> +			continue;
> +
> +		l_string_append_c(id_str, '/');
> +		l_string_append(id_str, info->str);
> +		l_string_append_c(id_str, '=3D');
> +		l_string_append_fixed(id_str, (char *) name, name_len);
>   	}
>   =

> -	if (printable_str)
> -		return l_strndup((char *) printable_str, printable_str_len);
> -	else
> -		return NULL;
> +	return l_string_unwrap(id_str);
> +
> +error:
> +	l_string_free(id_str);
> +	return NULL;
>   }
>   =

>   static void tls_finished(struct l_tls *tls)
> =


Regards,
-Denis

--===============3059758021055998996==--

