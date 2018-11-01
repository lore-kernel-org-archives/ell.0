Content-Type: multipart/mixed; boundary="===============2448593896347262876=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 09/11] tls: Support loading certificate chains from file
Date: Thu, 01 Nov 2018 15:48:18 -0500
Message-ID: <086a98ce-580f-a9d6-2ac5-384523214284@gmail.com>
In-Reply-To: <20181101115453.10373-9-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2448593896347262876==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/01/2018 06:54 AM, Andrew Zaborowski wrote:
> When loading the file supplied with l_tls_set_auth_data to be sent as
> Server Certificate or Client Certificate, allow for the possibility
> of loading a chain of certificates instead of just one if the file
> contains multiple concatenated PEM certificates, ordered from the
> end-entity to the CA.  The chain has to end with one of the CA certs
> set through l_tls_set_cacert or a cert directly signed by one of them,
> if l_tls_set_cacert was called.
> ---
>   ell/tls.c | 69 +++++++++++++++++++++++++++++++++++++++++--------------
>   1 file changed, 52 insertions(+), 17 deletions(-)
> =

> diff --git a/ell/tls.c b/ell/tls.c
> index 7f42240..0aa10e7 100644
> --- a/ell/tls.c
> +++ b/ell/tls.c
> @@ -754,7 +754,7 @@ static bool tls_send_certificate(struct l_tls *tls)
>   =

>   	if (tls->server && !cert) {
>   		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CERT,
> -				"Loading server certificate %s failed",
> +				"Loading server certificate chain %s failed",
>   				tls->cert_path);
>   		return false;
>   	}
> @@ -828,7 +828,7 @@ static bool tls_send_certificate(struct l_tls *tls)
>   	if (cert)
>   		tls->cert_sent =3D true;
>   =

> -	l_free(cert);
> +	tls_cert_free_certchain(cert);
>   =

>   	return true;
>   }
> @@ -2570,27 +2570,41 @@ const char *tls_handshake_state_to_str(enum tls_h=
andshake_state state)
>   =

>   struct tls_cert *tls_cert_load_file(const char *filename)
>   {
> -	uint8_t *der;
> -	size_t len;
> -	struct tls_cert *cert;
> +	struct l_queue *pem_list;
> +	struct tls_cert *chain =3D NULL;
> +	struct tls_cert **root =3D &chain;
> +	bool error =3D false;
>   =

> -	der =3D l_pem_load_certificate(filename, &len);
> -	if (!der)
> +	pem_list =3D l_pem_load_certificate_list(filename);
> +	if (!pem_list)
>   		return NULL;
>   =

> -	if (!len || der[0] !=3D ASN1_ID_SEQUENCE) {
> -		l_free(der);
> -		return NULL;
> +	while (!l_queue_isempty(pem_list)) {
> +		struct tls_cert *cert;
> +		struct l_pem_list_element *elem =3D l_queue_pop_head(pem_list);
> +		uint8_t *der =3D elem->content;
> +
> +		if (!elem->len || der[0] !=3D ASN1_ID_SEQUENCE)
> +			error =3D true;
> +
> +		cert =3D l_malloc(sizeof(struct tls_cert) + elem->len);
> +		cert->size =3D elem->len;
> +		cert->issuer =3D NULL;
> +		memcpy(cert->asn1, der, cert->size);
> +		l_free(elem->content);
> +		l_free(elem);
> +
> +		*root =3D cert;
> +		root =3D &cert->issuer;

Isn't this doing almost exactly the same thing as a function in patch 5?

>   	}
>   =

> -	cert =3D l_malloc(sizeof(struct tls_cert) + len);
> -	cert->size =3D len;
> -	cert->issuer =3D NULL;
> -	memcpy(cert->asn1, der, len);
> +	l_queue_destroy(pem_list, NULL);
>   =

> -	l_free(der);
> +	if (!error)
> +		return chain;
>   =

> -	return cert;
> +	tls_cert_free_certchain(chain);
> +	return NULL;
>   }
>   =

>   struct l_queue *tls_cert_list_load_file(const char *filename)

Regards,
-Denis

--===============2448593896347262876==--

