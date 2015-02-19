Content-Type: multipart/mixed; boundary="===============2736185840242755066=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 1/4] dbus: Add AddMatch and RemoveMatch support
Date: Thu, 19 Feb 2015 09:21:28 -0600
Message-ID: <54E5FF78.5070109@gmail.com>
In-Reply-To: <1424275716-7198-2-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2736185840242755066==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/18/2015 10:08 AM, Jukka Rissanen wrote:
> We do not check for errors as they are typically unrecoverable
> in this case and in most cases ignored anyway.
>
> This is the comment from libdbus API documentation for
> dbus_bus_add_match() about error checking:
>
> "If you pass NULL for the error, this function will not block;
> the match thus won't be added until you flush the connection,
> and if there's an error adding the match you won't find out
> about it. This is generally acceptable, since the possible
> errors (including a lack of resources in the bus, the connection
> having exceeded its quota of active match rules, or the match
> rule being unparseable) are generally unrecoverable."
> ---
>   ell/dbus.c | 26 ++++++++++++++++++++++++++
>   1 file changed, 26 insertions(+)
>

Mostly fine with this one, but please tweak the naming to be consistent =

with what we already have.

> diff --git a/ell/dbus.c b/ell/dbus.c
> index 4c4ba2d..c10e0ed 100644
> --- a/ell/dbus.c
> +++ b/ell/dbus.c
> @@ -1227,3 +1227,29 @@ LIB_EXPORT bool l_dbus_unregister_interface(struct=
 l_dbus *dbus,
>
>   	return _dbus_object_tree_unregister(dbus->tree, path, interface);
>   }
> +
> +static void send_match(struct l_dbus *dbus, const char *rule,
> +						const char *method)

So dbus1_send_match

> +{
> +	struct l_dbus_message *message;
> +
> +	message =3D l_dbus_message_new_method_call(dbus,
> +						DBUS_SERVICE_DBUS,
> +						DBUS_PATH_DBUS,
> +						DBUS_INTERFACE_DBUS,
> +						method);
> +
> +	l_dbus_message_set_arguments(message, "s", rule);
> +
> +	send_message(dbus, false, message, NULL, NULL, NULL);
> +}
> +
> +static void _dbus_bus_add_match(struct l_dbus *dbus, const char *rule)

The '_' prefix is reserved to exported functions that are private. =

Since this function is static, do not use the '_' prefix.

dbus1_bus_add_match

> +{
> +	send_match(dbus, rule, "AddMatch");
> +}
> +
> +static void _dbus_bus_remove_match(struct l_dbus *dbus, const char *rule)
> +{

dbus1_remove_match

> +	send_match(dbus, rule, "RemoveMatch");
> +}
>

Regards,
-Denis

--===============2736185840242755066==--

