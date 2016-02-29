Content-Type: multipart/mixed; boundary="===============1145256547500398511=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/5] dbus: Coalesce PropertiesChanged signals
Date: Mon, 29 Feb 2016 09:43:49 -0600
Message-ID: <56D46735.5070105@gmail.com>
In-Reply-To: <CAOq732+Ai=m+BVD6xxhip+CezQ8Um8rR5ehkAQVw-=US6bf+Aw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1145256547500398511==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 02/29/2016 03:21 AM, Andrzej Zaborowski wrote:
> Hi Denis,
>
> On 26 February 2016 at 21:30, Denis Kenzior <denkenz@gmail.com> wrote:
>> On 02/17/2016 09:20 PM, Andrew Zaborowski wrote:
>>>          if (!property)
>>>                  return false;
>>>
>>> -       signature =3D property->metainfo + strlen(property->metainfo) +=
 1;
>>> -
>>> -       if (instance->interface->handle_old_style_properties) {
>>> -               signal =3D l_dbus_message_new_signal(dbus, path,
>>> -                                                       interface_name,
>>> -
>>> "PropertyChanged");
>>> +       rec =3D l_queue_find(tree->property_changes,
>>> +                               match_property_changes_instance,
>>> instance);
>>>

The l_queue_find call only takes the instance into consideration, not =

the object pointer.

>>> -               builder =3D l_dbus_message_builder_new(signal);
>>> -
>>> -               l_dbus_message_builder_append_basic(builder, 's',
>>> -                                                       property_name);
>>> -               l_dbus_message_builder_enter_variant(builder, signature=
);
>>
>>
>> This looks a bit suspicious.  Should we be also comparing the object
>> pointer, not just the instance pointer here?
>
> Assuming that only one object can have the instance it shouldn't
> matter.  When the object or the instance are removed, the property
> change record is also removed so it won't accidentally point at a
> different instance.
>
> We also rely on that for the interface added notifications.
>

What about multiple objects with the same interface?

E.g. org.foo.Foobar interface on /bar1 and /bar2.  If Foobar.Baz =

property changes on /bar1 and /bar2.

Alternatively, if Foobar.Baz1 changes on /bar1, and Foobar.Baz2 changes =

on /bar2, you can also get into a weird situation.

Or am I missing something?

Regards,
-Denis


--===============1145256547500398511==--

