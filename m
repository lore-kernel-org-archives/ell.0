Content-Type: multipart/mixed; boundary="===============4020047275306838423=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 08/11] dbus: Fix the kdbus message encoding
Date: Tue, 12 Apr 2016 16:46:52 -0500
Message-ID: <570D6CCC.4050903@gmail.com>
In-Reply-To: <1460426175-25501-8-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4020047275306838423==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/11/2016 08:56 PM, Andrew Zaborowski wrote:
> Keep sending the message header+padding as a separate
> KDBUS_ITEM_PAYLOAD_OFF buffer like in DBus-1, the systemd busctl utility
> also seems to do that.  But fix what we send after the header.
> ---
>   ell/dbus-kernel.c  | 17 +++++++++--------
>   ell/dbus-message.c | 19 +++++++++++++++++++
>   ell/dbus-private.h |  3 +++
>   3 files changed, 31 insertions(+), 8 deletions(-)
>
> diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
> index 7797153..da5920f 100644
> --- a/ell/dbus-kernel.c
> +++ b/ell/dbus-kernel.c
> @@ -427,14 +427,15 @@ int _dbus_kernel_send(int fd, size_t bloom_size, ui=
nt8_t bloom_n_hash,
>   	item->vec.size =3D header_size;
>   	item =3D KDBUS_ITEM_NEXT(item);
>
> -	body =3D _dbus_message_get_body(message, &body_size);
> -	if (body_size > 0) {
> -		item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(struct kdbus_vec);
> -		item->type =3D KDBUS_ITEM_PAYLOAD_VEC;
> -		item->vec.address =3D (uintptr_t) body;
> -		item->vec.size =3D body_size;
> -		item =3D KDBUS_ITEM_NEXT(item);
> -	}
> +	_dbus_message_build_contents(message, NULL, &body_size);
> +	body =3D alloca(body_size);

This will fail badly somewhere around body_size >=3D 64k, depending on the =

platform.  Why can't we write the contents directly like we used to?

> +	_dbus_message_build_contents(message, body, NULL);
> +
> +	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(struct kdbus_vec);
> +	item->type =3D KDBUS_ITEM_PAYLOAD_VEC;
> +	item->vec.address =3D (uintptr_t) body;
> +	item->vec.size =3D body_size;
> +	item =3D KDBUS_ITEM_NEXT(item);
>
>   	kmsg->size =3D (void *)item - (void *)kmsg;
>

Regards,
-Denis

--===============4020047275306838423==--

