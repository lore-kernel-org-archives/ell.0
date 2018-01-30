Content-Type: multipart/mixed; boundary="===============2339344694845550715=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: added l_dbus_message_iter_get_fixed_array
Date: Tue, 30 Jan 2018 11:22:51 -0600
Message-ID: <6b73051a-dab4-b681-32a8-b6621e8498ac@gmail.com>
In-Reply-To: <1517269726-12151-1-git-send-email-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2339344694845550715==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 01/29/2018 05:48 PM, James Prestwood wrote:
> Returns pointer and length of dbus array in place so no copying
> is needed.
> ---
>   ell/dbus-message.c | 14 ++++++++++++++
>   ell/dbus.h         |  3 ++-
>   2 files changed, 16 insertions(+), 1 deletion(-)
> =

> diff --git a/ell/dbus-message.c b/ell/dbus-message.c
> index f4f6b42..7a24f5b 100644
> --- a/ell/dbus-message.c
> +++ b/ell/dbus-message.c
> @@ -1414,6 +1414,20 @@ LIB_EXPORT bool l_dbus_message_iter_get_variant(
>   	return result;
>   }
>   =

> +LIB_EXPORT bool l_dbus_message_iter_get_fixed_array(
> +					struct l_dbus_message_iter *iter,
> +					const void **a, uint32_t *len)
> +{
> +	if (iter->container_type !=3D 'a')
> +		return false;
> +

Also, we need to be a bit stricter here and check that the type is =

indeed a fixed type.

> +	*a =3D iter->data + iter->pos;
> +	*len =3D iter->len - 4;

Why len - 4?  That can't be right

> +
> +	return true;
> +}
> +
> +
>   void _dbus_message_set_sender(struct l_dbus_message *message,
>   					const char *sender)
>   {

The DBus stuff is a bit complex, so I just went ahead and implemented =

the needed logic in commits:
a9ea8d44618e9216fde6e550f2cae61f248b1218
886aeec677d1c5c7d5c83b59a857727507510050

Regards,
-Denis

--===============2339344694845550715==--

