Content-Type: multipart/mixed; boundary="===============2013509380571562581=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/8] dbus: Rewrite service/disconnect watch APIs on top of
 filter API
Date: Sat, 26 Mar 2016 16:50:03 +0100
Message-ID: <CAOq732K46EEX7UX3kA=JXuZn9ZbPJqOCNnBTsorDvbbeHXa7Lw@mail.gmail.com>
In-Reply-To: <56F5FBA7.3020500@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2013509380571562581==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

 in the cur would Hi Denis,

On 26 March 2016 at 04:01, Denis Kenzior <denkenz@gmail.com> wrote:
> On 03/25/2016 07:06 PM, Andrzej Zaborowski wrote:
>> On 25 March 2016 at 03:55, Denis Kenzior <denkenz@gmail.com> wrote:
>>> On 03/23/2016 09:07 PM, Andrew Zaborowski wrote:
>>>>
>>>> @@ -363,6 +379,35 @@ static void bus_ready(struct l_dbus *dbus)
>>>>          l_io_set_write_handler(dbus->io, message_write_handler, dbus,
>>>> NULL);
>>>>    }
>>>>
>>>> +static void name_owner_notify(struct l_dbus *dbus, const char *name,
>>>> +                               const char *old, const char *new)
>>>> +{
>>>> +       struct service_watch_data *watch;
>>>> +       bool connect =3D old && new && !*old && *new;
>>>> +       bool disconnect =3D old && new && *old && !*new;
>>>
>>>
>>>
>>> This makes my brain hurt.  I also don't think this works properly.  Half
>>> the
>>> functions call name_owner_notify with empty strings and the other half
>>> calls
>>> it with NULLs.
>>>
>>> The disconnect can be expressed much simpler as *new =3D=3D '\0'.
>>
>>
>> Disconnects yes, the NULLs are a different case where we don't know
>> the old value.  We can't do *old =3D=3D '\0' without checking that it
>> isn't NULL.
>>
>> But, I can change this function's signature to be something like void
>> name_owner_notify(dbus, const char *name, bool connect, bool
>> disconnect, const char *owner)
>>
>
> Nah, the signature is fine.  I think you need to make the flow a bit
> simpler.  The current logic listens to NameOwnerChanged and also queues up
> the GetNameOwner call.  If the NameOwnerChanged signal wins the race,
> GetNameOwner call is canceled, connect is called.  If GetNameOwner returns
> first, connect is called and subsequent NameOwnerChanged (if it arrives at
> all) doesn't do anything.

Yep, that's also what I think this patch does, I'm not sure if you're
saying there's any issue here.  We don't cancel the GetnameOnwer
though.

>
> You try to do something similar with pending_get_name_owner flag.  So lets
> use it to our advantage...

pending_get_name_owner is necessary to implement the logic above
because if the watch has just been added (flag is true), we have to
call connect regardless of whether the service has just popped up or
has already existed.  If the flag is false, we only call connect if
the service had been disconnected before.

>
>>>
>>>
>>>> +
>>>> +       _dbus_filter_name_owner_notify(dbus->filter, name, new);
>>>> +
>>>> +       watch =3D l_hashmap_lookup(dbus->services_watched, name);
>>>> +
>>>> +       while (watch && !strcmp(watch->bus_name, name)) {
>>>> +               if (watch->removed)
>>>> +                       goto next;
>>>> +
>>>> +               if (watch->pending_get_name_owner) {
>>>> +                       watch->pending_get_name_owner =3D false;
>>>> +                       if (new && *new)
>>>> +                               watch->connect_func(dbus,
>>>> watch->user_data);
>
>
> In case new is non-null, reset pending_get_name_owner to false and call
> connect.

We have to additionally check that either the service had been
disconneted until now (old was empty) or pending_get_name_owner is
true.

>
>>>> +               } else if (connect && watch->connect_func)
>>>> +                       watch->connect_func(dbus, watch->user_data);
>>>> +               else if (disconnect && watch->disconnect_func)
>>>> +                       watch->disconnect_func(dbus, watch->user_data);
>>>> +
>>>> +next:
>>>> +               watch =3D watch->next;
>>>> +       }
>>>> +}
>>>> +
>>>>    static void hello_callback(struct l_dbus_message *message, void
>>>> *user_data)
>>>>    {
>>>>          struct l_dbus *dbus =3D user_data;
>>>> @@ -752,7 +797,7 @@ static void get_name_owner_reply_cb(struct
>>>> l_dbus_message *reply,
>>>>          if (!l_dbus_message_get_arguments(req->message, "s", &name))
>>>>                  return;
>>>>
>>>> -       _dbus_filter_name_owner_notify(req->dbus->filter, name, owner);
>>>> +       name_owner_notify(req->dbus, name, NULL, owner);
>
>
> Then here, if pending_get_name_owner is false, simply return.
> get_name_owner_reply lost the race.

We don't itereate over all the watches here.  We could do that but I
wanted to extract the common driver-independent logic out to a common
function, name_owner_notify.

>
> Otherwise, just call with "" instead of NULL and simplify your life in
> name_owner_notify.

But then again there may be watches for the same name that should not
have their "connect" called, so we still need some way to convey that.
Besides that "simplification" removes a single NULL check at a cost of
triplicated code.

>
>>>
>>>
>>> should this use "" instead of NULL?
>>
>>
>> If we pass "" then name_owner_notify will have to assume this is a new
>> connection and will issue spurious connect calls.  The NULL here says
>> to not treat this as new connection or disconnection.
>>
>
> And by the way, we might want to handle the case where a service name is
> changed from one unique name to another.  E.g. due to RequestName being
> queued or DBUS_NAME_FLAG_REPLACE_EXISTING somehow succeeding so that the
> name is passed from one service to another.
>
> For our purposes, calling disconnect and then immediately calling connect
> would probably be okay for now.

Ah again good point, I'll add this.

>
>
>>>
>>>>    }
>>>>
>>>>    static bool classic_get_name_owner(struct l_dbus *bus, const char
>>>> *name)
>>>> @@ -800,7 +845,7 @@ static void name_owner_changed_cb(struct
>>>> l_dbus_message *message,
>>>>          if (!l_dbus_message_get_arguments(message, "sss", &name, &old,
>>>> &new))
>>>>                  return;
>>>>
>>>> -       _dbus_filter_name_owner_notify(dbus->filter, name, new);
>>>> +       name_owner_notify(dbus, name, old, new);
>>>>    }
>>>>
>>>>    static struct l_dbus *setup_dbus1(int fd, const char *guid)
>>>> @@ -1000,15 +1045,22 @@ static void kdbus_name_owner_change_func(const
>>>> char *name, uint64_t old_owner,
>>>>                                                  void *user_data)
>>>>    {
>>>>          struct kdbus_message_recv_data *recv_data =3D user_data;
>>>> -       char owner[32];
>>>> +       char old[32], new[32];
>>>>
>>>>          l_util_debug(recv_data->dbus->debug_handler,
>>>>                          recv_data->dbus->debug_data,
>>>>                          "Read KDBUS Name Owner Change notification");
>>>>
>>>> -       snprintf(owner, sizeof(owner), ":1.%" PRIu64, new_owner);
>>>> +       if (old_owner)
>>>> +               snprintf(old, sizeof(old), ":1.%" PRIu64, new_owner);
>>>
>>>
>>>
>>> old_owner here, not new_owner?
>>
>>
>> Yes, thanks for catching this.
>>
>>>
>>>> +       else
>>>> +               *old =3D '\0';
>>>> +       if (new_owner)
>>>> +               snprintf(new, sizeof(new), ":1.%" PRIu64, new_owner);
>>>> +       else
>>>> +               *new =3D '\0';
>>>>
>>>> -       _dbus_filter_name_owner_notify(recv_data->dbus->filter, name,
>>>> owner);
>>>> +       name_owner_notify(recv_data->dbus, name, old, new);
>>>>    }
>>>>
>>>>    static struct l_dbus_message *kdbus_recv_message(struct l_dbus *dbu=
s)
>>>> @@ -1070,15 +1122,13 @@ static bool kdbus_get_name_owner(struct l_dbus
>>>> *dbus, const char *name)
>>>>          char owner[32];
>>>>
>>>>          owner_id =3D _dbus_kernel_get_name_owner(fd, kdbus->kdbus_poo=
l,
>>>> name);
>>>> -       if (!owner_id) {
>>>> -               l_util_debug(dbus->debug_handler,
>>>> -                               dbus->debug_data, "Error getting name
>>>> owner");
>>>> -               return false;
>>>> -       }
>>>>
>>>> -       snprintf(owner, sizeof(owner), ":1.%" PRIu64, owner_id);
>>>> +       if (owner_id)
>>>> +               snprintf(owner, sizeof(owner), ":1.%" PRIu64, owner_id=
);
>>>> +       else
>>>> +               *owner =3D '\0';
>>>>
>>>> -       _dbus_filter_name_owner_notify(dbus->filter, name, owner);
>>>> +       name_owner_notify(dbus, name, NULL, owner);
>>>
>>>
>>>
>>> "" instead of NULL?
>>>
>
> With kdbus you don't even have a race, so using "" should be safe, no?

Well, name_owner_notify in the current form may call connect for other
watches for the same service.  We'd have to call the connect callback
right from this function and reset pending_get_name_owner.  I
personally like to keep the whole logic contained in name_owner_notify
and not have the driver functions do the work, but I could do that.
>
>
>>>
>>>>
>>>>          return true;
>>>>    }
>>>> @@ -1222,6 +1272,17 @@ LIB_EXPORT struct l_dbus *l_dbus_new_default(en=
um
>>>> l_dbus_bus bus)
>>>>          return setup_address(address);
>>>>    }
>>>>
>>>> +static void service_watch_data_free(void *data)
>>>> +{
>>>> +       struct service_watch_data *watch =3D data;
>>>> +
>>>> +       if (watch->destroy_func)
>>>> +               watch->destroy_func(watch->user_data);
>>>> +
>>>> +       l_free(watch->bus_name);
>>>> +       l_free(watch);
>>>> +}
>>>> +
>>>>    LIB_EXPORT void l_dbus_destroy(struct l_dbus *dbus)
>>>>    {
>>>>          if (unlikely(!dbus))
>>>> @@ -1236,6 +1297,11 @@ LIB_EXPORT void l_dbus_destroy(struct l_dbus
>>>> *dbus)
>>>>          l_hashmap_destroy(dbus->message_list, message_list_destroy);
>>>>          l_queue_destroy(dbus->message_queue, message_queue_destroy);
>>>>
>>>> +       l_hashmap_destroy(dbus->services_watched,
>>>> service_watch_data_free);
>>>> +
>>>> +       if (dbus->service_watch_remove_work)
>>>> +               l_idle_remove(dbus->service_watch_remove_work);
>>>> +
>>>>          l_io_destroy(dbus->io);
>>>>
>>>>          if (dbus->disconnect_destroy)
>>>> @@ -1809,33 +1875,6 @@ void _dbus1_name_owner_changed_filter(struct
>>>> l_dbus_message *message,
>>>>          }
>>>>    }
>>>>
>>>> -static void _dbus1_get_name_owner_reply(struct l_dbus_message *messag=
e,
>>>> -                                                       void *user_dat=
a)
>>>> -{
>>>> -       struct dbus1_filter_data *data =3D user_data;
>>>> -       const char *name;
>>>> -
>>>> -       data->get_name_owner_id =3D 0;
>>>> -
>>>> -       /* No name owner yet */
>>>> -       if (l_dbus_message_is_error(message))
>>>> -               return;
>>>> -
>>>> -       /* Shouldn't happen */
>>>> -       if (!l_dbus_message_get_arguments(message, "s", &name))
>>>> -               return;
>>>> -
>>>> -       /* If the signal arrived before the reply, don't do anything */
>>>> -       if (data->owner && !strcmp(data->owner, name))
>>>> -               return;
>>>> -
>>>> -       l_free(data->owner);
>>>> -       data->owner =3D l_strdup(name);
>>>> -
>>>> -       if (data->connect_func)
>>>> -               data->connect_func(data->dbus, data->user_data);
>>>> -}
>>>> -
>>>>    LIB_EXPORT unsigned int l_dbus_add_disconnect_watch(struct l_dbus
>>>> *dbus,
>>>>                                          const char *name,
>>>>                                          l_dbus_watch_func_t
>>>> disconnect_func,
>>>> @@ -1846,56 +1885,103 @@ LIB_EXPORT unsigned int
>>>> l_dbus_add_disconnect_watch(struct l_dbus *dbus,
>>>>                                          user_data, destroy);
>>>>    }
>>>>
>>>> -unsigned int l_dbus_add_service_watch(struct l_dbus *dbus,
>>>> +LIB_EXPORT unsigned int l_dbus_add_service_watch(struct l_dbus *dbus,
>>>>                                          const char *name,
>>>>                                          l_dbus_watch_func_t
>>>> connect_func,
>>>>                                          l_dbus_watch_func_t
>>>> disconnect_func,
>>>>                                          void *user_data,
>>>>                                          l_dbus_destroy_func_t destroy)
>>>>    {
>>>> -       struct dbus1_filter_data *data;
>>>> +       struct service_watch_data *watch, *first;
>>>>
>>>>          if (!name)
>>>>                  return 0;
>>>>
>>>> -       data =3D _dbus1_filter_data_get(dbus,
>>>> _dbus1_name_owner_changed_filter,
>>>> -                               DBUS_SERVICE_DBUS, DBUS_PATH_DBUS,
>>>> -                               L_DBUS_INTERFACE_DBUS,
>>>> "NameOwnerChanged",
>>>> -                               name,
>>>> -                               disconnect_func,
>>>> -                               user_data,
>>>> -                               destroy);
>>>> -       if (!data)
>>>> -               return 0;
>>>> +       if (!dbus->services_watched)
>>>> +               dbus->services_watched =3D l_hashmap_string_new();
>>>> +
>>>> +       watch =3D l_new(struct service_watch_data, 1);
>>>> +       watch->bus_name =3D l_strdup(name);
>>>> +       watch->id =3D ++dbus->last_service_watch_id;
>>>> +       watch->connect_func =3D connect_func;
>>>> +       watch->disconnect_func =3D disconnect_func;
>>>> +       watch->destroy_func =3D destroy;
>>>> +
>>>> +       /*
>>>> +        * Make sure that all the entries for the same bus name are
>>>> +        * grouped together on the list and that the first entry for t=
he
>>>> +        * name is in the hashmap for easy lookups.
>>>> +        */
>>>> +       first =3D l_hashmap_lookup(dbus->services_watched, name);
>>>> +       if (first) {
>>>> +               watch->next =3D first->next;
>>>> +               first->next =3D watch;
>>>> +       } else {
>>>> +               l_hashmap_insert(dbus->services_watched, name, watch);
>>>>
>>>> -       add_match(data);
>>>> +               watch->next =3D dbus->service_watch_head;
>>>> +               dbus->service_watch_head =3D watch;
>>>> +       }
>>>>
>>>>          if (connect_func) {
>>>> -               struct l_dbus_message *message;
>>>> +               watch->pending_get_name_owner =3D true;
>>>>
>>>> -               data->connect_func =3D connect_func;
>>>> +               dbus->driver->filter_ops.get_name_owner(dbus, name);
>>>> +       }
>>>>
>>>> -               message =3D l_dbus_message_new_method_call(dbus,
>>>> -
>>>> DBUS_SERVICE_DBUS,
>>>> -                                                       DBUS_PATH_DBUS,
>>>> -
>>>> L_DBUS_INTERFACE_DBUS,
>>>> -                                                       "GetNameOwner"=
);
>>>> +       return watch->id;
>>>> +}
>>>>
>>>> -               l_dbus_message_set_arguments(message, "s", name);
>>>> +static void service_watch_remove(struct l_idle *idle, void *user_data)
>>>> +{
>>>> +       struct l_dbus *dbus =3D user_data;
>>>> +       struct service_watch_data **watch, *tmp;
>>>>
>>>> -               data->get_name_owner_id =3D
>>>> -                       l_dbus_send_with_reply(dbus, message,
>>>> -
>>>> _dbus1_get_name_owner_reply,
>>>> -                                               data, NULL);
>>>> -       }
>>>> +       l_idle_remove(dbus->service_watch_remove_work);
>>>> +       dbus->service_watch_remove_work =3D NULL;
>>>> +
>>>> +       for (watch =3D &dbus->service_watch_head; *watch;
>>>> +                       watch =3D &(*watch)->next) {
>>>> +               if (!(*watch)->removed)
>>>> +                       continue;
>>>> +
>>>> +               tmp =3D *watch;
>>>> +               *watch =3D tmp->next;
>>>> +
>>>> +               /* Check if this was the first entry for the bus name =
*/
>>>> +               if (l_hashmap_lookup(dbus->services_watched,
>>>> tmp->bus_name) =3D=3D
>>>> +                               tmp) {
>>>> +                       l_hashmap_remove(dbus->services_watched,
>>>> tmp->bus_name);
>>>> +
>>>> +                       if (tmp->next && !strcmp(tmp->bus_name,
>>>> +                                               tmp->next->bus_name))
>>>> +                               l_hashmap_insert(dbus->services_watche=
d,
>>>> +                                               tmp->bus_name,
>>>> tmp->next);
>>>
>>>
>>>
>>> I really wonder if we should just add l_hashmap_find or something here
>>> and
>>> avoid the linked-list on the side.  It feels a bit kludgy to me.
>>> Alternatively, let the user remove the service watch by name instead of
>>> messing with ids.
>>
>>
>> They'd have to also pass the callbacks and/or user_data to make sure
>> we don't remove other watches for the same service.
>>
>> Do you think it would be cleaner if we mapped the service names to
>> individual, normal linked lists instead of having one linked list?  I
>> noticed afterwards that this wouldn't be any worse than what I did
>> here.
>
>
> Yes, I think it would be a bit more readable.
>
>>
>>>
>>>> +               }
>>>>
>>>> -       return l_dbus_register(dbus, _dbus1_signal_dispatcher, data,
>>>> -
>>>> filter_data_destroy);
>>>> +               service_watch_data_free(tmp);
>>>> +       }
>>>>    }
>>>>
>>>>    LIB_EXPORT bool l_dbus_remove_watch(struct l_dbus *dbus, unsigned i=
nt
>>>> id)
>>>>    {
>>>> -       return l_dbus_unregister(dbus, id);
>>>> +       struct service_watch_data *watch;
>>>> +
>>>> +       for (watch =3D dbus->service_watch_head; watch; watch =3D
>>>> watch->next)
>>>> +               if (watch->id =3D=3D id && !watch->removed)
>>>> +                       break;
>>>> +
>>>> +       if (!watch)
>>>> +               return false;
>>>> +
>>>> +       watch->removed =3D true;
>>>
>>>
>>>
>>> Do you also want to make sure that the callbacks are not called by
>>> setting
>>> them to NULL or something?  Otherwise you can remove a watch, and it wi=
ll
>>> still be called due to pending events...
>>
>>
>> name_owner_notify should already skip over entries that have removed =3D=
=3D
>> true.
>
>
> Yep, I see that now.  Nevermind :)
>
>
> Regards,
> -Denis
> _______________________________________________
> ell mailing list
> ell(a)lists.01.org
> https://lists.01.org/mailman/listinfo/ell

--===============2013509380571562581==--

