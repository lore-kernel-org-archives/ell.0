Content-Type: multipart/mixed; boundary="===============3007361290416614734=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 3/4] dbus: Add disconnect watch support
Date: Thu, 19 Feb 2015 09:57:14 -0600
Message-ID: <54E607DA.8090302@gmail.com>
In-Reply-To: <1424275716-7198-4-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3007361290416614734==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/18/2015 10:08 AM, Jukka Rissanen wrote:
> Allow caller to monitor the disconnect status of a service.
> ---
>   ell/dbus-private.h |  35 ++++++++++
>   ell/dbus.c         | 195 ++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   ell/dbus.h         |   9 +++
>   3 files changed, 239 insertions(+)
>
> diff --git a/ell/dbus-private.h b/ell/dbus-private.h
> index 9987294..cbde2fd 100644
> --- a/ell/dbus-private.h
> +++ b/ell/dbus-private.h
> @@ -212,3 +212,38 @@ int _dbus_kernel_remove_match(int fd, uint64_t cooki=
e);
>
>   uint8_t _dbus_get_version(struct l_dbus *dbus);
>   int _dbus_get_fd(struct l_dbus *dbus);
> +
> +struct _dbus_filter_data {
> +	struct l_dbus *dbus;
> +	l_dbus_message_func_t handle_func;
> +	l_dbus_watch_func_t connect_func;

This member isn't used

> +	l_dbus_watch_func_t disconnect_func;
> +	char *sender;
> +	char *path;
> +	char *interface;
> +	char *member;
> +	char *argument;
> +	void *user_data;
> +	l_dbus_destroy_func_t destroy_func;
> +};

Please encapsulate this into the source file.

> +
> +typedef void (*l_dbus_match_func_t) (struct _dbus_filter_data *data,
> +					l_dbus_message_func_t filter);
> +
> +void _dbus_message_filter_dispatcher(struct l_dbus_message *message,
> +				     void *user_data);

Whitespace violation on the line above.

> +void _dbus1_format_rule(struct _dbus_filter_data *data, char *rule,
> +			size_t size);

Break this function into a separate patch, then submit a unit test for =

this in a separate patch. Both can be part of the v4 series.

> +struct _dbus_filter_data *_dbus1_filter_data_get(struct l_dbus *dbus,
> +					l_dbus_message_func_t filter,
> +					const char *sender,
> +					const char *path,
> +					const char *interface,
> +					const char *member,
> +					const char *argument,
> +					l_dbus_watch_func_t disconnect_func,
> +					void *user_data,
> +					l_dbus_destroy_func_t destroy,
> +					l_dbus_match_func_t match);
> +void _dbus1_filter_data_destroy(void *user_data, l_dbus_match_func_t mat=
ch);
> +void _dbus1_service_filter(struct l_dbus_message *message, void *user_da=
ta);
> diff --git a/ell/dbus.c b/ell/dbus.c
> index c10e0ed..8596449 100644
> --- a/ell/dbus.c
> +++ b/ell/dbus.c
> @@ -53,6 +53,8 @@
>   #define DBUS_INTERFACE_INTROSPECTABLE	"org.freedesktop.DBus.Introspecta=
ble"
>   #define DBUS_INTERFACE_PROPERTIES	"org.freedesktop.DBus.Properties"
>
> +#define DBUS_MAXIMUM_MATCH_RULE_LENGTH	1024
> +
>   enum auth_state {
>   	WAITING_FOR_OK,
>   	WAITING_FOR_AGREE_UNIX_FD,
> @@ -1253,3 +1255,196 @@ static void _dbus_bus_remove_match(struct l_dbus =
*dbus, const char *rule)
>   {
>   	send_match(dbus, rule, "RemoveMatch");
>   }
> +
> +void _dbus1_format_rule(struct _dbus_filter_data *data, char *rule,
> +			size_t size)
> +{
> +	int offset;
> +
> +	offset =3D snprintf(rule, size, "type=3D'signal'");
> +
> +	if (data->sender)
> +		offset +=3D snprintf(rule + offset, size - offset,
> +				",sender=3D'%s'", data->sender);
> +	if (data->path)
> +		offset +=3D snprintf(rule + offset, size - offset,
> +				",path=3D'%s'", data->path);
> +	if (data->interface)
> +		offset +=3D snprintf(rule + offset, size - offset,
> +				",interface=3D'%s'", data->interface);
> +	if (data->member)
> +		offset +=3D snprintf(rule + offset, size - offset,
> +				",member=3D'%s'", data->member);
> +	if (data->argument)
> +		snprintf(rule + offset, size - offset,
> +				",arg0=3D'%s'", data->argument);
> +}
> +
> +static void add_match(struct _dbus_filter_data *data,
> +						l_dbus_message_func_t filter)
> +{
> +	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
> +
> +	_dbus1_format_rule(data, rule, sizeof(rule));
> +
> +	_dbus_bus_add_match(data->dbus, rule);
> +
> +	data->handle_func =3D filter;

Why is this being set here, it is also being set in =

_dbus1_filter_data_get.  So you end up setting it twice.

> +}
> +
> +static void remove_match(struct _dbus_filter_data *data,
> +						l_dbus_message_func_t filter)

What's the reason for the filter argument?  It isn't used as far as I =

can tell.

> +{
> +	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
> +
> +	_dbus1_format_rule(data, rule, sizeof(rule));
> +
> +	_dbus_bus_remove_match(data->dbus, rule);
> +}
> +
> +struct _dbus_filter_data *_dbus1_filter_data_get(struct l_dbus *dbus,
> +					l_dbus_message_func_t filter,
> +					const char *sender,
> +					const char *path,
> +					const char *interface,
> +					const char *member,
> +					const char *argument,
> +					l_dbus_watch_func_t disconnect_func,
> +					void *user_data,
> +					l_dbus_destroy_func_t destroy,
> +					l_dbus_match_func_t add_match)

Why pass add_match in as the argument?  It also matches the a function =

name just above.  That is a good way to get people confused.  If you =

need to avoid calling add_match for unit test purposes, just make the =

caller of this function call add_match.

> +{
> +	struct _dbus_filter_data *data;
> +
> +	data =3D l_new(struct _dbus_filter_data, 1);
> +
> +	data->dbus =3D dbus;
> +	data->handle_func =3D filter;
> +	data->disconnect_func =3D disconnect_func;
> +	data->sender =3D l_strdup(sender);
> +	data->path =3D l_strdup(path);
> +	data->interface =3D l_strdup(interface);
> +	data->member =3D l_strdup(member);
> +	data->argument =3D l_strdup(argument);
> +	data->user_data =3D user_data;
> +	data->destroy_func =3D destroy;
> +
> +	add_match(data, filter);
> +
> +	return data;
> +}
> +
> +void _dbus1_filter_data_destroy(void *user_data,
> +				l_dbus_match_func_t remove_match)

Same question as above?

> +{
> +	struct _dbus_filter_data *data =3D user_data;
> +
> +	remove_match(data, NULL);
> +
> +	l_free(data->sender);
> +	l_free(data->path);
> +	l_free(data->interface);
> +	l_free(data->member);
> +	l_free(data->argument);
> +
> +	if (data->destroy_func)
> +		data->destroy_func(data->user_data);
> +
> +	l_free(data);
> +}
> +
> +static void filter_data_destroy(void *user_data)
> +{
> +	_dbus1_filter_data_destroy(user_data, remove_match);
> +}
> +
> +void _dbus_message_filter_dispatcher(struct l_dbus_message *message,
> +				     void *user_data)

Since everything used by this is _dbus1_*, use _dbus1_signal_dispatcher

> +{
> +	struct _dbus_filter_data *data =3D user_data;
> +	const char *sender, *path, *iface, *member;
> +
> +	if (_dbus_message_get_type(message) !=3D DBUS_MESSAGE_TYPE_SIGNAL)
> +		return;
> +
> +	sender =3D l_dbus_message_get_sender(message);
> +	if (!sender)
> +		return;
> +
> +	if (data->sender && strcmp(sender, data->sender))
> +		return;
> +
> +	path =3D l_dbus_message_get_path(message);
> +	if (data->path && strcmp(path, data->path))
> +		return;
> +
> +	iface =3D l_dbus_message_get_interface(message);
> +	if (data->interface && strcmp(iface, data->interface))
> +		return;
> +
> +	member =3D l_dbus_message_get_member(message);
> +	if (data->member && strcmp(member, data->member))
> +		return;
> +
> +	if (data->handle_func)
> +		data->handle_func(message, data);
> +}
> +
> +void _dbus1_service_filter(struct l_dbus_message *message, void *user_da=
ta)

void _dbus1_name_owner_changed_filter()

> +{
> +	struct _dbus_filter_data *data =3D user_data;
> +	char *name, *old, *new;
> +
> +	if (!l_dbus_message_get_arguments(message, "sss",
> +						&name, &old, &new))
> +		return;
> +
> +	if (strcmp(name, data->argument))
> +		return;
> +
> +	if (*new =3D=3D '\0') {
> +		if (data->disconnect_func)
> +			data->disconnect_func(data->dbus, data->user_data);
> +	}
> +}
> +
> +static unsigned int l_dbus_add_service_watch(struct l_dbus *dbus,
> +					const char *name,
> +					l_dbus_watch_func_t disconnect_func,
> +					void *user_data,
> +					l_dbus_destroy_func_t destroy)

Don't bother adding this function as static.  That is just confusing. =

If you don't support service watches, just move this functionality into =

add_disconnect_watch below and get rid of this function completely.

> +{
> +	struct _dbus_filter_data *data;
> +
> +	if (!name)
> +		return 0;
> +
> +	data =3D _dbus1_filter_data_get(dbus, _dbus1_service_filter,
> +				DBUS_SERVICE_DBUS, DBUS_PATH_DBUS,
> +				DBUS_INTERFACE_DBUS, "NameOwnerChanged",
> +				name,
> +				disconnect_func,
> +				user_data,
> +				destroy,
> +				add_match);
> +	if (!data)
> +		return 0;
> +
> +	return l_dbus_register(dbus, _dbus_message_filter_dispatcher, data,
> +							filter_data_destroy);
> +}
> +
> +LIB_EXPORT unsigned int l_dbus_add_disconnect_watch(struct l_dbus *dbus,
> +					const char *name,
> +					l_dbus_watch_func_t disconnect_func,
> +					void *user_data,
> +					l_dbus_destroy_func_t destroy)
> +{
> +	return l_dbus_add_service_watch(dbus, name, disconnect_func,
> +							user_data, destroy);
> +}
> +
> +LIB_EXPORT bool l_dbus_remove_watch(struct l_dbus *dbus, unsigned int id)
> +{
> +	return l_dbus_unregister(dbus, id);
> +}
> diff --git a/ell/dbus.h b/ell/dbus.h
> index a6ad109..39f926b 100644
> --- a/ell/dbus.h
> +++ b/ell/dbus.h
> @@ -48,6 +48,8 @@ typedef void (*l_dbus_debug_func_t) (const char *str, v=
oid *user_data);
>   typedef void (*l_dbus_destroy_func_t) (void *user_data);
>   typedef void (*l_dbus_interface_setup_func_t) (struct l_dbus_interface =
*);
>
> +typedef void (*l_dbus_watch_func_t) (struct l_dbus *dbus, void *user_dat=
a);
> +
>   struct l_dbus *l_dbus_new(const char *address);
>   struct l_dbus *l_dbus_new_default(enum l_dbus_bus bus);
>   void l_dbus_destroy(struct l_dbus *dbus);
> @@ -196,6 +198,13 @@ bool l_dbus_register_interface(struct l_dbus *dbus,
>   				l_dbus_destroy_func_t destroy);
>   bool l_dbus_unregister_interface(struct l_dbus *dbus, const char *path,
>   					const char *interface);
> +unsigned int l_dbus_add_disconnect_watch(struct l_dbus *dbus,
> +					const char *name,
> +					l_dbus_watch_func_t disconnect_func,
> +					void *user_data,
> +					l_dbus_destroy_func_t destroy);
> +bool l_dbus_remove_watch(struct l_dbus *dbus, unsigned int id);
> +
>   #ifdef __cplusplus
>   }
>   #endif
>

Regards,
-Denis

--===============3007361290416614734==--

