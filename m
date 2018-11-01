Content-Type: multipart/mixed; boundary="===============4904774251095182217=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 05/11] tls: Support loading multiple root CAs
Date: Thu, 01 Nov 2018 14:47:00 -0500
Message-ID: <0e8d3045-387b-1397-dad8-e47bdcfc94a9@gmail.com>
In-Reply-To: <20181101115453.10373-5-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4904774251095182217==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/01/2018 06:54 AM, Andrew Zaborowski wrote:
> If a file with multiple concatenated certificates is supplied to
> set_auth_data, load all of them and verify received certificate chains
> aginst any of them instead of just the first one.  This is also what
> wpa_supplicant does for files supplied with the ca_cert=3D setting and
> it's actually useful.  Some enterprise CAs have multiple root
> certificates and provision clients with a file that contains all of them
> concatenated and it does happen that they switch from a certificate
> chain using one root to a new chain with a different root for their wifi
> in which case our network config files break while wpa_supplicant
> configs keep working.
> =

> Also simplify tls_cert_verify_certchain slightly.

So mostly just a couple of nitpicks here:

>   =

> +struct l_queue *tls_cert_list_load_file(const char *filename)
> +{
> +	struct l_queue *pem_list;
> +	struct l_queue *cert_list;
> +	bool error =3D false;
> +
> +	pem_list =3D l_pem_load_certificate_list(filename);
> +	if (!pem_list)
> +		return NULL;
> +
> +	cert_list =3D l_queue_new();
> +
> +	while (!l_queue_isempty(pem_list)) {
> +		struct tls_cert *cert;
> +		struct l_pem_list_element *elem =3D l_queue_pop_head(pem_list);
> +		uint8_t *der =3D elem->content;
> +
> +		if (!elem->len || der[0] !=3D ASN1_ID_SEQUENCE)
> +			error =3D true;

Can we actually not do that?  Lets bugger out right away.  No sense in =

performing additional work when we know that we've failed already.

> +
> +		cert =3D l_malloc(sizeof(struct tls_cert) + elem->len);
> +		cert->size =3D elem->len;
> +		cert->issuer =3D NULL;
> +		memcpy(cert->asn1, der, cert->size);
> +		l_queue_push_tail(cert_list, cert);
> +		l_free(elem->content);
> +		l_free(elem);

l_pem_free()?

> +	}
> +
> +	l_queue_destroy(pem_list, NULL);
> +
> +	if (!error)
> +		return cert_list;
> +
> +	l_queue_destroy(cert_list, l_free);
> +	return NULL;
> +}
> +
>   int tls_cert_from_certificate_list(const void *data, size_t len,
>   					struct tls_cert **out_certchain)
>   {

Regards,
-Denis

--===============4904774251095182217==--

