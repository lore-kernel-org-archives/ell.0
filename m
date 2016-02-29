Content-Type: multipart/mixed; boundary="===============0159951829466635520=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 2/5] dbus: Coalesce PropertiesChanged signals
Date: Mon, 29 Feb 2016 10:21:39 +0100
Message-ID: <CAOq732+Ai=m+BVD6xxhip+CezQ8Um8rR5ehkAQVw-=US6bf+Aw@mail.gmail.com>
In-Reply-To: <56D0B5D7.8060209@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0159951829466635520==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 26 February 2016 at 21:30, Denis Kenzior <denkenz@gmail.com> wrote:
> On 02/17/2016 09:20 PM, Andrew Zaborowski wrote:
>>         if (!property)
>>                 return false;
>>
>> -       signature =3D property->metainfo + strlen(property->metainfo) + =
1;
>> -
>> -       if (instance->interface->handle_old_style_properties) {
>> -               signal =3D l_dbus_message_new_signal(dbus, path,
>> -                                                       interface_name,
>> -
>> "PropertyChanged");
>> +       rec =3D l_queue_find(tree->property_changes,
>> +                               match_property_changes_instance,
>> instance);
>>
>> -               builder =3D l_dbus_message_builder_new(signal);
>> -
>> -               l_dbus_message_builder_append_basic(builder, 's',
>> -                                                       property_name);
>> -               l_dbus_message_builder_enter_variant(builder, signature);
>
>
> This looks a bit suspicious.  Should we be also comparing the object
> pointer, not just the instance pointer here?

Assuming that only one object can have the instance it shouldn't
matter.  When the object or the instance are removed, the property
change record is also removed so it won't accidentally point at a
different instance.

We also rely on that for the interface added notifications.

Best regards

--===============0159951829466635520==--

