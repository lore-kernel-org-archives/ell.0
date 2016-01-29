Content-Type: multipart/mixed; boundary="===============4694049384131320179=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [RFC PATCH 8/8] dbus: Implement org.freedesktop.DBus.ObjectManager
Date: Thu, 28 Jan 2016 21:35:10 -0600
Message-ID: <56AADDEE.7010403@gmail.com>
In-Reply-To: <1453517972-22833-8-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4694049384131320179==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/22/2016 08:59 PM, Andrew Zaborowski wrote:
> This is a first approximation for the Object Manager implementation, it
> only works for a single ObjectManager object per tree (see FIXME) and
> the code that calls the property getters sequentially can probably be
> deduplicated a little.
> ---
>   ell/dbus-private.h       |   2 +
>   ell/dbus-service.c       | 333 ++++++++++++++++++++++++++++++++++++++++=
++++++-
>   ell/dbus.c               |  22 +++-
>   ell/dbus.h               |   2 +
>   examples/dbus-service.c  |   5 +
>   unit/test-dbus-service.c |   5 +-
>   6 files changed, 360 insertions(+), 9 deletions(-)
>
> diff --git a/ell/dbus-private.h b/ell/dbus-private.h
> index 0db777e..a00ef38 100644
> --- a/ell/dbus-private.h
> +++ b/ell/dbus-private.h
> @@ -185,9 +185,11 @@ bool _dbus_object_tree_unregister(struct _dbus_objec=
t_tree *tree,
>   				const char *interface);
>
>   bool _dbus_object_tree_add_interface(struct _dbus_object_tree *tree,
> +					struct l_dbus *dbus,
>   					const char *path, const char *interface,
>   					void *user_data);
>   bool _dbus_object_tree_remove_interface(struct _dbus_object_tree *tree,
> +					struct l_dbus *dbus,
>   					const char *path,
>   					const char *interface);

I'm not (yet) convinced by this change.  I think this needs a bit more =

thinking.

I think the way we want to do this is to model things something along =

these lines:

register_interface -> registers global interface object, e.g. =

l_dbus_interface
add_interface -> adds an instance of the interface to the tree, e.g. =

interface_instance

Each dbus bus instance would have a 1:1 relationship to the object tree. =

  For the purposes of signal emission, can we put the dbus pointer in =

the object_manager instance user_data?  If so, the parameter introduced =

above in _dbus_object_tree_add_interface and =

_dbus_object_tree_remove_interface can be omitted.

>
> diff --git a/ell/dbus-service.c b/ell/dbus-service.c
> index 4802b21..1e3c0f0 100644
> --- a/ell/dbus-service.c
> +++ b/ell/dbus-service.c
> @@ -27,6 +27,8 @@
>   #define _GNU_SOURCE
>   #include <stdarg.h>
>   #include <string.h>
> +#include <stdio.h>
> +#include <stdlib.h>
>
>   #include "util.h"
>   #include "queue.h"
> @@ -48,6 +50,7 @@ static const char *static_introspectable =3D
>   		"\t\t</method>\n\t</interface>\n";
>
>   #define DBUS_INTERFACE_PROPERTIES	"org.freedesktop.DBus.Properties"
> +#define DBUS_INTERFACE_OBJECT_MANAGER	"org.freedesktop.DBus.ObjectManage=
r"
>
>   struct _dbus_method {
>   	l_dbus_interface_method_cb_t cb;
> @@ -104,6 +107,7 @@ struct _dbus_object_tree {
>   	struct l_hashmap *objects;
>   	struct l_hashmap *property_requests;
>   	struct object_node *root;
> +	struct l_queue *object_managers;
>   };
>
>   void _dbus_method_introspection(struct _dbus_method *info,
> @@ -514,6 +518,7 @@ static bool match_interface_instance(const void *a, c=
onst void *b)
>   }
>
>   static void properties_setup_func(struct l_dbus_interface *);
> +static void object_manager_setup_func(struct l_dbus_interface *);
>
>   struct _dbus_object_tree *_dbus_object_tree_new()
>   {
> @@ -535,6 +540,11 @@ struct _dbus_object_tree *_dbus_object_tree_new()
>   	_dbus_object_tree_register(tree, DBUS_INTERFACE_PROPERTIES,
>   					properties_setup_func, NULL, false);
>
> +	tree->object_managers =3D l_queue_new();
> +
> +	_dbus_object_tree_register(tree, DBUS_INTERFACE_OBJECT_MANAGER,
> +					object_manager_setup_func, NULL, false);
> +
>   	return tree;
>   }
>
> @@ -568,6 +578,8 @@ void _dbus_object_tree_free(struct _dbus_object_tree =
*tree)
>
>   	subtree_free(tree->root);
>
> +	l_queue_destroy(tree->object_managers, NULL);
> +
>   	l_free(tree);
>   }
>
> @@ -902,6 +914,7 @@ struct get_properties_state {
>   	struct l_dbus_message_builder *builder;
>   	void *user_data;
>   	int count;
> +	int container_dicts;
>   };
>
>   static void get_next_property(struct l_dbus *dbus,
> @@ -930,6 +943,10 @@ static void get_next_property(struct l_dbus *dbus,
>
>   	if (!state->entry) {
>   		l_dbus_message_builder_leave_array(state->builder);
> +		while (state->container_dicts--) {
> +			l_dbus_message_builder_leave_dict(state->builder);
> +			l_dbus_message_builder_leave_array(state->builder);
> +		}
>   		l_dbus_message_builder_finalize(state->builder);
>
>   		l_dbus_send(dbus, state->reply);
> @@ -1004,13 +1021,50 @@ static void dbus_interface_setup(struct l_dbus_in=
terface *interface)
>   				"sv", "name", "value");
>   }
>
> +static void build_interfaces_added_signal(struct l_dbus *dbus,
> +					const char *manager_path,
> +					const char *path,
> +					struct interface_instance *instance)
> +{
> +	struct get_properties_state *state;
> +	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
> +	struct l_dbus_message *signal;
> +
> +	signal =3D l_dbus_message_new_signal(dbus, manager_path,
> +						DBUS_INTERFACE_OBJECT_MANAGER,
> +						"InterfacesAdded");
> +
> +	state =3D l_new(struct get_properties_state, 1);
> +
> +	state->message =3D l_dbus_message_ref(signal);
> +	state->reply =3D signal;
> +	state->entry =3D l_queue_get_entries(instance->interface->properties);
> +	state->builder =3D l_dbus_message_builder_new(signal);
> +	state->user_data =3D instance->user_data;
> +	state->container_dicts =3D 1;
> +
> +	l_hashmap_insert(tree->property_requests, signal, state);
> +
> +	l_dbus_message_builder_append_basic(state->builder, 'o', path);
> +	l_dbus_message_builder_enter_array(state->builder, "{sa{sv}}");
> +	l_dbus_message_builder_enter_dict(state->builder, "sa{sv}");
> +	l_dbus_message_builder_append_basic(state->builder, 's',
> +						instance->interface->name);
> +	l_dbus_message_builder_enter_array(state->builder, "{sv}");
> +
> +	get_next_property(dbus, signal, NULL);
> +
> +}
> +
>   bool _dbus_object_tree_add_interface(struct _dbus_object_tree *tree,
> -					const char *path, const char *interface,
> -					void *user_data)
> +					struct l_dbus *dbus, const char *path,
> +					const char *interface, void *user_data)
>   {
>   	struct object_node *object;
>   	struct l_dbus_interface *dbi;
>   	struct interface_instance *instance;
> +	const struct l_queue_entry *entry;
> +	const char *manager_path;
>
>   	dbi =3D l_hashmap_lookup(tree->interfaces, interface);
>   	if (!dbi)
> @@ -1044,15 +1098,48 @@ bool _dbus_object_tree_add_interface(struct _dbus=
_object_tree *tree,
>
>   	l_queue_push_tail(object->instances, instance);
>
> +	if (!dbus)
> +		return true;
> +
> +	for (entry =3D l_queue_get_entries(tree->object_managers); entry;
> +			entry =3D entry->next) {
> +		manager_path =3D entry->data;
> +
> +		if (memcmp(path, manager_path, strlen(manager_path)))
> +			continue;
> +
> +		build_interfaces_added_signal(dbus, manager_path,
> +						path, instance);
> +
> +		/*
> +		 * FIXME: currently we only emit one InterfacesAdded signal for
> +		 * the operation independent of the number of Object Managers
> +		 * to avoid having async getters running concurrently.
> +		 */
> +		break;
> +	}
> +
> +	if (!strcmp(interface, DBUS_INTERFACE_OBJECT_MANAGER))
> +		l_queue_push_tail(tree->object_managers, l_strdup(path));
> +
>   	return true;
>   }
>
> +static bool match_path(const void *a, const void *b)
> +{
> +	return !strcmp(a, b);
> +}
> +
>   bool _dbus_object_tree_remove_interface(struct _dbus_object_tree *tree,
> -					const char *path,
> +					struct l_dbus *dbus, const char *path,
>   					const char *interface)
>   {
>   	struct object_node *node;
>   	struct interface_instance *instance;
> +	const struct l_queue_entry *entry;
> +	char *manager_path;
> +	struct l_dbus_message *signal;
> +	struct l_dbus_message_builder *builder;
>
>   	node =3D l_hashmap_lookup(tree->objects, path);
>   	if (!node)
> @@ -1065,6 +1152,38 @@ bool _dbus_object_tree_remove_interface(struct _db=
us_object_tree *tree,
>
>   	interface_instance_free(instance);
>
> +	if (!dbus)
> +		return true;
> +
> +	if (!strcmp(interface, DBUS_INTERFACE_OBJECT_MANAGER)) {
> +		manager_path =3D l_queue_remove_if(tree->object_managers,
> +						match_path, (char *) path);
> +
> +		l_free(manager_path);
> +	}
> +
> +	for (entry =3D l_queue_get_entries(tree->object_managers); entry;
> +			entry =3D entry->next) {
> +		manager_path =3D entry->data;
> +
> +		if (memcmp(path, manager_path, strlen(manager_path)))
> +			continue;
> +
> +		signal =3D l_dbus_message_new_signal(dbus, manager_path,
> +						DBUS_INTERFACE_OBJECT_MANAGER,
> +						"InterfacesRemoved");
> +
> +		builder =3D l_dbus_message_builder_new(signal);
> +
> +		l_dbus_message_builder_append_basic(builder, 'o', path);
> +		l_dbus_message_builder_enter_array(builder, "s");
> +		l_dbus_message_builder_append_basic(builder, 's', interface);
> +		l_dbus_message_builder_leave_array(builder);
> +		l_dbus_message_builder_finalize(builder);
> +		l_dbus_message_builder_destroy(builder);
> +		l_dbus_send(dbus, signal);
> +	}
> +
>   	return true;
>   }
>
> @@ -1465,3 +1584,211 @@ static void properties_setup_func(struct l_dbus_i=
nterface *interface)
>   				"interface_name", "changed_properties",
>   				"invalidated_properties");
>   }
> +
> +struct get_objects_interface {
> +	const char *path;
> +	struct interface_instance *instance;
> +};
> +
> +struct get_objects_state {
> +	struct get_properties_state props_state;
> +	struct l_queue *interfaces;
> +	char *prefix;
> +	int prefix_len;
> +	int count;
> +	int interface_count;
> +};
> +
> +static void get_objects_next_property(struct l_dbus *dbus,
> +					struct l_dbus_message *message,
> +					struct l_dbus_message *error)
> +{
> +	struct get_objects_state *state;
> +	struct get_objects_interface *interface_info;
> +	struct l_dbus_interface *interface;
> +	struct _dbus_property *property;
> +	const char *signature;
> +	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
> +
> +	state =3D l_hashmap_lookup(tree->property_requests, message);
> +
> +	if (error) {
> +		l_dbus_message_unref(state->props_state.reply);
> +
> +		l_dbus_send(dbus, error);
> +
> +		goto done;
> +	}
> +
> +	if (state->props_state.count) {
> +		l_dbus_message_builder_leave_variant(
> +						state->props_state.builder);
> +		l_dbus_message_builder_leave_dict(state->props_state.builder);
> +	}
> +
> +	while (!state->props_state.entry) {
> +		if (state->interface_count) {
> +			l_dbus_message_builder_leave_array(
> +						state->props_state.builder);
> +			l_dbus_message_builder_leave_dict(
> +						state->props_state.builder);
> +			state->props_state.count =3D 0;
> +		}
> +
> +		interface_info =3D l_queue_pop_head(state->interfaces);
> +
> +		if ((!interface_info || !interface_info->instance) &&
> +				state->count) {
> +			l_dbus_message_builder_leave_array(
> +						state->props_state.builder);
> +			l_dbus_message_builder_leave_dict(
> +					state->props_state.builder);
> +			state->interface_count =3D 0;
> +		}
> +
> +		if (!interface_info) {
> +			l_dbus_message_builder_leave_array(
> +						state->props_state.builder);
> +			l_dbus_message_builder_finalize(
> +						state->props_state.builder);
> +
> +			l_dbus_send(dbus, state->props_state.reply);
> +
> +done:
> +			l_hashmap_remove(tree->property_requests,
> +						state->props_state.message);
> +			l_dbus_message_unref(state->props_state.message);
> +			l_dbus_message_builder_destroy(
> +						state->props_state.builder);
> +			l_queue_destroy(state->interfaces,
> +					(l_queue_destroy_func_t) l_free);
> +			l_free(state);
> +
> +			return;
> +		}
> +
> +		if (!interface_info->instance) {
> +			state->count +=3D 1;
> +
> +			l_dbus_message_builder_enter_dict(
> +						state->props_state.builder,
> +						"oa{sa{sv}}");
> +			l_dbus_message_builder_append_basic(
> +						state->props_state.builder,
> +						'o', interface_info->path);
> +			l_dbus_message_builder_enter_array(
> +						state->props_state.builder,
> +						"{sa{sv}}");
> +		} else {
> +			state->interface_count +=3D 1;
> +
> +			interface =3D interface_info->instance->interface;
> +
> +			state->props_state.entry =3D
> +				l_queue_get_entries(interface->properties);
> +			state->props_state.user_data =3D
> +				interface_info->instance->user_data;
> +
> +			l_dbus_message_builder_enter_dict(
> +						state->props_state.builder,
> +						"sa{sv}");
> +			l_dbus_message_builder_append_basic(
> +						state->props_state.builder,
> +						's', interface->name);
> +			l_dbus_message_builder_enter_array(
> +						state->props_state.builder,
> +						"{sv}");
> +		}
> +
> +		l_free(interface_info);
> +	}
> +
> +	property =3D state->props_state.entry->data;
> +	signature =3D property->metainfo + strlen(property->metainfo) + 1;
> +
> +	state->props_state.entry =3D state->props_state.entry->next;
> +	state->props_state.count +=3D 1;
> +
> +	l_dbus_message_builder_enter_dict(state->props_state.builder, "sv");
> +	l_dbus_message_builder_append_basic(state->props_state.builder, 's',
> +						property->metainfo);
> +	l_dbus_message_builder_enter_variant(state->props_state.builder,
> +						signature);
> +	property->getter(dbus, state->props_state.message,
> +				state->props_state.builder,
> +				get_objects_next_property,
> +				state->props_state.user_data);
> +}
> +
> +/* Collect the interface data to be queried for one object */
> +static void get_one_object(const void *key, void *value, void *user_data)
> +{
> +	const char *path =3D key;
> +	struct object_node *object =3D value;
> +	struct get_objects_state *state =3D user_data;
> +	const struct l_queue_entry *entry;
> +	struct get_objects_interface *interface_info;
> +
> +	if (memcmp(path, state->prefix, state->prefix_len))
> +		return;
> +
> +	interface_info =3D l_new(struct get_objects_interface, 1);
> +	interface_info->path =3D path;
> +

We have to be pretty careful here.  What if the object is removed while =

we're generating the reply?  Do we need to rethink having async getters?

> +	/* Add the object's own entry */
> +	l_queue_push_tail(state->interfaces, interface_info);
> +
> +	for (entry =3D l_queue_get_entries(object->instances); entry;
> +			entry =3D entry->next) {
> +		interface_info =3D l_new(struct get_objects_interface, 1);
> +		interface_info->path =3D path;
> +		interface_info->instance =3D entry->data;
> +
> +		/* Add a complete interface entry */
> +		l_queue_push_tail(state->interfaces, interface_info);
> +	}
> +}
> +
> +static struct l_dbus_message *get_managed_objects(struct l_dbus *dbus,
> +						struct l_dbus_message *message,
> +						void *user_data)
> +{
> +	struct get_objects_state *state;
> +	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
> +
> +	state =3D l_new(struct get_objects_state, 1);
> +	state->interfaces =3D l_queue_new();
> +	state->prefix_len =3D asprintf(&state->prefix, "%s/",
> +					l_dbus_message_get_path(message));
> +
> +	/* Build a list of interfaces to query */
> +	l_hashmap_foreach(tree->objects, get_one_object, state);
> +

Yikes.  Is there a way to be a bit smarter here and walk the tree =

instead of using the very expensive hashmap_foreach?

> +	free(state->prefix);
> +
> +	state->props_state.message =3D l_dbus_message_ref(message);
> +	state->props_state.reply =3D l_dbus_message_new_method_return(message);
> +	state->props_state.builder =3D
> +		l_dbus_message_builder_new(state->props_state.reply);
> +
> +	l_hashmap_insert(tree->property_requests, message, state);
> +
> +	l_dbus_message_builder_enter_array(state->props_state.builder,
> +						"{oa{sa{sv}}}");
> +
> +	get_objects_next_property(dbus, message, NULL);
> +
> +	return NULL;
> +}
> +
> +static void object_manager_setup_func(struct l_dbus_interface *interface)
> +{
> +	l_dbus_interface_method(interface, "GetManagedObjects", 0,
> +				get_managed_objects, "a{oa{sa{sv}}}", "",
> +				"objpath_interfaces_and_properties");
> +
> +	l_dbus_interface_signal(interface, "InterfacesAdded", 0, "oa{sa{sv}}",
> +				"object_path", "interfaces_and_properties");
> +	l_dbus_interface_signal(interface, "InterfacesRemoved", 0, "oas",
> +				"object_path", "interfaces");
> +}

<snip>

Regards,
-Denis

--===============4694049384131320179==--

