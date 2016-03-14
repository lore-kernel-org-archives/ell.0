Content-Type: multipart/mixed; boundary="===============2632408010245077474=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 07/20] dbus-filter: Name owner change tracking support.
Date: Mon, 14 Mar 2016 23:32:48 +0100
Message-ID: <CAOq732JXSB+qAfjwDq_71TeysWTL83nwEvi6w3jskdReQjucBQ@mail.gmail.com>
In-Reply-To: <56E6FCF6.5070505@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2632408010245077474==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 14 March 2016 at 19:03, Denis Kenzior <denkenz@gmail.com> wrote:
> Hi Andrew,
>
>
> On 03/13/2016 10:41 PM, Andrew Zaborowski wrote:
>>
>> This is needed because incoming message callbacks normally care what
>> Well-known Bus Name the message comes from but the sender field of the
>> message normally stores unique bus names in classic dbus.  The
>> Well-known names may be re-assigned to different unique names while the
>> rule is in place.
>> ---
>>   ell/dbus-filter.c  | 102
>> ++++++++++++++++++++++++++++++++++++++++++++++++++++-
>>   ell/dbus-private.h |   5 +++
>>   2 files changed, 106 insertions(+), 1 deletion(-)
>>
>> diff --git a/ell/dbus-filter.c b/ell/dbus-filter.c
>> index 2541374..f2cc023 100644
>> --- a/ell/dbus-filter.c
>> +++ b/ell/dbus-filter.c
>> @@ -62,6 +62,12 @@ struct _dbus_filter {
>>         unsigned int signal_id;
>>         unsigned int last_id;
>>         const struct _dbus_filter_ops *driver;
>> +       struct l_hashmap *unique_names;
>> +};
>> +
>> +struct unique_name_record {
>> +       int ref_count;
>> +       char *unique_name;
>>   };
>>
>>   static void filter_subtree_free(struct filter_node *node)
>> @@ -86,6 +92,14 @@ static void filter_subtree_free(struct filter_node
>> *node)
>>         }
>>   }
>>
>> +static void unique_name_record_free(void *data)
>> +{
>> +       struct unique_name_record *name_rec =3D data;
>> +
>> +       l_free(name_rec->unique_name);
>> +       l_free(name_rec);
>> +}
>> +
>>   static void dbus_filter_destroy(void *data)
>>   {
>>         struct _dbus_filter *filter =3D data;
>> @@ -93,6 +107,10 @@ static void dbus_filter_destroy(void *data)
>>         if (filter->root)
>>                 filter_subtree_free(filter->root);
>>
>> +       if (filter->unique_names)
>> +               l_hashmap_destroy(filter->unique_names,
>> +                                       unique_name_record_free);
>> +
>>         l_free(filter);
>>   }
>>
>> @@ -101,6 +119,8 @@ static void filter_dispatch_match_recurse(struct
>> _dbus_filter *filter,
>>                                                 struct l_dbus_message
>> *message)
>>   {
>>         const char *value =3D NULL;
>> +       const char *alt_value =3D NULL;
>> +       const struct unique_name_record *name_rec;
>>         struct filter_node *child;
>>
>>         switch ((int) node->type) {
>> @@ -141,7 +161,18 @@ static void filter_dispatch_match_recurse(struct
>> _dbus_filter *filter,
>>         if (!value)
>>                 return;
>>
>> -       if (strcmp(value, node->match.value))
>> +       if ((node->type =3D=3D L_DBUS_MATCH_SENDER ||
>> +                               node->type =3D=3D L_DBUS_MATCH_DESTINATI=
ON) &&
>
>
> According to DBus specification, destination matches only match the unique
> name:
> "Matches messages which are being sent to the given unique name. An examp=
le
> of a destination match is destination=3D':1.0'"

Okay, good point.
>
>
>> +                       filter->unique_names) {
>> +               name_rec =3D l_hashmap_lookup(filter->unique_names,
>> +                                               node->match.value);
>> +
>> +               if (name_rec)
>> +                       alt_value =3D name_rec->unique_name;
>> +       }
>> +
>> +       if (strcmp(value, node->match.value) &&
>> +                       (!alt_value || strcmp(value, alt_value)))
>>                 return;
>>
>>         for (child =3D node->match.children; child; child =3D child->nex=
t)
>> @@ -155,6 +186,21 @@ void _dbus_filter_dispatch(struct l_dbus_message
>> *message, void *user_data)
>>         filter_dispatch_match_recurse(filter, filter->root, message);
>>   }
>>
>> +void _dbus_filter_name_owner_notify(struct _dbus_filter *filter,
>> +                                       const char *name, const char
>> *owner)
>> +{
>> +       if (_dbus_parse_unique_name(name, NULL))
>> +               return;
>> +
>> +       name_rec =3D l_hashmap_lookup(filter->unique_names, name);
>> +       if (!name_rec)
>> +               return;
>> +
>> +       l_free(name_rec->unique_name);
>> +
>> +       name_rec->unique_name =3D (owner && *owner) ? l_strdup(owner) :
>> NULL;
>> +}
>> +
>>   struct _dbus_filter *_dbus_filter_new(struct l_dbus *dbus,
>>                                         const struct _dbus_filter_ops
>> *driver)
>>   {
>> @@ -170,6 +216,9 @@ struct _dbus_filter *_dbus_filter_new(struct l_dbus
>> *dbus,
>>                                                         filter,
>>
>> dbus_filter_destroy);
>>
>> +       if (filter->driver->track_name_owner_change)
>
>
> Is this ever going to be false?
>
>> +               filter->unique_names =3D l_hashmap_string_new();
>> +
>>         return filter;
>>   }
>>
>> @@ -184,6 +233,49 @@ void _dbus_filter_free(struct _dbus_filter *filter)
>>                 dbus_filter_destroy(filter);
>>   }
>>
>> +static void filter_add_bus_name(struct _dbus_filter *filter, const char
>> *name)
>> +{
>> +       struct unique_name_record *name_rec;
>> +
>> +       if (!filter->unique_names)
>> +               return;
>> +
>> +       if (_dbus_parse_unique_name(name, NULL))
>> +               return;
>
>
> Do you need to add a check for valid_bus_name?
>
> Should this function return something?

Maybe we should have a check in _dbus_filter_add_rule but I'd rather
let the user submit rules even for names that we think are wrong and
have the D-Bus implementation handle that.

>
>
>> +
>> +       name_rec =3D l_hashmap_lookup(filter->unique_names, name);
>> +       if (!name_rec) {
>> +               name_rec =3D l_new(struct unique_name_record, 1);
>> +
>> +               l_hashmap_insert(filter->unique_names, name, name_rec);
>> +
>> +               filter->driver->get_name_owner(filter->dbus, name);
>> +       }
>> +
>> +       name_rec->ref_count++;
>> +}
>> +
>> +static void filter_remove_bus_name(struct _dbus_filter *filter,
>> +                                       const char *name)
>> +{
>> +       struct unique_name_record *name_rec;
>> +
>> +       if (!filter->unique_names)
>> +               return;
>> +
>> +       if (_dbus_parse_unique_name(name, NULL))
>> +               return;
>> +
>> +       name_rec =3D l_hashmap_lookup(filter->unique_names, name);
>> +
>> +       if (--name_rec->ref_count)
>> +               return;
>> +
>> +       l_hashmap_remove(filter->unique_names, name);
>> +
>> +       unique_name_record_free(name_rec);
>> +}
>> +
>>   static int condition_compare(const void *a, const void *b)
>>   {
>>         const struct _dbus_filter_condition *condition_a =3D a, *conditi=
on_b
>> =3D b;
>> @@ -225,6 +317,10 @@ unsigned int _dbus_filter_add_rule(struct
>> _dbus_filter *filter,
>>                         node->match.value =3D l_strdup(condition->value);
>>
>>                         *node_ptr =3D node;
>> +
>> +                       if (node->type =3D=3D L_DBUS_MATCH_SENDER ||
>> +                                       node->type =3D=3D
>> L_DBUS_MATCH_DESTINATION)
>> +                               filter_add_bus_name(filter,
>> node->match.value);
>
>
> As mentioned before, L_DBUS_MATCH_DESTINATION does not seem to be relevant
> here.

Yes.

>
>>                 }
>>
>>                 node_ptr =3D &node->match.children;
>> @@ -286,6 +382,10 @@ static bool remove_recurse(struct _dbus_filter
>> *filter,
>>                 if (tmp->match.remote_rule)
>>                         filter->driver->remove_match(filter->dbus,
>> tmp->id);
>>
>> +               if (tmp->type =3D=3D L_DBUS_MATCH_SENDER ||
>> +                               tmp->type =3D=3D L_DBUS_MATCH_DESTINATIO=
N)
>> +                       filter_remove_bus_name(filter, tmp->match.value);
>> +
>>                 filter_subtree_free(tmp);
>>         }
>>
>> diff --git a/ell/dbus-private.h b/ell/dbus-private.h
>> index d4a4782..de4e706 100644
>> --- a/ell/dbus-private.h
>> +++ b/ell/dbus-private.h
>> @@ -250,11 +250,13 @@ struct _dbus_filter_condition {
>>   };
>>
>>   struct _dbus_filter_ops {
>> +       bool track_name_owner_change;
>
>
> Do we really need this? I think we can safely assume that this is true if
> get_name_owner implementation is provided.

Yes, let's do that.  The reason for this is that my earlier
implementation didn't have a get_name_owner.

Best regards

--===============2632408010245077474==--

