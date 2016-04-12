Content-Type: multipart/mixed; boundary="===============4001291281565344046=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 04/11] dbus: Fix parsing GVariant header/body
 information
Date: Tue, 12 Apr 2016 16:15:39 -0500
Message-ID: <570D657B.8010804@gmail.com>
In-Reply-To: <1460426175-25501-4-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4001291281565344046==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/11/2016 08:56 PM, Andrew Zaborowski wrote:
> In GVariant messages there's no body size field (it is reserved and must
> be sent as 0) or header size information or signature.  We do still add
> the signature as a field same as in Dbus-1 because it's not prohibited
> but we can't rely on it being there.  The message needs to be parsed as
> a single GVariant blob if we want to split it into a header and a body.
> ---
>   ell/dbus-kernel.c  |   3 --
>   ell/dbus-message.c | 108 ++++++++++++++++++++++++++++++++++++----------=
-------
>   2 files changed, 73 insertions(+), 38 deletions(-)
>

<snip>

> @@ -653,6 +651,7 @@ struct l_dbus_message *dbus_message_from_blob(const v=
oid *data, size_t size)
>   {
>   	const struct dbus_header *hdr =3D data;
>   	struct l_dbus_message *message;
> +	size_t body_pos;
>
>   	if (unlikely(size < DBUS_HEADER_SIZE))
>   		return NULL;
> @@ -661,28 +660,62 @@ struct l_dbus_message *dbus_message_from_blob(const=
 void *data, size_t size)
>
>   	message->refcount =3D 1;
>
> -	message->header_size =3D align_len(DBUS_HEADER_SIZE +
> -						hdr->field_length, 8);
> -	message->body_size =3D hdr->body_length;
> +	if (hdr->version =3D=3D 1) {
> +		message->header_size =3D align_len(DBUS_HEADER_SIZE +
> +							hdr->field_length, 8);
> +		message->body_size =3D hdr->body_length;
>
> -	if (message->header_size + message->body_size < size) {
> -		l_free(message);
> -		return NULL;
> +		if (message->header_size + message->body_size < size)
> +			goto free;
> +
> +		body_pos =3D message->header_size;
> +	} else {
> +		struct l_dbus_message_iter iter, header,
> +			variant, structure, body;

Please break this up into multiple struct declarations.

e.g.

struct l_dbus_message_iter iter;
struct l_dbus_message_iter header, variant, body;

Just to group them better and make this more readable.

> +
> +		if (!_gvariant_iter_init(&iter, message, "((yyyyuta{tv})v)",
> +						NULL, data, size))

So quoting or pointing to:
https://wiki.gnome.org/Projects/GLib/GDBus/Version2
might be in order here.

It says: "The canonical type of a D-Bus version two message is =

(yyyyuta{tv}v)."

Also, you might want to put in a quick blurb why we're not using the =

canonical structure.

> +			goto free;
> +
> +		if (!_gvariant_iter_enter_struct(&iter, &structure))
> +			goto free;

Since the outer structure is implicit, do we really need this part? =

Can't we simply omit the outer '()'s? If so, the code can be simplified.

> +
> +		if (!_gvariant_iter_enter_struct(&structure, &header))
> +			goto free;
> +
> +		if (!_gvariant_iter_enter_variant(&structure, &variant))
> +			goto free;
> +
> +		if (!_gvariant_iter_enter_struct(&variant, &body))
> +			goto free;
> +
> +		message->header_size =3D align_len(header.len - header.pos, 8);

why do we need an align_len here?  This was probably specific to the =

classic and old kdbus formats.

> +		message->body_size =3D body.len - body.pos;
> +		message->signature =3D l_strndup(body.sig_start + body.sig_pos,
> +						body.sig_len - body.sig_pos);
> +		message->signature_free =3D true;
> +		message->header_end =3D header.len;
> +		body_pos =3D body.data + body.pos - data;
>   	}
>
>   	message->header =3D l_malloc(message->header_size);
>   	message->body =3D l_malloc(message->body_size);
>
>   	memcpy(message->header, data, message->header_size);
> -	memcpy(message->body, data + message->header_size, message->body_size);
> +	memcpy(message->body, data + body_pos, message->body_size);
>
>   	message->sealed =3D true;
>
>   	/* If the field is absent message->signature will remain NULL */
> -	get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE, 'g',
> -						&message->signature);
> +	if (hdr->version =3D=3D 1)
> +		get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE,
> +					'g', &message->signature);
>
>   	return message;
> +
> +free:
> +	l_free(message);
> +	return NULL;
>   }
>
>   struct l_dbus_message *dbus_message_build(void *header, size_t header_s=
ize,
> @@ -698,6 +731,13 @@ struct l_dbus_message *dbus_message_build(void *head=
er, size_t header_size,
>   	if (unlikely(!valid_header(hdr)))
>   		return NULL;
>
> +	/*
> +	 * With GVariant we need to know the signature, use
> +	 * dbus_message_from_blob instead.
> +	 */
> +	if (unlikely(hdr->version !=3D 1))
> +		return NULL;
> +
>   	message =3D l_new(struct l_dbus_message, 1);
>
>   	message->refcount =3D 1;
> @@ -827,21 +867,18 @@ static void build_header(struct l_dbus_message *mes=
sage, const char *signature)
>   	char *generated_signature;
>   	struct dbus_header *hdr;
>   	size_t header_size;
> +	bool gvariant;
>
> -	if (_dbus_message_is_gvariant(message))
> +	gvariant =3D _dbus_message_is_gvariant(message);
> +
> +	if (gvariant)
>   		driver =3D &gvariant_driver;
>   	else
>   		driver =3D &dbus1_driver;
>
>   	builder =3D driver->new(message->header, message->header_size);
>
> -	if (_dbus_message_is_gvariant(message)) {
> -		uint32_t field_length =3D 0;
> -		driver->append_basic(builder, 'u', &field_length);
> -	}
> -
> -	driver->enter_array(builder, _dbus_message_is_gvariant(message) ?
> -				"(tv)" : "(yv)");
> +	driver->enter_array(builder, gvariant ? "(tv)" : "(yv)");
>
>   	if (message->path) {
>   		add_field(builder, driver, DBUS_MESSAGE_FIELD_PATH,
> @@ -906,15 +943,16 @@ static void build_header(struct l_dbus_message *mes=
sage, const char *signature)
>   	hdr =3D message->header;
>
>   	if (_dbus_message_is_gvariant(message))
> -		hdr->field_length =3D header_size - 16;
> -
> -	hdr->body_length =3D message->body_size;
> +		hdr->body_length =3D 0;
> +	else
> +		hdr->body_length =3D message->body_size;
>
>   	/* We must align the end of the header to an 8-byte boundary */
>   	message->header_size =3D align_len(header_size, 8);
>   	message->header =3D l_realloc(message->header, message->header_size);
>   	memset(message->header + header_size, 0,
>   			message->header_size - header_size);
> +	message->header_end =3D header_size;
>   }
>
>   struct container {
>

Regards,
-Denis

--===============4001291281565344046==--

