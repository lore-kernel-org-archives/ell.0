Content-Type: multipart/mixed; boundary="===============4314303759439948740=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/4] tls: Implement l_tls_set_domain_mask
Date: Tue, 20 Aug 2019 14:27:13 -0500
Message-ID: <d48452e1-9cdd-d0d5-00bb-5f4afa43db72@gmail.com>
In-Reply-To: <20190817002834.15208-3-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4314303759439948740==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 8/16/19 7:28 PM, Andrew Zaborowski wrote:
> Allow user to set a mask that the a peer certificate's subject CN
> has to match.
> ---
>   ell/ell.sym       |   1 +
>   ell/tls-private.h |   1 +
>   ell/tls.c         | 132 ++++++++++++++++++++++++++++++++++++++++++++++
>   ell/tls.h         |  16 ++++++
>   4 files changed, 150 insertions(+)
> =


<snip>

> diff --git a/ell/tls.c b/ell/tls.c
> index b1fec9f..e4c9a1e 100644
> --- a/ell/tls.c
> +++ b/ell/tls.c
> @@ -629,6 +629,120 @@ static const struct tls_hash_algorithm *tls_set_prf=
_hmac(struct l_tls *tls)
>   	return NULL;
>   }
>   =

> +static bool tls_domain_match_mask(const char *name, size_t name_len,
> +					const char *mask, size_t mask_len)
> +{
> +	bool at_start =3D true;
> +
> +	while (1) {
> +		const char *name_seg_end =3D memchr(name, '.', name_len);
> +		const char *mask_seg_end =3D memchr(mask, '.', mask_len);
> +		size_t name_seg_len =3D name_seg_end ?
> +			(size_t) (name_seg_end - name) : name_len;
> +		size_t mask_seg_len =3D mask_seg_end ?
> +			(size_t) (mask_seg_end - mask) : mask_len;
> +
> +		if (mask_seg_len =3D=3D 1 && mask[0] =3D=3D '*') {
> +			/*
> +			 * A * at the beginning of the mask matches any
> +			 * number of labels.
> +			 */
> +			if (at_start && name_seg_end &&
> +					tls_domain_match_mask(name_seg_end + 1,
> +						name_len - name_seg_len - 1,
> +						mask, mask_len))
> +				return true;
> +
> +			goto ok_next;
> +		}
> +
> +		if (name_seg_len !=3D mask_seg_len ||
> +				memcmp(name, mask, name_seg_len))
> +			return false;
> +
> +ok_next:
> +		/* If either string ends here both must end here */
> +		if (!name_seg_end || !mask_seg_end)
> +			return !name_seg_end && !mask_seg_end;
> +
> +		at_start =3D false;
> +		name =3D name_seg_end + 1;
> +		name_len -=3D name_seg_len - 1;
> +		mask =3D mask_seg_end + 1;
> +		mask_len -=3D mask_seg_len - 1;
> +	}
> +}
> +
> +static const struct asn1_oid dn_common_name_oid =3D
> +	{ 3, { 0x55, 0x04, 0x03 } };
> +
> +static bool tls_cert_subject_match_mask(struct l_cert *cert, const char =
*mask)
> +{
> +	const uint8_t *dn, *end;
> +	size_t dn_size;
> +	const char *cn =3D NULL;
> +	size_t cn_len;
> +
> +	/*
> +	 * Retrieve the Common Name from the Subject DN and check if it
> +	 * matches.  TODO: possibly also look at SubjectAltName.

We definitely need to look in the SubjectAltName dNSName extensions for =

Hotspot.  So can we add that as well?

> +	 */
> +
> +	dn =3D l_cert_get_dn(cert, &dn_size);
> +	if (!dn)
> +		return false;
> +
> +	end =3D dn + dn_size;
> +	while (dn < end) {
> +		const uint8_t *set, *seq, *oid, *name;
> +		uint8_t tag;
> +		size_t len, oid_len, name_len;
> +
> +		set =3D asn1_der_find_elem(dn, end - dn, 0, &tag, &len);
> +		if (!set || tag !=3D ASN1_ID_SET)
> +			return false;
> +
> +		dn =3D set + len;

Do you really mean to do this in the loop?

> +
> +		seq =3D asn1_der_find_elem(set, len, 0, &tag, &len);
> +		if (!seq || tag !=3D ASN1_ID_SEQUENCE)
> +			return false;
> +
> +		oid =3D asn1_der_find_elem(seq, len, 0, &tag, &oid_len);
> +		if (!oid || tag !=3D ASN1_ID_OID)
> +			return false;
> +
> +		name =3D asn1_der_find_elem(seq, len, 1, &tag, &name_len);
> +		if (!name || (tag !=3D ASN1_ID_PRINTABLESTRING &&
> +					tag !=3D ASN1_ID_UTF8STRING &&
> +					tag !=3D ASN1_ID_IA5STRING))
> +			continue;
> +
> +		if (asn1_oid_eq(&dn_common_name_oid, oid_len, oid)) {
> +			cn =3D (const char *) name;
> +			cn_len =3D name_len;
> +			break;
> +		}
> +	}
> +
> +	if (!cn)
> +		return false;
> +
> +	while (1) {
> +		const char *mask_end =3D strchr(mask, ';') ?: mask + strlen(mask);
> +
> +		if (tls_domain_match_mask(cn, cn_len, mask, mask_end - mask))
> +			return true;
> +
> +		if (!mask_end[0])
> +			break;
> +
> +		mask =3D mask_end + 1;
> +	}
> +
> +	return false;
> +}
> +
>   #define SWITCH_ENUM_TO_STR(val) \
>   	case (val):		\
>   		return L_STRINGIFY(val);
> @@ -1793,6 +1907,15 @@ static void tls_handle_certificate(struct l_tls *t=
ls,
>   		goto done;
>   	}
>   =

> +	if (tls->subject_mask && !tls_cert_subject_match_mask(leaf,
> +							tls->subject_mask)) {
> +		TLS_DISCONNECT(TLS_ALERT_BAD_CERT, 0,
> +				"Peer certificate's subject domain "
> +				"doesn't match %s", tls->subject_mask);
> +
> +		goto done;
> +	}
> +
>   	/* Save the end-entity certificate and free the chain */
>   	der =3D l_cert_get_der_data(leaf, &der_len);
>   	tls->peer_cert =3D l_cert_new_from_der(der, der_len);
> @@ -2420,6 +2543,7 @@ LIB_EXPORT void l_tls_free(struct l_tls *tls)
>   =

>   	l_tls_set_cacert(tls, NULL);
>   	l_tls_set_auth_data(tls, NULL, NULL, NULL);
> +	l_tls_set_domain_mask(tls, NULL);
>   =

>   	tls_reset_handshake(tls);
>   	tls_cleanup_handshake(tls);
> @@ -2766,6 +2890,14 @@ LIB_EXPORT void l_tls_set_version_range(struct l_t=
ls *tls,
>   		max_version : TLS_MAX_VERSION;
>   }
>   =

> +LIB_EXPORT void l_tls_set_domain_mask(struct l_tls *tls,
> +					const char *mask)

Actually I wonder if it would make your life easier if the mask was a =

char **?  E.g. a strv array?  Note that l_settings already has a method =

for getting lists of strings.  So this is what we would use in iwd most =

likely anyway.  e.g. l_settings_get_string_list()

> +{
> +	l_free(tls->subject_mask);
> +
> +	tls->subject_mask =3D l_strdup(mask);
> +}
> +
>   LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls_alert_desc desc)
>   {
>   	switch (desc) {
> diff --git a/ell/tls.h b/ell/tls.h
> index b0db34f..d860459 100644
> --- a/ell/tls.h
> +++ b/ell/tls.h
> @@ -117,6 +117,22 @@ void l_tls_set_version_range(struct l_tls *tls,
>   				enum l_tls_version min_version,
>   				enum l_tls_version max_version);
>   =

> +/*
> + * Set a mask for domain names contained in the peer certificate
> + * (eg. the subject Common Name) to be matched against.  If none of the
> + * domains match the mask, authentication will fail.
> + *
> + * Multiple masks can be joined using semicolons to form alternatives.
> + * The masks are each split into segments at the dot characters and each
> + * segment must match the corresponding label of the domain name --
> + * a domain name is a sequence of labels joined by dots.  An asterisk
> + * segment in the mask matches any label.  An asterisk segment at the
> + * beginning of the mask matches any numer of labels from the beginning
> + * of the domain string.
> + */

Can we move this documentation to tls.c instead and put the normal doc =

formatting around it?

> +void l_tls_set_domain_mask(struct l_tls *tls,
> +				const char *mask);
> +
>   const char *l_tls_alert_to_str(enum l_tls_alert_desc desc);
>   =

>   enum l_checksum_type;
> =


Regards,
-Denis

--===============4314303759439948740==--

