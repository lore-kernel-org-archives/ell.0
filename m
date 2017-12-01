Content-Type: multipart/mixed; boundary="===============7956526364998619059=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: Re: [RFC 5/6] dbus: Add support for setting properties on D-Bus proxy
 interface
Date: Fri, 01 Dec 2017 16:01:32 +0100
Message-ID: <8844831.h3fZ7XXDys@ix>
In-Reply-To: <e5b9332f-57ff-5092-5404-96e551a0bc0e@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7956526364998619059==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Wednesday, 29 November 2017 18:05:14 CET Denis Kenzior wrote:
> Hi Szymon,
> =

> On 11/29/2017 09:16 AM, Szymon Janc wrote:
> > l_dbus_proxy_set_property function allows to set properties via proxy
> > interface.
> > ---
> > =

> >   ell/dbus-client.c | 96
> >   +++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >   ell/dbus-client.h |  8 +++++
> >   2 files changed, 104 insertions(+)
> > =

> > diff --git a/ell/dbus-client.c b/ell/dbus-client.c
> > index e6b6ff3..3f8c49f 100644
> > --- a/ell/dbus-client.c
> > +++ b/ell/dbus-client.c
> > @@ -182,6 +182,102 @@ static void l_dbus_proxy_unref(struct l_dbus_proxy
> > *proxy)> =

> >   	l_free(proxy);
> >   =

> >   }
> > =

> > +struct set_prop_data
> =

> I hate the name.  Maybe set_property_request?

I've named it "method_call_request" as it will also be used for tracking pr=
oxy =

method calls (and seting property is just a special method call).

> =

> > +{
> > +	struct l_dbus_proxy *proxy;
> > +	l_dbus_client_proxy_result_func_t result;
> > +	void *user_data;
> > +	l_dbus_destroy_func_t destroy;
> > +};
> > +
> > +static void set_prop_data_free(void *user_data)
> > +{
> > +	struct set_prop_data* prop =3D user_data;
> > +
> > +	if (prop->destroy)
> > +		prop->destroy(prop->user_data);
> > +
> > +	l_dbus_proxy_unref(prop->proxy);
> > +	l_free(prop);
> > +}
> > +
> > +static void set_prop_reply(struct l_dbus_message *message, void
> > *user_data) +{
> > +	struct set_prop_data* prop =3D user_data;
> > +
> > +	prop->result(prop->proxy, message, prop->user_data);
> > +}
> > +
> > +LIB_EXPORT bool l_dbus_proxy_set_property(struct l_dbus_proxy *proxy,
> > +				l_dbus_client_proxy_result_func_t result,
> > +				void *user_data, l_dbus_destroy_func_t destroy,
> > +				const char *name, const char *signature, ...)
> > +{
> > +	struct l_dbus_client *client =3D proxy->client;
> > +	struct l_dbus_message_builder *builder;
> > +	struct set_prop_data *set_prop_data;
> > +	struct l_dbus_message *message;
> > +	struct proxy_property *prop;
> > +	va_list args;
> > +
> > +	if (unlikely(!proxy))
> > +		return false;
> > +
> > +	prop =3D find_property(proxy, name);
> > +	if (!prop)
> > +		return false;
> > +
> > +	if (strcmp(l_dbus_message_get_signature(prop->msg), signature))
> > +		return false;
> > +
> > +	message =3D l_dbus_message_new_method_call(client->dbus, client-
>service,
> > +						proxy->path,
> > +						L_DBUS_INTERFACE_PROPERTIES,
> > +						"Set");
> > +	if (!message)
> > +		return false;
> > +
> > +	builder =3D l_dbus_message_builder_new(message);
> > +	if (!builder) {
> > +		l_dbus_message_unref(message);
> > +		return false;
> > +	}
> > +
> > +	l_dbus_message_builder_append_basic(builder, 's', proxy->interface);
> > +	l_dbus_message_builder_append_basic(builder, 's', name);
> > +
> > +	l_dbus_message_builder_enter_variant(builder, signature);
> > +
> > +	va_start(args, signature);
> > +	l_dbus_message_builder_append_from_valist(builder, signature, args);
> > +	va_end(args);
> > +
> > +	l_dbus_message_builder_leave_variant(builder);
> > +
> > +	l_dbus_message_builder_finalize(builder);
> > +	l_dbus_message_builder_destroy(builder);
> > +
> > +
> > +	if (!result) {
> > +		return l_dbus_send(client->dbus, message);
> > +	}
> =

> No need for {}

Fixed.

> =

> > +
> > +	set_prop_data =3D l_new(struct set_prop_data, 1);
> > +	set_prop_data->proxy =3D l_dbus_proxy_ref(proxy);
> =

> So its a bit weird that a proxy_removed might have been called, yet an
> outstanding call for that proxy is ongoing...  No idea how to fix this
> nicely but some options:
> =

> - cancel all pending requests when the proxy is destroyed
> - set a destroyed flag on the proxy and don't bother calling the
> callback in set_prop_reply
> - something else?

Right, I've miss that. I'll go with queue of pending calls and cancel those =

when proxy is destroyed.

> =

> > +	set_prop_data->result =3D result;
> > +	set_prop_data->user_data =3D user_data;
> > +	set_prop_data->destroy =3D destroy;
> > +
> > +	if (!l_dbus_send_with_reply(client->dbus, message, set_prop_reply,
> > +					set_prop_data, set_prop_data_free)) {
> > +		l_dbus_proxy_unref(set_prop_data->proxy);
> > +		l_free(set_prop_data);
> > +		return false;
> > +	}
> > +
> > +	return true;
> > +}
> > +
> > =

> >   static void proxy_update_property(struct l_dbus_proxy *proxy,
> >   =

> >   					const char *name,
> >   					struct l_dbus_message_iter *property)
> > =

> > diff --git a/ell/dbus-client.h b/ell/dbus-client.h
> > index b32f4a3..a65d8bb 100644
> > --- a/ell/dbus-client.h
> > +++ b/ell/dbus-client.h
> > @@ -39,6 +39,9 @@ typedef void (*l_dbus_client_ready_func_t)(struct
> > l_dbus_client *client,> =

> >   							void *user_data);
> >   =

> >   typedef void (*l_dbus_client_proxy_func_t) (struct l_dbus_proxy *prox=
y,
> >   =

> >   							void *user_data);
> > =

> > +typedef void (*l_dbus_client_proxy_result_func_t) (struct l_dbus_proxy
> > *proxy, +						struct l_dbus_message *result,
> > +						void *user_data);
> > =

> >   typedef void (*l_dbus_client_property_function_t) (struct l_dbus_proxy
> >   *proxy,>   =

> >   						const char *name,
> >   						struct l_dbus_message *msg,
> > =

> > @@ -80,6 +83,11 @@ const char *l_dbus_proxy_get_interface(struct
> > l_dbus_proxy *proxy);> =

> >   bool l_dbus_proxy_get_property(struct l_dbus_proxy *proxy, const char
> >   *name,>   =

> >   						const char *signature, ...);
> > =

> > +
> > +bool l_dbus_proxy_set_property(struct l_dbus_proxy *proxy,
> > +				l_dbus_client_proxy_result_func_t result,
> > +				void *user_data, l_dbus_destroy_func_t destroy,
> > +				const char *name, const char *signature, ...);
> > =

> >   #ifdef __cplusplus
> >   }
> >   #endif
> =

> Regards,
> -Denis


-- =

pozdrawiam
Szymon Janc

--===============7956526364998619059==--

