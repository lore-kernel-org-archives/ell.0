Content-Type: multipart/mixed; boundary="===============6813029311601607623=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/5] dbus: Coalesce PropertiesChanged signals
Date: Fri, 26 Feb 2016 14:30:15 -0600
Message-ID: <56D0B5D7.8060209@gmail.com>
In-Reply-To: <1455765612-6577-2-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6813029311601607623==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 02/17/2016 09:20 PM, Andrew Zaborowski wrote:
> When multiple properties are changed in one main loop cycle emit only
> one signal per interface with all the changes.
> ---
>   ell/dbus-private.h |   3 +-
>   ell/dbus-service.c | 256 ++++++++++++++++++++++++++++++++++++----------=
-------
>   2 files changed, 177 insertions(+), 82 deletions(-)
>

<snip>

> @@ -991,76 +1132,25 @@ bool _dbus_object_tree_property_changed(struct l_d=
bus *dbus,
>   	if (!property)
>   		return false;
>
> -	signature =3D property->metainfo + strlen(property->metainfo) + 1;
> -
> -	if (instance->interface->handle_old_style_properties) {
> -		signal =3D l_dbus_message_new_signal(dbus, path,
> -							interface_name,
> -							"PropertyChanged");
> +	rec =3D l_queue_find(tree->property_changes,
> +				match_property_changes_instance, instance);
>
> -		builder =3D l_dbus_message_builder_new(signal);
> -
> -		l_dbus_message_builder_append_basic(builder, 's',
> -							property_name);
> -		l_dbus_message_builder_enter_variant(builder, signature);

This looks a bit suspicious.  Should we be also comparing the object =

pointer, not just the instance pointer here?

> +	if (rec) {
> +		if (l_queue_find(rec->properties, match_pointer, property))
> +			return true;
> +	} else {
> +		rec =3D l_new(struct property_changes, 1);
> +		rec->path =3D l_strdup(path);
> +		rec->object =3D object;
> +		rec->instance =3D instance;
> +		rec->properties =3D l_queue_new();
>
> -		if (variant) {
> -			memcpy(&value, variant, sizeof(value));
> -			r =3D l_dbus_message_builder_append_from_iter(builder,
> -								&value);
> -		} else {
> -			r =3D property->getter(dbus, signal, builder,
> -						instance->user_data);
> -		}
> -
> -		if (r) {
> -			l_dbus_message_builder_leave_variant(builder);
> -
> -			l_dbus_message_builder_finalize(builder);
> -			l_dbus_send(dbus, signal);
> -		}
> -
> -		l_dbus_message_builder_destroy(builder);
> +		l_queue_push_tail(tree->property_changes, rec);
>   	}
>
> -	if (l_queue_find(object->instances, match_interface_instance,
> -				DBUS_INTERFACE_PROPERTIES)) {
> -		signal =3D l_dbus_message_new_signal(dbus, path,
> -						DBUS_INTERFACE_PROPERTIES,
> -						"PropertiesChanged");
> -
> -		builder =3D l_dbus_message_builder_new(signal);
> -
> -		l_dbus_message_builder_append_basic(builder, 's',
> -							interface_name);
> -		l_dbus_message_builder_enter_array(builder, "{sv}");
> -		l_dbus_message_builder_enter_dict(builder, "sv");
> -		l_dbus_message_builder_append_basic(builder, 's',
> -							property_name);
> -		l_dbus_message_builder_enter_variant(builder, signature);
> +	l_queue_push_tail(rec->properties, property);
>
> -		if (variant) {
> -			memcpy(&value, variant, sizeof(value));
> -			r =3D l_dbus_message_builder_append_from_iter(builder,
> -								&value);
> -		} else {
> -			r =3D property->getter(dbus, signal, builder,
> -						instance->user_data);
> -		}
> -
> -		if (r) {
> -			l_dbus_message_builder_leave_variant(builder);
> -			l_dbus_message_builder_leave_dict(builder);
> -			l_dbus_message_builder_leave_array(builder);
> -			l_dbus_message_builder_enter_array(builder, "s");
> -			l_dbus_message_builder_leave_array(builder);
> -
> -			l_dbus_message_builder_finalize(builder);
> -			l_dbus_send(dbus, signal);
> -		}
> -
> -		l_dbus_message_builder_destroy(builder);
> -	}
> +	schedule_emit_signals(dbus);
>
>   	return true;
>   }

Regards,
-Denis


--===============6813029311601607623==--

