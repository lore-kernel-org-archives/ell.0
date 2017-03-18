Content-Type: multipart/mixed; boundary="===============6367754967597820028=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] dbus: Flush pending object manager signals in send_message
Date: Sat, 18 Mar 2017 18:36:11 +0100
Message-ID: <CAOq732+D4gBVX+CoD7NYaxkc1NtuyRoDcSVobmCd=gYXTBXWFA@mail.gmail.com>
In-Reply-To: <6c5c37b8-4ca1-8ad4-cc35-873dba634069@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6367754967597820028==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 18 March 2017 at 05:05, Denis Kenzior <denkenz@gmail.com> wrote:
> On 03/17/2017 08:30 PM, Andrew Zaborowski wrote:
>>
>> Try to warrant the original ordering of PropertiesChanged and
>> InterfacesAdded/Removed signals in relation to other messages for
>> clients that rely on this ordering.  One case where this may matter
>> is when a method call causes a property value change followed by the
>> method return message in the same main loop iteration as the property
>> change.  In this case the property change would always be seen by
>> dbus after the method return because of the signals being send from
>> an idle callback.  Set a barrier for the object manager signals
>> before queuing other messages like method returns.
>
>
> Does this fix our MFP autotest failure?

It does for me, didn't expect that.

>
>
>> ---
>>  ell/dbus-private.h | 2 ++
>>  ell/dbus-service.c | 8 ++++++++
>>  ell/dbus.c         | 2 ++
>>  3 files changed, 12 insertions(+)
>>
>> diff --git a/ell/dbus-private.h b/ell/dbus-private.h
>> index a4118c6..c22b95a 100644
>> --- a/ell/dbus-private.h
>> +++ b/ell/dbus-private.h
>> @@ -234,6 +234,8 @@ bool _dbus_object_tree_property_changed(struct l_dbus
>> *dbus,
>>                                         const char *interface_name,
>>                                         const char *property_name);
>>
>> +void _dbus_object_tree_signals_flush(struct l_dbus *dbus);
>> +
>>  void _dbus_kernel_bloom_add(uint64_t filter[], size_t size, uint8_t
>> num_hash,
>>                                 const char *prefix, const char *str);
>>  void _dbus_kernel_bloom_add_parents(uint64_t filter[], size_t size,
>> diff --git a/ell/dbus-service.c b/ell/dbus-service.c
>> index 1df8f1b..f54d2dd 100644
>> --- a/ell/dbus-service.c
>> +++ b/ell/dbus-service.c
>> @@ -1101,6 +1101,14 @@ static void schedule_emit_signals(struct l_dbus
>> *dbus)
>>         tree->emit_signals_work =3D l_idle_create(emit_signals, dbus, NU=
LL);
>>  }
>>
>> +void _dbus_object_tree_signals_flush(struct l_dbus *dbus)
>> +{
>> +       struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
>> +
>> +       if (tree->emit_signals_work)
>> +               emit_signals(tree->emit_signals_work, dbus);
>> +}
>> +
>>  static bool match_property_changes_instance(const void *a, const void *=
b)
>>  {
>>         const struct property_change_record *rec =3D a;
>> diff --git a/ell/dbus.c b/ell/dbus.c
>> index ddc51aa..274e4ae 100644
>> --- a/ell/dbus.c
>> +++ b/ell/dbus.c
>> @@ -346,6 +346,8 @@ static uint32_t send_message(struct l_dbus *dbus, bo=
ol
>> priority,
>>                 return callback->serial;
>>         }
>>
>> +       _dbus_object_tree_signals_flush(dbus);
>> +
>
>
> Should this only affect method returns?

Not sure, I thought it would be better to guarantee the ordering on
the dbus socket generally for all messages and not have to worry if
the issue may possibly come back in the future.  I think it should
affect at least method returns, signals and errors, if we want to do
it.  Method calls I'm not sure because services don't make any except
to agents, but it may be worth doing for the agent calls.

>
> Also, this causes (potentially lots) of getter calls to be made.  Would it
> not be better (and safer) to only send the properties for the object which
> is generating the method return?

Again if we do that there will be some situations where the clients
will have to work around issues.  If the getter calls are an issue we
can probably move the other messages to idle callbacks too, relatively
easily.

>
>>         l_queue_push_tail(dbus->message_queue, callback);
>>
>>         if (dbus->is_ready)
>>
>
> I still wonder if something like l_dbus_property_changed_immediate would =
be
> better?

Not sure.  Imagine a situation where an interface is added and it
emits a custom signal in the same cycle.  Due to the coalescing logic
I think we will emit the InterfaceAdded after the signal.  I think we
should try a general fix.

>
> Also, it looks like our property setters generate the method return, then
> generate the property changed.  These are probably okay as they are.  At
> least less critical since the caller should assume the property change has
> occurred, but just thought I'd mention it in case you think they need to =
be
> affected by this change.

Good point, I think we should actually switch the order in
properties_set_complete / set_property_complete if we want to let
clients rely on things like the order of the Scaning change and the
Scan() call.

Best regards

--===============6367754967597820028==--

