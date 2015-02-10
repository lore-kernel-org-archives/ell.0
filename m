Content-Type: multipart/mixed; boundary="===============7226219656738943854=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/3] dbus: Add disconnect watch support
Date: Tue, 10 Feb 2015 16:02:34 -0600
Message-ID: <54DA7FFA.8050003@gmail.com>
In-Reply-To: <1423583207-22917-3-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7226219656738943854==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/10/2015 09:46 AM, Jukka Rissanen wrote:
> Allow caller to monitor the disconnect status of a service.
> ---
>   Makefile.am      |   1 +
>   ell/dbus-watch.c | 267 ++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   ell/dbus.h       |  17 ++++
>   3 files changed, 285 insertions(+)
>   create mode 100644 ell/dbus-watch.c
>
> diff --git a/Makefile.am b/Makefile.am
> index 50f81eb..3dcc7ee 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -63,6 +63,7 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
>   			ell/dbus-message.c \
>   			ell/dbus-util.c \
>   			ell/dbus-service.c \
> +			ell/dbus-watch.c \
>   			ell/gvariant-private.h \
>   			ell/gvariant-util.c \
>   			ell/siphash-private.h \
> diff --git a/ell/dbus-watch.c b/ell/dbus-watch.c
> new file mode 100644
> index 0000000..005bc83
> --- /dev/null
> +++ b/ell/dbus-watch.c
> @@ -0,0 +1,267 @@
> +/*
> + *
> + *  Embedded Linux library
> + *
> + *  Copyright (C) 2015  Intel Corporation. All rights reserved.
> + *
> + *  This library is free software; you can redistribute it and/or
> + *  modify it under the terms of the GNU Lesser General Public
> + *  License as published by the Free Software Foundation; either
> + *  version 2.1 of the License, or (at your option) any later version.
> + *
> + *  This library is distributed in the hope that it will be useful,
> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + *  Lesser General Public License for more details.
> + *
> + *  You should have received a copy of the GNU Lesser General Public
> + *  License along with this library; if not, write to the Free Software
> + *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-130=
1  USA
> + *
> + */
> +
> +#ifdef HAVE_CONFIG_H
> +#include <config.h>
> +#endif
> +
> +#define _GNU_SOURCE
> +#include <stdarg.h>
> +#include <string.h>
> +#include <stdio.h>
> +#include <errno.h>
> +
> +#include "log.h"
> +#include "util.h"
> +#include "queue.h"
> +#include "string.h"
> +#include "dbus.h"
> +#include "dbus-private.h"
> +#include "private.h"
> +
> +struct filter_data {
> +	struct l_dbus *dbus;
> +	l_dbus_message_func_t handle_func;
> +	l_dbus_watch_func_t connect_func;
> +	l_dbus_watch_func_t disconnect_func;
> +	char *name;
> +	char *owner;
> +	char *path;
> +	char *interface;
> +	char *member;
> +	char *argument;
> +	void *user_data;
> +	l_dbus_destroy_func_t destroy_func;
> +};
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
> +
> +	if (data->handle_func)
> +		data->handle_func(message, data);
> +
> +out:
> +	return;
> +}
> +
> +static void service_filter(struct l_dbus_message *message, void *user_da=
ta)
> +{
> +	struct filter_data *data =3D user_data;
> +	char *name, *old, *new;
> +
> +	if (!l_dbus_message_get_arguments(message, "sss",
> +						&name, &old, &new)) {
> +		l_error("Invalid arguments for NameOwnerChanged signal");
> +		return;
> +	}
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
> +	if (connect_func) {
> +		l_error("Connect watch not yet supported");
> +		return -EOPNOTSUPP;
> +	}
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

So this is the reason why you have re-entrancy problems.  You are trying =

to use l_dbus_register and l_dbus_unregister.  So when the signal_list =

hash is traversed, the agent tries to call l_dbus_unregister and things die.

I suggest that you rework this part to maintain its own data structure =

instead of using l_dbus_register, or make that part smarter.  You can =

handle re-entrancy like gdbus does now.  Since you already used most of =

the gdbus design, might as well take the rest of it (e.g. maintain a =

list of items to be removed and a re-entrancy guard).

Another idea might be to use the return value from the callback in order =

to remove the watch right then and there.  Similar to how g_io_add_watch =

and its callback works.

However, as I mentioned before, we need a way smarter data structure =

here long term.  A multi-level tree or something else.  The current =

l_hashmap_foreach traversal of signal_list needs to go away.

For the purposes of getting something working in the near future, I'm =

fine with this approach.

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

These three functions should probably be in dbus.c and the needed =

utilities exposed via dbus-private.h.

> diff --git a/ell/dbus.h b/ell/dbus.h
> index 9fcce03..8952dcf 100644
> --- a/ell/dbus.h
> +++ b/ell/dbus.h
> @@ -36,6 +36,8 @@ extern "C" {
>   #define DBUS_PATH_DBUS		"/org/freedesktop/DBus"
>   #define DBUS_INTERFACE_DBUS	"org.freedesktop.DBus"
>
> +#define DBUS_MAXIMUM_MATCH_RULE_LENGTH	1024
> +
>   enum l_dbus_bus {
>   	L_DBUS_SYSTEM_BUS,
>   	L_DBUS_SESSION_BUS,
> @@ -52,6 +54,8 @@ typedef void (*l_dbus_debug_func_t) (const char *str, v=
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
> @@ -204,6 +208,19 @@ bool l_dbus_unregister_interface(struct l_dbus *dbus=
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

--===============7226219656738943854==--

