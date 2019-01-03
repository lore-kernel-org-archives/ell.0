Content-Type: multipart/mixed; boundary="===============1013526741222368460=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 02/17] tls: Add Hello extension sending support
Date: Wed, 02 Jan 2019 18:36:57 -0600
Message-ID: <3c99fee2-77f9-c34f-f699-a14bf17f602d@gmail.com>
In-Reply-To: <20190101194939.5974-2-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1013526741222368460==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/01/2019 01:49 PM, Andrew Zaborowski wrote:
> Declare a struct for ServerHello/ClientHello extensions with write and
> handle callbacks, modify our ServerHello and ClientHello message
> builders to append the extensions to the messages.
> ---
>   ell/tls-private.h |  18 +++++++++
>   ell/tls.c         | 101 ++++++++++++++++++++++++++++++++++++++++++----
>   2 files changed, 112 insertions(+), 7 deletions(-)
> =


<snip>

> @@ -812,11 +814,12 @@ static void tls_tx_handshake(struct l_tls *tls, int=
 type, uint8_t *buf,
>   =

>   static bool tls_send_client_hello(struct l_tls *tls)
>   {
> -	uint8_t buf[128 + L_ARRAY_SIZE(tls_compression_pref) +
> +	uint8_t buf[1024 + L_ARRAY_SIZE(tls_compression_pref) +
>   			2 * L_ARRAY_SIZE(tls_cipher_suite_pref)];

So you're sort of depending on the buffer to be large enough, maybe not =

a great strategy long-term.

>   	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
>   	uint8_t *len_ptr;
> -	int i;
> +	unsigned int i;
> +	uint8_t *extensions_len_ptr;
>   =

>   	/* Fill in the Client Hello body */
>   =

> @@ -832,7 +835,7 @@ static bool tls_send_client_hello(struct l_tls *tls)
>   	len_ptr =3D ptr;
>   	ptr +=3D 2;
>   =

> -	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_cipher_suite_pref); i++) {
> +	for (i =3D 0; i < L_ARRAY_SIZE(tls_cipher_suite_pref); i++) {
>   		if (!tls_cipher_suite_is_compatible(tls,
>   						&tls_cipher_suite_pref[i],
>   						NULL))
> @@ -850,17 +853,58 @@ static bool tls_send_client_hello(struct l_tls *tls)
>   	l_put_be16((ptr - len_ptr - 2), len_ptr);
>   	*ptr++ =3D L_ARRAY_SIZE(tls_compression_pref);
>   =

> -	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_compression_pref); i++)
> +	for (i =3D 0; i < L_ARRAY_SIZE(tls_compression_pref); i++)
>   		*ptr++ =3D tls_compression_pref[i].id;
>   =

> +	extensions_len_ptr =3D ptr;
> +	ptr +=3D 2;
> +
> +	for (i =3D 0; tls_extensions[i].name; i++) {
> +		const struct tls_hello_extension *extension =3D
> +			&tls_extensions[i];
> +		ssize_t ext_len;
> +
> +		/*
> +		 * Note: could handle NULL client_write with non-NULL
> +		 * server_handle or server_handle_absent as "server-oriented"
> +		 * extension (7.4.1.4) and write empty extension_data and
> +		 * simliarly require empty extension_data in
> +		 * tls_handle_client_hello if client_handle NULL.
> +		 */
> +		if (!extension->client_write)
> +			continue;
> +
> +		ext_len =3D extension->client_write(tls, ptr + 4,
> +						buf + sizeof(buf) - (ptr + 4));
> +		if (ext_len =3D=3D -ENOMSG)
> +			continue;
> +
> +		if (ext_len < 0) {
> +			TLS_DEBUG("%s extension's client_write: %s",
> +					extension->name, strerror(-ext_len));
> +			return false;
> +		}
> +
> +		l_put_be16(extension->id, ptr + 0);
> +		l_put_be16(ext_len, ptr + 2);
> +		ptr +=3D 4 + ext_len;
> +	}
> +
> +	if (ptr > extensions_len_ptr + 2)
> +		l_put_be16(ptr - (extensions_len_ptr + 2), extensions_len_ptr);
> +	else /* Skip the length if no extensions */
> +		ptr =3D extensions_len_ptr;
> +
>   	tls_tx_handshake(tls, TLS_CLIENT_HELLO, buf, ptr - buf);
>   	return true;
>   }
>   =

> -static void tls_send_server_hello(struct l_tls *tls)
> +static bool tls_send_server_hello(struct l_tls *tls, struct l_queue *ext=
ensions)
>   {
> -	uint8_t buf[128];
> +	uint8_t buf[1024];
>   	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
> +	uint8_t *extensions_len_ptr;
> +	const struct l_queue_entry *entry;
>   =

>   	/* Fill in the Server Hello body */
>   =

> @@ -878,7 +922,49 @@ static void tls_send_server_hello(struct l_tls *tls)
>   =

>   	*ptr++ =3D tls->pending.compression_method->id;
>   =

> +	extensions_len_ptr =3D ptr;
> +	ptr +=3D 2;
> +
> +	for (entry =3D l_queue_get_entries(extensions); entry;
> +			entry =3D entry->next) {
> +		uint16_t ext_id =3D L_PTR_TO_UINT(entry->data);
> +		const struct tls_hello_extension *extension =3D NULL;
> +		unsigned int i;
> +		ssize_t ext_len;
> +
> +		for (i =3D 0; tls_extensions[i].name; i++)
> +			if (tls_extensions[i].id =3D=3D ext_id) {
> +				extension =3D &tls_extensions[i];
> +				break;
> +			}
> +
> +		if (!extension || !extension->server_write)
> +			continue;
> +
> +		ext_len =3D extension->server_write(tls, ptr + 4,
> +						buf + sizeof(buf) - (ptr + 4));
> +		if (ext_len =3D=3D -ENOMSG)
> +			continue;
> +
> +		if (ext_len < 0) {
> +			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
> +					"%s extension's server_write: %s",
> +					extension->name, strerror(-ext_len));
> +			return false;
> +		}
> +
> +		l_put_be16(ext_id, ptr + 0);
> +		l_put_be16(ext_len, ptr + 2);
> +		ptr +=3D 4 + ext_len;
> +	}
> +
> +	if (ptr > extensions_len_ptr + 2)
> +		l_put_be16(ptr - (extensions_len_ptr + 2), extensions_len_ptr);
> +	else /* Skip the length if no extensions */
> +		ptr =3D extensions_len_ptr;
> +
>   	tls_tx_handshake(tls, TLS_SERVER_HELLO, buf, ptr - buf);
> +	return true;
>   }
>   =


So both the server and the client versions are almost the same code. =

Signatures of client_write and server_write are also identical.  Can =

these two functions be combined?

Also, don't you want the supported client extensions to also be =

dynamically configurable per tls object?

Regards,
-Denis

--===============1013526741222368460==--

