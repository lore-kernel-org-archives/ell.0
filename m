Content-Type: multipart/mixed; boundary="===============5285852287520321149=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/8] dbus: Rewrite service/disconnect watch APIs on top of
 filter API
Date: Sat, 26 Mar 2016 17:18:38 -0500
Message-ID: <56F70ABE.2090301@gmail.com>
In-Reply-To: <CAOq732K46EEX7UX3kA=JXuZn9ZbPJqOCNnBTsorDvbbeHXa7Lw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5285852287520321149==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/26/2016 10:50 AM, Andrzej Zaborowski wrote:
>   in the cur would Hi Denis,
>
> On 26 March 2016 at 04:01, Denis Kenzior <denkenz@gmail.com> wrote:
>> On 03/25/2016 07:06 PM, Andrzej Zaborowski wrote:
>>> On 25 March 2016 at 03:55, Denis Kenzior <denkenz@gmail.com> wrote:
>>>> On 03/23/2016 09:07 PM, Andrew Zaborowski wrote:
>>>>>
>>>>> @@ -363,6 +379,35 @@ static void bus_ready(struct l_dbus *dbus)
>>>>>           l_io_set_write_handler(dbus->io, message_write_handler, dbu=
s,
>>>>> NULL);
>>>>>     }
>>>>>
>>>>> +static void name_owner_notify(struct l_dbus *dbus, const char *name,
>>>>> +                               const char *old, const char *new)
>>>>> +{
>>>>> +       struct service_watch_data *watch;
>>>>> +       bool connect =3D old && new && !*old && *new;
>>>>> +       bool disconnect =3D old && new && *old && !*new;
>>>>
>>>>
>>>>
>>>> This makes my brain hurt.  I also don't think this works properly.  Ha=
lf
>>>> the
>>>> functions call name_owner_notify with empty strings and the other half
>>>> calls
>>>> it with NULLs.
>>>>
>>>> The disconnect can be expressed much simpler as *new =3D=3D '\0'.
>>>
>>>
>>> Disconnects yes, the NULLs are a different case where we don't know
>>> the old value.  We can't do *old =3D=3D '\0' without checking that it
>>> isn't NULL.
>>>
>>> But, I can change this function's signature to be something like void
>>> name_owner_notify(dbus, const char *name, bool connect, bool
>>> disconnect, const char *owner)
>>>
>>
>> Nah, the signature is fine.  I think you need to make the flow a bit
>> simpler.  The current logic listens to NameOwnerChanged and also queues =
up
>> the GetNameOwner call.  If the NameOwnerChanged signal wins the race,
>> GetNameOwner call is canceled, connect is called.  If GetNameOwner retur=
ns
>> first, connect is called and subsequent NameOwnerChanged (if it arrives =
at
>> all) doesn't do anything.
>
> Yep, that's also what I think this patch does, I'm not sure if you're
> saying there's any issue here.  We don't cancel the GetnameOnwer
> though.

I'm just wondering why we aren't doing the same thing in the new world =

order?  Canceling GetNameOwner calls would make things much simpler.

>
>>
>> You try to do something similar with pending_get_name_owner flag.  So le=
ts
>> use it to our advantage...
>
> pending_get_name_owner is necessary to implement the logic above
> because if the watch has just been added (flag is true), we have to
> call connect regardless of whether the service has just popped up or
> has already existed.  If the flag is false, we only call connect if
> the service had been disconnected before.
>
>>
>>>>
>>>>
>>>>> +
>>>>> +       _dbus_filter_name_owner_notify(dbus->filter, name, new);
>>>>> +
>>>>> +       watch =3D l_hashmap_lookup(dbus->services_watched, name);
>>>>> +
>>>>> +       while (watch && !strcmp(watch->bus_name, name)) {
>>>>> +               if (watch->removed)
>>>>> +                       goto next;
>>>>> +
>>>>> +               if (watch->pending_get_name_owner) {
>>>>> +                       watch->pending_get_name_owner =3D false;
>>>>> +                       if (new && *new)
>>>>> +                               watch->connect_func(dbus,
>>>>> watch->user_data);
>>
>>
>> In case new is non-null, reset pending_get_name_owner to false and call
>> connect.
>
> We have to additionally check that either the service had been
> disconneted until now (old was empty) or pending_get_name_owner is
> true.
>

So I think the real issue is that you're trying to take care of two =

unrelated code-flows (that perform similar operations) which makes =

things pretty hard to understand.  I'd be in favor of not hi-jacking the =

filtering operations for service watch things.  Keep the two path flows =

separate.

And then we should probably add a proper WellKnownName -> UniqueName =

cache abstraction, so that we avoid GetNameOwner calls all over the place.

>>
>>>>> +               } else if (connect && watch->connect_func)
>>>>> +                       watch->connect_func(dbus, watch->user_data);
>>>>> +               else if (disconnect && watch->disconnect_func)
>>>>> +                       watch->disconnect_func(dbus, watch->user_data=
);
>>>>> +
>>>>> +next:
>>>>> +               watch =3D watch->next;
>>>>> +       }
>>>>> +}
>>>>> +
>>>>>     static void hello_callback(struct l_dbus_message *message, void
>>>>> *user_data)
>>>>>     {
>>>>>           struct l_dbus *dbus =3D user_data;
>>>>> @@ -752,7 +797,7 @@ static void get_name_owner_reply_cb(struct
>>>>> l_dbus_message *reply,
>>>>>           if (!l_dbus_message_get_arguments(req->message, "s", &name))
>>>>>                   return;
>>>>>
>>>>> -       _dbus_filter_name_owner_notify(req->dbus->filter, name, owner=
);
>>>>> +       name_owner_notify(req->dbus, name, NULL, owner);
>>
>>
>> Then here, if pending_get_name_owner is false, simply return.
>> get_name_owner_reply lost the race.
>
> We don't itereate over all the watches here.  We could do that but I
> wanted to extract the common driver-independent logic out to a common
> function, name_owner_notify.

Which would iterate anyway, but fair point.

>
>>
>> Otherwise, just call with "" instead of NULL and simplify your life in
>> name_owner_notify.
>
> But then again there may be watches for the same name that should not
> have their "connect" called, so we still need some way to convey that.
> Besides that "simplification" removes a single NULL check at a cost of
> triplicated code.
>
>>
>>>>
>>>>
>>>> should this use "" instead of NULL?
>>>
>>>
>>> If we pass "" then name_owner_notify will have to assume this is a new
>>> connection and will issue spurious connect calls.  The NULL here says
>>> to not treat this as new connection or disconnection.
>>>
>>
>> And by the way, we might want to handle the case where a service name is
>> changed from one unique name to another.  E.g. due to RequestName being
>> queued or DBUS_NAME_FLAG_REPLACE_EXISTING somehow succeeding so that the
>> name is passed from one service to another.
>>
>> For our purposes, calling disconnect and then immediately calling connect
>> would probably be okay for now.
>
> Ah again good point, I'll add this.
>
>>
>>
>>>>
>>>>>     }
>>>>>
>>>>>     static bool classic_get_name_owner(struct l_dbus *bus, const char
>>>>> *name)
>>>>> @@ -800,7 +845,7 @@ static void name_owner_changed_cb(struct
>>>>> l_dbus_message *message,
>>>>>           if (!l_dbus_message_get_arguments(message, "sss", &name, &o=
ld,
>>>>> &new))
>>>>>                   return;
>>>>>
>>>>> -       _dbus_filter_name_owner_notify(dbus->filter, name, new);
>>>>> +       name_owner_notify(dbus, name, old, new);
>>>>>     }
>>>>>
>>>>>     static struct l_dbus *setup_dbus1(int fd, const char *guid)
>>>>> @@ -1000,15 +1045,22 @@ static void kdbus_name_owner_change_func(const
>>>>> char *name, uint64_t old_owner,
>>>>>                                                   void *user_data)
>>>>>     {
>>>>>           struct kdbus_message_recv_data *recv_data =3D user_data;
>>>>> -       char owner[32];
>>>>> +       char old[32], new[32];
>>>>>
>>>>>           l_util_debug(recv_data->dbus->debug_handler,
>>>>>                           recv_data->dbus->debug_data,
>>>>>                           "Read KDBUS Name Owner Change notification"=
);
>>>>>
>>>>> -       snprintf(owner, sizeof(owner), ":1.%" PRIu64, new_owner);
>>>>> +       if (old_owner)
>>>>> +               snprintf(old, sizeof(old), ":1.%" PRIu64, new_owner);
>>>>
>>>>
>>>>
>>>> old_owner here, not new_owner?
>>>
>>>
>>> Yes, thanks for catching this.
>>>
>>>>
>>>>> +       else
>>>>> +               *old =3D '\0';
>>>>> +       if (new_owner)
>>>>> +               snprintf(new, sizeof(new), ":1.%" PRIu64, new_owner);
>>>>> +       else
>>>>> +               *new =3D '\0';
>>>>>
>>>>> -       _dbus_filter_name_owner_notify(recv_data->dbus->filter, name,
>>>>> owner);
>>>>> +       name_owner_notify(recv_data->dbus, name, old, new);
>>>>>     }
>>>>>
>>>>>     static struct l_dbus_message *kdbus_recv_message(struct l_dbus *d=
bus)
>>>>> @@ -1070,15 +1122,13 @@ static bool kdbus_get_name_owner(struct l_dbus
>>>>> *dbus, const char *name)
>>>>>           char owner[32];
>>>>>
>>>>>           owner_id =3D _dbus_kernel_get_name_owner(fd, kdbus->kdbus_p=
ool,
>>>>> name);
>>>>> -       if (!owner_id) {
>>>>> -               l_util_debug(dbus->debug_handler,
>>>>> -                               dbus->debug_data, "Error getting name
>>>>> owner");
>>>>> -               return false;
>>>>> -       }
>>>>>
>>>>> -       snprintf(owner, sizeof(owner), ":1.%" PRIu64, owner_id);
>>>>> +       if (owner_id)
>>>>> +               snprintf(owner, sizeof(owner), ":1.%" PRIu64, owner_i=
d);
>>>>> +       else
>>>>> +               *owner =3D '\0';
>>>>>
>>>>> -       _dbus_filter_name_owner_notify(dbus->filter, name, owner);
>>>>> +       name_owner_notify(dbus, name, NULL, owner);
>>>>
>>>>
>>>>
>>>> "" instead of NULL?
>>>>
>>
>> With kdbus you don't even have a race, so using "" should be safe, no?
>
> Well, name_owner_notify in the current form may call connect for other
> watches for the same service.  We'd have to call the connect callback
> right from this function and reset pending_get_name_owner.  I
> personally like to keep the whole logic contained in name_owner_notify
> and not have the driver functions do the work, but I could do that.

Why not just do the _dbus_kernel_get_name_owner thing right away for =

kdbus transports?  I think this goes along with what I'm saying above =

about keeping the two paths separate.

>>
>>
>>>>
>>>>>
>>>>>           return true;
>>>>>     }

Regards,
-Denis

--===============5285852287520321149==--

