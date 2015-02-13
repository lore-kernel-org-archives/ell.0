Content-Type: multipart/mixed; boundary="===============4606095226299711291=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 1/3] dbus: Add AddMatch and RemoveMatch support
Date: Thu, 12 Feb 2015 21:00:30 -0600
Message-ID: <54DD68CE.7060101@gmail.com>
In-Reply-To: <1423741733-26743-2-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4606095226299711291==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/12/2015 05:48 AM, Jukka Rissanen wrote:
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
>   ell/dbus.h |  4 ++++
>   2 files changed, 30 insertions(+)
>
> diff --git a/ell/dbus.c b/ell/dbus.c
> index 4c4ba2d..96a1230 100644
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
> +LIB_EXPORT void l_dbus_bus_add_match(struct l_dbus *dbus, const char *ru=
le)

These functions should not be exported / become private.

> +{
> +	send_match(dbus, rule, "AddMatch");
> +}
> +
> +LIB_EXPORT void l_dbus_bus_remove_match(struct l_dbus *dbus, const char =
*rule)
> +{

As above

> +	send_match(dbus, rule, "RemoveMatch");
> +}
> diff --git a/ell/dbus.h b/ell/dbus.h
> index a6ad109..d5890a5 100644
> --- a/ell/dbus.h
> +++ b/ell/dbus.h
> @@ -196,6 +196,10 @@ bool l_dbus_register_interface(struct l_dbus *dbus,
>   				l_dbus_destroy_func_t destroy);
>   bool l_dbus_unregister_interface(struct l_dbus *dbus, const char *path,
>   					const char *interface);
> +
> +void l_dbus_bus_add_match(struct l_dbus *dbus, const char *rule);
> +void l_dbus_bus_remove_match(struct l_dbus *dbus, const char *rule);
> +
>   #ifdef __cplusplus
>   }
>   #endif
>

Regards,
-Denis

--===============4606095226299711291==--

