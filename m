Content-Type: multipart/mixed; boundary="===============0953227143243840971=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/5] dbus: Add and validate the UNIX_FDS msg header field
Date: Fri, 29 Apr 2016 18:17:37 -0500
Message-ID: <5723EB91.7050600@gmail.com>
In-Reply-To: <1461969842-11704-3-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0953227143243840971==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/29/2016 05:44 PM, Andrew Zaborowski wrote:
> ---
>   ell/dbus-message.c | 50 +++++++++++++++++++++++++++++++++++++++--------=
---
>   1 file changed, 39 insertions(+), 11 deletions(-)
>
> diff --git a/ell/dbus-message.c b/ell/dbus-message.c
> index 038d44d..0fe76de 100644
> --- a/ell/dbus-message.c
> +++ b/ell/dbus-message.c
> @@ -764,11 +764,22 @@ struct l_dbus_message *dbus_message_from_blob(const=
 void *data, size_t size,
>   		get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE,
>   					'g', &message->signature);
>
> -	if (num_fds > L_ARRAY_SIZE(message->fds)) {
> -		for (i =3D L_ARRAY_SIZE(message->fds); i < num_fds; i++)
> -			close(fds[i]);
> +	if (num_fds) {
> +		uint32_t unix_fds;
>
> -		num_fds =3D L_ARRAY_SIZE(message->fds);
> +		if (!get_header_field(message, DBUS_MESSAGE_FIELD_UNIX_FDS,
> +					'u', &unix_fds))
> +			goto free;
> +
> +		if (num_fds > unix_fds)
> +			num_fds =3D unix_fds;

If num_fds > unix_fds, should all unused fds (e.g. fds[unix_fds .. =

num_fds-1] be closed just in case as well?

Also, what if unix_fds > num_fds?

> +
> +		if (num_fds > L_ARRAY_SIZE(message->fds)) {
> +			for (i =3D L_ARRAY_SIZE(message->fds); i < num_fds; i++)
> +				close(fds[i]);
> +
> +			num_fds =3D L_ARRAY_SIZE(message->fds);
> +		}
>   	}
>
>   	message->num_fds =3D num_fds;
> @@ -777,7 +788,8 @@ struct l_dbus_message *dbus_message_from_blob(const v=
oid *data, size_t size,
>   	return message;
>
>   free:
> -	l_free(message);
> +	l_dbus_message_unref(message);
> +
>   	return NULL;
>   }
>
> @@ -809,19 +821,31 @@ struct l_dbus_message *dbus_message_build(void *hea=
der, size_t header_size,
>   	message->header =3D header;
>   	message->body_size =3D body_size;
>   	message->body =3D body;
> +	message->sealed =3D true;
>
> -	if (num_fds > L_ARRAY_SIZE(message->fds)) {
> -		for (i =3D L_ARRAY_SIZE(message->fds); i < num_fds; i++)
> -			close(fds[i]);
> +	if (num_fds) {
> +		uint32_t unix_fds;
>
> -		num_fds =3D L_ARRAY_SIZE(message->fds);
> +		if (!get_header_field(message, DBUS_MESSAGE_FIELD_UNIX_FDS,
> +					'u', &unix_fds)) {
> +			l_free(message);
> +			return NULL;
> +		}
> +
> +		if (num_fds > unix_fds)
> +			num_fds =3D unix_fds;
> +
> +		if (num_fds > L_ARRAY_SIZE(message->fds)) {
> +			for (i =3D L_ARRAY_SIZE(message->fds); i < num_fds; i++)
> +				close(fds[i]);
> +
> +			num_fds =3D L_ARRAY_SIZE(message->fds);
> +		}
>   	}
>
>   	message->num_fds =3D num_fds;
>   	memcpy(message->fds, fds, num_fds * sizeof(int));
>
> -	message->sealed =3D true;
> -
>   	/* If the field is absent message->signature will remain NULL */
>   	get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE, 'g',
>   						&message->signature);
> @@ -1013,6 +1037,10 @@ static void build_header(struct l_dbus_message *me=
ssage, const char *signature)
>   		add_field(builder, driver, DBUS_MESSAGE_FIELD_SIGNATURE,
>   				"g", signature);
>
> +	if (message->num_fds)
> +		add_field(builder, driver, DBUS_MESSAGE_FIELD_UNIX_FDS,
> +					"u", &message->num_fds);
> +
>   	driver->leave_array(builder);
>
>   	generated_signature =3D driver->finish(builder, &message->header,
>

Regards,
-Denis

--===============0953227143243840971==--

