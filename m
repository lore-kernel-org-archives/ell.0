Content-Type: multipart/mixed; boundary="===============2326627936992452132=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 2/3] dbus: Add disconnect watch support
Date: Thu, 12 Feb 2015 21:25:54 -0600
Message-ID: <54DD6EC2.4000008@gmail.com>
In-Reply-To: <1423741733-26743-3-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2326627936992452132==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/12/2015 05:48 AM, Jukka Rissanen wrote:
> Allow caller to monitor the disconnect status of a service.
> ---
>   ell/dbus.c | 227 ++++++++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   ell/dbus.h |  15 ++++
>   2 files changed, 242 insertions(+)
>
> diff --git a/ell/dbus.c b/ell/dbus.c
> index 96a1230..f98b042 100644
> --- a/ell/dbus.c
> +++ b/ell/dbus.c
> @@ -33,6 +33,7 @@
>   #include <string.h>
>   #include <sys/socket.h>
>   #include <sys/un.h>
> +#include <errno.h>
>
>   #include "util.h"
>   #include "io.h"
> @@ -53,6 +54,8 @@
>   #define DBUS_INTERFACE_INTROSPECTABLE	"org.freedesktop.DBus.Introspecta=
ble"
>   #define DBUS_INTERFACE_PROPERTIES	"org.freedesktop.DBus.Properties"
>
> +#define DBUS_MAXIMUM_MATCH_RULE_LENGTH	1024
> +
>   enum auth_state {
>   	WAITING_FOR_OK,
>   	WAITING_FOR_AGREE_UNIX_FD,
> @@ -122,6 +125,21 @@ struct signal_callback {
>   	void *user_data;
>   };
>
> +struct filter_data {
> +	struct l_dbus *dbus;
> +	l_dbus_message_func_t handle_func;
> +	l_dbus_watch_func_t connect_func;
> +	l_dbus_watch_func_t disconnect_func;
> +	char *name;
> +	char *owner;

What is the exact difference between name and owner?  I don't see a =

distinction...

> +	char *path;
> +	char *interface;
> +	char *member;
> +	char *argument;
> +	void *user_data;
> +	l_dbus_destroy_func_t destroy_func;
> +};
> +
>   static void message_queue_destroy(void *data)
>   {
>   	struct message_callback *callback =3D data;
> @@ -1253,3 +1271,212 @@ LIB_EXPORT void l_dbus_bus_remove_match(struct l_=
dbus *dbus, const char *rule)
>   {
>   	send_match(dbus, rule, "RemoveMatch");
>   }
> +
> +static void format_rule(struct filter_data *data, char *rule, size_t siz=
e)
> +{
> +	const char *sender;
> +	int offset;
> +
> +	offset =3D snprintf(rule, size, "type=3D'signal'");
> +	sender =3D data->name ? : data->owner;
> +
> +	if (sender)
> +		offset +=3D snprintf(rule + offset, size - offset,
> +				",sender=3D'%s'", sender);
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
> +static void add_match(struct filter_data *data, l_dbus_message_func_t fi=
lter)
> +{
> +	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
> +
> +	format_rule(data, rule, sizeof(rule));
> +
> +	l_dbus_bus_add_match(data->dbus, rule);
> +
> +	data->handle_func =3D filter;
> +}
> +
> +static void remove_match(struct filter_data *data)
> +{
> +	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
> +
> +	format_rule(data, rule, sizeof(rule));
> +
> +	l_dbus_bus_remove_match(data->dbus, rule);
> +}
> +
> +static struct filter_data *filter_data_get(struct l_dbus *dbus,
> +					l_dbus_message_func_t filter,
> +					const char *sender,
> +					const char *path,
> +					const char *interface,
> +					const char *member,
> +					const char *argument,
> +					l_dbus_watch_func_t connect_func,
> +					l_dbus_watch_func_t disconnect_func,
> +					void *user_data,
> +					l_dbus_destroy_func_t destroy)
> +{
> +	struct filter_data *data;
> +	const char *name =3D NULL, *owner =3D NULL;
> +
> +	if (sender) {
> +		if (sender[0] =3D=3D ':')
> +			owner =3D sender;
> +		else
> +			name =3D sender;
> +	}

Why is this needed?

> +
> +	data =3D l_new(struct filter_data, 1);
> +
> +	data->dbus =3D dbus;
> +	data->handle_func =3D filter;
> +	data->connect_func =3D connect_func;
> +	data->disconnect_func =3D disconnect_func;
> +	data->name =3D l_strdup(name);
> +	data->owner =3D l_strdup(owner);
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
> +static void filter_data_destroy(void *user_data)
> +{
> +	struct filter_data *data =3D user_data;
> +
> +	remove_match(data);
> +
> +	l_free(data->name);
> +	l_free(data->owner);
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
> +static void message_filter(struct l_dbus_message *message, void *user_da=
ta)
> +{
> +	struct filter_data *data =3D user_data;
> +	const char *sender, *path, *iface, *member, *arg =3D NULL;
> +
> +	if (_dbus_message_get_type(message) !=3D DBUS_MESSAGE_TYPE_SIGNAL)
> +		return;
> +
> +	sender =3D l_dbus_message_get_sender(message);
> +	if (!sender)
> +		return;
> +
> +	path =3D l_dbus_message_get_path(message);
> +	iface =3D l_dbus_message_get_interface(message);
> +	member =3D l_dbus_message_get_member(message);
> +
> +	l_dbus_message_get_arguments(message, "s", &arg);
> +
> +	if (data->owner && strcmp(sender, data->owner))
> +		goto out;
> +
> +	if (data->path && strcmp(path, data->path))
> +		goto out;
> +
> +	if (data->interface && strcmp(iface, data->interface))
> +		goto out;
> +
> +	if (data->member && strcmp(member, data->member))
> +		goto out;
> +
> +	if (arg && data->argument && strcmp(arg, data->argument))
> +		goto out;

This looks wrong

> +
> +	if (data->handle_func)
> +		data->handle_func(message, data);
> +
> +out:
> +	return;

Seriously?  Why bother?  Just return straight away.

> +}
> +
> +static void service_filter(struct l_dbus_message *message, void *user_da=
ta)
> +{
> +	struct filter_data *data =3D user_data;
> +	char *name, *old, *new;
> +
> +	if (!l_dbus_message_get_arguments(message, "sss",
> +						&name, &old, &new))
> +		return;
> +
> +	if (*new =3D=3D '\0') {
> +		if (data->disconnect_func)
> +			data->disconnect_func(data->dbus, data->user_data);
> +	} else {
> +		if (data->connect_func)
> +			data->connect_func(data->dbus, data->user_data);
> +	}
> +}
> +
> +LIB_EXPORT unsigned int l_dbus_add_service_watch(struct l_dbus *dbus,
> +					const char *name,
> +					l_dbus_watch_func_t connect_func,
> +					l_dbus_watch_func_t disconnect_func,
> +					void *user_data,
> +					l_dbus_destroy_func_t destroy)
> +{
> +	struct filter_data *data;
> +
> +	if (!name)
> +		return 0;
> +
> +	if (connect_func)
> +		return -EOPNOTSUPP;

Why? You seem to be handling that just fine?

> +
> +	data =3D filter_data_get(dbus, service_filter,
> +				DBUS_SERVICE_DBUS, DBUS_PATH_DBUS,
> +				DBUS_INTERFACE_DBUS, "NameOwnerChanged",
> +				name,
> +				connect_func,
> +				disconnect_func,
> +				user_data,
> +				destroy);
> +	if (!data)
> +		return 0;
> +
> +	return l_dbus_register(dbus, message_filter, data,
> +							filter_data_destroy);
> +}
> +
> +LIB_EXPORT unsigned int l_dbus_add_disconnect_watch(struct l_dbus *dbus,
> +					const char *name,
> +					l_dbus_watch_func_t disconnect_func,
> +					void *user_data,
> +					l_dbus_destroy_func_t destroy)
> +{
> +	return l_dbus_add_service_watch(dbus, name, NULL, disconnect_func,
> +							user_data, destroy);
> +}
> +
> +LIB_EXPORT bool l_dbus_remove_watch(struct l_dbus *dbus, unsigned int id)
> +{
> +	return l_dbus_unregister(dbus, id);
> +}
> diff --git a/ell/dbus.h b/ell/dbus.h
> index d5890a5..4a17de7 100644
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
> @@ -200,6 +202,19 @@ bool l_dbus_unregister_interface(struct l_dbus *dbus=
, const char *path,
>   void l_dbus_bus_add_match(struct l_dbus *dbus, const char *rule);
>   void l_dbus_bus_remove_match(struct l_dbus *dbus, const char *rule);
>
> +unsigned int l_dbus_add_service_watch(struct l_dbus *dbus,
> +					const char *name,
> +					l_dbus_watch_func_t connect_func,
> +					l_dbus_watch_func_t disconnect_func,
> +					void *user_data,
> +					l_dbus_destroy_func_t destroy);
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

--===============2326627936992452132==--

