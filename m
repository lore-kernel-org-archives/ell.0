Content-Type: multipart/mixed; boundary="===============6792201435754045678=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [RFC PATCH 6/8] dbus: Handle legacy GetProperties and SetProperty
 automatically.
Date: Thu, 28 Jan 2016 18:16:07 -0600
Message-ID: <56AAAF47.6040405@gmail.com>
In-Reply-To: <1453517972-22833-6-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6792201435754045678==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/22/2016 08:59 PM, Andrew Zaborowski wrote:
> ---
>   ell/dbus-service.c      | 216 +++++++++++++++++++++++++++++++++++++++++=
+++++--
>   examples/dbus-service.c |  86 +------------------
>   2 files changed, 212 insertions(+), 90 deletions(-)
>

<snip>

> +static struct l_dbus_message *old_set_property(struct l_dbus *dbus,
> +						struct l_dbus_message *message,
> +						void *user_data)
> +{

<snip>

> +
> +	signature =3D property->metainfo + strlen(property->metainfo) + 1;
> +
> +	if (l_dbus_message_iter_get_type(&variant) !=3D signature[0])
> +		return l_dbus_message_new_error(message,
> +						"org.freedesktop.DBus.Error."
> +						"InvalidArgs",
> +						"Expected type '%s'",
> +						signature);
> +

Is this check strictly needed?  The setter would be running a =

l_dbus_message_iter_get_variant call anyway which does a more thorough =

signature check.

Rest looks fine.

Regards,
-Denis

--===============6792201435754045678==--

