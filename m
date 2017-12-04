Content-Type: multipart/mixed; boundary="===============3538116644546270330=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/6] dbus: Add support for proxy interface
Date: Mon, 04 Dec 2017 12:40:29 -0600
Message-ID: <d62a628a-76f9-6e13-1656-993161d17b73@gmail.com>
In-Reply-To: <20171201150610.9696-4-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3538116644546270330==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Szymon,

<snip>

> +static struct l_dbus_proxy *l_dbus_proxy_new(struct l_dbus_client *clien=
t,
> +					const char *path, const char *interface)

I would just call it dbus_proxy_new since it is not exported.  Same with =

l_dbus_proxy_destroy

> +{
> +	struct l_dbus_proxy *proxy;
> +
> +	proxy =3D l_new(struct l_dbus_proxy, 1);

can condense these to a single line...

> +
> +	proxy->properties_watch =3D l_dbus_add_signal_watch(client->dbus,
> +						client->service, path,
> +						L_DBUS_INTERFACE_PROPERTIES,
> +						"PropertiesChanged",
> +						L_DBUS_MATCH_ARGUMENT(0),
> +						interface, L_DBUS_MATCH_NONE,
> +						properties_changed_callback,
> +						proxy);
> +	if (!proxy->properties_watch) {
> +		l_free(proxy);
> +		return NULL;
> +	}
> +
> +	proxy->client =3D client;
> +	proxy->interface =3D l_strdup(interface);
> +	proxy->path =3D l_strdup(path);
> +	proxy->properties =3D l_queue_new();
> +
> +	l_queue_push_tail(client->proxies, proxy);
> +
> +	return proxy;
> +}
> +
> +static bool is_ignorable(const char *interface)
> +{
> +	static const struct {
> +		const char *interface;
> +	} interfaces_to_ignore[] =3D {
> +		{ L_DBUS_INTERFACE_OBJECT_MANAGER },
> +		{ L_DBUS_INTERFACE_INTROSPECTABLE },
> +		{ L_DBUS_INTERFACE_PROPERTIES },
> +	};
> +	size_t i;
> +
> +	for (i =3D 0; i < L_ARRAY_SIZE(interfaces_to_ignore); i++)
> +		if (!strcmp(interfaces_to_ignore[i].interface, interface))
> +			return true;
> +
> +	return false;
> +}
> +
> +static struct l_dbus_proxy *find_proxy(struct l_dbus_client *client,
> +					const char *path, const char *interface)
> +{
> +	const struct l_queue_entry *entry;
> +
> +	for (entry =3D l_queue_get_entries(client->proxies); entry;
> +							entry =3D entry->next) {
> +		struct l_dbus_proxy *proxy =3D entry->data;
> +
> +		if (!strcmp(proxy->interface, interface) &&
> +						!strcmp(proxy->path, path))
> +			return proxy;
> +	}
> +
> +	return NULL;
> +}
> +
> +static void parse_interface(struct l_dbus_client *client, const char *pa=
th,
> +					const char *interface,
> +					struct l_dbus_message_iter *properties)
> +{
> +	struct l_dbus_proxy *proxy;
> +
> +	if (is_ignorable(interface))
> +		return;
> +
> +	proxy =3D find_proxy(client, path, interface);
> +	if (!proxy) {
> +		proxy =3D l_dbus_proxy_new(client, path, interface);
> +	}

No need for {}

> +
> +	if (!proxy)
> +		return;
> +
> +	proxy_update_properties(proxy, properties);
> +
> +	if (!proxy->ready) {
> +		proxy->ready =3D true;
> +
> +		if (client->proxy_added_cb)
> +			client->proxy_added_cb(proxy, client->proxy_cb_data);
> +	}
> +}
> +

<snip>

> +
> +static void service_appeared_callback(struct l_dbus *dbus, void *user_da=
ta)
> +{
> +	struct l_dbus_client *client =3D user_data;
> +
> +	/* TODO should we allow to set different root? */
> +	client->objects_call =3D l_dbus_method_call(dbus, client->service, "/",
> +						L_DBUS_INTERFACE_OBJECT_MANAGER,
> +						"GetManagedObjects", NULL,
> +						get_managed_objects_reply,
> +						client, NULL);
> +
> +	if (client->connect_cb)
> +		client->connect_cb(client->dbus, client->connect_cb_data);
> +}
> +
> +static void service_disappeared_callback(struct l_dbus *dbus, void *user=
_data)
> +{
> +	struct l_dbus_client *client =3D user_data;
> +
> +	if (client->disconnect_cb)
> +		client->disconnect_cb(client->dbus, client->disconnect_cb_data);
> +
> +	l_queue_clear(client->proxies,
> +				(l_queue_destroy_func_t)l_dbus_proxy_destroy);
> +}
> +
> +LIB_EXPORT struct l_dbus_client *l_dbus_client_new(struct l_dbus *dbus,
> +					const char *service, const char *path)
> +{
> +	struct l_dbus_client *client;
> +
> +	client =3D l_new(struct l_dbus_client, 1);
> +

Can condense these to a single line

> +	client->dbus =3D dbus;
> +
> +	client->watch =3D l_dbus_add_service_watch(dbus, service,
> +						service_appeared_callback,
> +						service_disappeared_callback,
> +						client, NULL);
> +
> +	if (!client->watch) {
> +		l_free(client);
> +		return NULL;
> +	}
> +
> +	client->service =3D l_strdup(service);
> +	client->path =3D l_strdup(path);

What is the purpose of this member actually?  We're not using it for the =

ObjectManager root, nor are we using it for anything else.  I also don't =

get its purpose in gdbus either.  Can we simply drop it?

> +	client->proxies =3D l_queue_new();
> +
> +	return client;
> +}
> +
> +LIB_EXPORT void l_dbus_client_destroy(struct l_dbus_client *client)
> +{
> +	if (unlikely(!client))
> +		return;
> +
> +	if (client->watch)
> +		l_dbus_remove_signal_watch(client->dbus, client->watch);
> +
> +	if (client->added_watch)
> +		l_dbus_remove_signal_watch(client->dbus, client->added_watch);
> +
> +	if (client->removed_watch)
> +		l_dbus_remove_signal_watch(client->dbus, client->removed_watch);
> +
> +	if (client->connect_cb_data_destroy)
> +		client->connect_cb_data_destroy(client->connect_cb_data);
> +
> +	if (client->disconnect_cb_data_destroy)
> +		client->disconnect_cb_data_destroy(client->disconnect_cb_data);
> +
> +	if (client->ready_cb_data_destroy)
> +		client->ready_cb_data_destroy(client->ready_cb_data);
> +
> +	if (client->proxy_cb_data_destroy)
> +		client->proxy_cb_data_destroy(client->proxy_cb_data);
> +
> +	if (client->objects_call)
> +		l_dbus_cancel(client->dbus, client->objects_call)
> +;
> +	l_queue_destroy(client->proxies,
> +				(l_queue_destroy_func_t)l_dbus_proxy_destroy);
> +
> +	l_free(client->service);
> +	l_free(client->path);
> +	l_free(client);
> +}
> +
> +LIB_EXPORT bool l_dbus_client_set_connect_handler(struct l_dbus_client *=
client,
> +						l_dbus_watch_func_t function,
> +						void *user_data,
> +						l_dbus_destroy_func_t destroy)
> +{
> +	if (unlikely(!client))
> +		return false;
> +
> +	client->connect_cb =3D function;
> +	client->connect_cb_data =3D user_data;
> +	client->connect_cb_data_destroy =3D destroy;

No biggie, but maybe we should call destroy function here in case it is =

already set.

> +
> +	return true;
> +}
> +
> +LIB_EXPORT bool l_dbus_client_set_disconnect_handler(struct l_dbus_clien=
t *client,
> +						l_dbus_watch_func_t function,
> +						void *user_data,
> +						l_dbus_destroy_func_t destroy)
> +{
> +	if (unlikely(!client))
> +		return false;
> +
> +	client->disconnect_cb =3D function;
> +	client->disconnect_cb_data =3D user_data;
> +	client->disconnect_cb_data_destroy =3D destroy;

as above

> +
> +	return true;
> +}
> +
> +LIB_EXPORT bool l_dbus_client_set_ready_handler(struct l_dbus_client *cl=
ient,
> +					l_dbus_client_ready_func_t function,
> +					void *user_data,
> +					l_dbus_destroy_func_t destroy)
> +{
> +	if (unlikely(!client))
> +		return false;
> +
> +	client->ready_cb =3D function;
> +	client->ready_cb_data =3D user_data;
> +	client->ready_cb_data_destroy =3D destroy;

as above

> +
> +	return true;
> +}
> +
> +LIB_EXPORT bool l_dbus_client_set_proxy_handlers(struct l_dbus_client *c=
lient,
> +			l_dbus_client_proxy_func_t proxy_added,
> +			l_dbus_client_proxy_func_t proxy_removed,
> +			l_dbus_client_property_function_t property_changed,
> +			void *user_data, l_dbus_destroy_func_t destroy)
> +{
> +	if (unlikely(!client))
> +		return false;
> +
> +	client->proxy_added_cb =3D proxy_added;
> +	client->proxy_removed_cb =3D proxy_removed;
> +	client->properties_changed_cb =3D property_changed;
> +	client->proxy_cb_data =3D user_data;
> +	client->proxy_cb_data_destroy =3D destroy;

as above

> +
> +	return true;
> +}

<snip>

Regards,
-Denis

--===============3538116644546270330==--

