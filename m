Content-Type: multipart/mixed; boundary="===============5360709637705554533=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 04/20] dbus: Fix _dbus_kernel_calculate_bloom for multiple
 arguments.
Date: Mon, 14 Mar 2016 11:49:22 -0500
Message-ID: <56E6EB92.9020305@gmail.com>
In-Reply-To: <1457926896-9843-4-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5360709637705554533==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/13/2016 10:41 PM, Andrew Zaborowski wrote:
> It seems that l_dbus_message_iter_get_type can't be used to get the
> value of a single argument and be called repeatedly, it might crash if

Looking at l_dbus_message_iter_get_type, it just returns =

iter->sig_start[iter->sig_pos].  Is there something deeper going on here =

that is not readily apparent?

> the number and types of call arguments don't match the message arguments.
> Also try to support the string arguments that come after non-string
> arguments in the bloom filter.

 From my reading of systemd code, I didn't think this was possible.  But =

I could be wrong...

> ---
>   ell/dbus-message.c | 38 ++++++++++++++++++++++++++++----------
>   1 file changed, 28 insertions(+), 10 deletions(-)
>
> diff --git a/ell/dbus-message.c b/ell/dbus-message.c
> index f223c70..a123a8a 100644
> --- a/ell/dbus-message.c
> +++ b/ell/dbus-message.c
> @@ -1412,9 +1412,12 @@ bool _dbus_kernel_calculate_bloom(struct l_dbus_me=
ssage *message,
>   	const char *signature;
>   	void *body;
>   	size_t body_size;
> -	struct l_dbus_message_iter iter;
> +	struct l_dbus_message_iter iter, tmp;
>   	uint8_t argn;
>   	char buf[256];
> +	bool (*skip_entry)(struct l_dbus_message_iter *);
> +	bool (*get_basic)(struct l_dbus_message_iter *, char, void *);
> +	char type;
>
>   	/* The string "interface:" suffixed by the interface name */
>   	attr =3D l_dbus_message_get_interface(message);
> @@ -1458,17 +1461,32 @@ bool _dbus_kernel_calculate_bloom(struct l_dbus_m=
essage *message,
>
>   	body =3D _dbus_message_get_body(message, &body_size);
>
> -	if (_dbus_message_is_gvariant(message))
> -		_gvariant_iter_init(&iter, message, signature, NULL,
> -					body, body_size);
> -	else
> +	if (_dbus_message_is_gvariant(message)) {
> +		if (!_gvariant_iter_init(&iter, message, signature, NULL,
> +						body, body_size))
> +			return false;
> +
> +		skip_entry =3D _gvariant_iter_skip_entry;
> +		get_basic =3D _gvariant_iter_next_entry_basic;
> +	} else {
>   		_dbus1_iter_init(&iter, message, signature, NULL,
> -				body, body_size);
> +					body, body_size);
> +
> +		skip_entry =3D _dbus1_iter_skip_entry;
> +		get_basic =3D _dbus1_iter_next_entry_basic;
> +	}
>
>   	argn =3D 0;
>
> -	while (*signature =3D=3D 's' || *signature =3D=3D 'o' || *signature =3D=
=3D 'g') {
> -		if (!message_iter_next_entry(&iter, &attr))
> +	do {
> +		type =3D l_dbus_message_iter_get_type(&iter);
> +		if (!strchr("sog", type))
> +			goto next;
> +
> +		/* Don't let get_basic move iter->pos without moving sig_pos */
> +		memcpy(&tmp, &iter, sizeof(tmp));
> +
> +		if (!get_basic(&tmp, type, &attr))
>   			return false;

Is this to avoid double skipping this entry?  Can we find a less hacky =

way to do this?  Perhaps peek_basic, or restructure the loop in some way?

>
>   		sprintf(buf, "arg%hhu", argn);
> @@ -1482,9 +1500,9 @@ bool _dbus_kernel_calculate_bloom(struct l_dbus_mes=
sage *message,
>   		_dbus_kernel_bloom_add_parents(filter, f_size, num_hash, buf,
>   						attr, '.');
>
> +next:
>   		argn +=3D 1;
> -		signature +=3D 1;
> -	}
> +	} while (skip_entry(&iter));
>
>   	return true;
>   }
>

Regards,
-Denis

--===============5360709637705554533==--

