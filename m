Content-Type: multipart/mixed; boundary="===============7386641185930074215=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 04/20] dbus: Fix _dbus_kernel_calculate_bloom for multiple
 arguments.
Date: Mon, 14 Mar 2016 23:11:49 +0100
Message-ID: <CAOq732JHOTHzDxX2_Trcae_h5gL=8TQe2C2BRGiCTiC0wpovjw@mail.gmail.com>
In-Reply-To: <56E6EB92.9020305@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7386641185930074215==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

 Hi Denis,

On 14 March 2016 at 17:49, Denis Kenzior <denkenz@gmail.com> wrote:
> Hi Andrew,
>
> On 03/13/2016 10:41 PM, Andrew Zaborowski wrote:
>>
>> It seems that l_dbus_message_iter_get_type can't be used to get the
>> value of a single argument and be called repeatedly, it might crash if
>
>
> Looking at l_dbus_message_iter_get_type, it just returns
> iter->sig_start[iter->sig_pos].  Is there something deeper going on here
> that is not readily apparent?

Sorry, l_dbus_message_iter_get_type is a typo, I wanted to say
message_iter_next_entry here.  This function calls it with a fixed
number of parameters and sooner or later it will receive a message
with more arguments and by my reading will segfault.

>
>> the number and types of call arguments don't match the message arguments.
>> Also try to support the string arguments that come after non-string
>> arguments in the bloom filter.
>
>
> From my reading of systemd code, I didn't think this was possible.  But I
> could be wrong...

I see no problem with the bloom filter containing, say, arg3=3D"hello",
even though arguments 1 and 2 are integers.  I don't know if systemd
supports that but if for example a client adds a match with this kind
of filter, the service must also support that or the signal won't pass
through the filter.

>
>
>> ---
>>   ell/dbus-message.c | 38 ++++++++++++++++++++++++++++----------
>>   1 file changed, 28 insertions(+), 10 deletions(-)
>>
>> diff --git a/ell/dbus-message.c b/ell/dbus-message.c
>> index f223c70..a123a8a 100644
>> --- a/ell/dbus-message.c
>> +++ b/ell/dbus-message.c
>> @@ -1412,9 +1412,12 @@ bool _dbus_kernel_calculate_bloom(struct
>> l_dbus_message *message,
>>         const char *signature;
>>         void *body;
>>         size_t body_size;
>> -       struct l_dbus_message_iter iter;
>> +       struct l_dbus_message_iter iter, tmp;
>>         uint8_t argn;
>>         char buf[256];
>> +       bool (*skip_entry)(struct l_dbus_message_iter *);
>> +       bool (*get_basic)(struct l_dbus_message_iter *, char, void *);
>> +       char type;
>>
>>         /* The string "interface:" suffixed by the interface name */
>>         attr =3D l_dbus_message_get_interface(message);
>> @@ -1458,17 +1461,32 @@ bool _dbus_kernel_calculate_bloom(struct
>> l_dbus_message *message,
>>
>>         body =3D _dbus_message_get_body(message, &body_size);
>>
>> -       if (_dbus_message_is_gvariant(message))
>> -               _gvariant_iter_init(&iter, message, signature, NULL,
>> -                                       body, body_size);
>> -       else
>> +       if (_dbus_message_is_gvariant(message)) {
>> +               if (!_gvariant_iter_init(&iter, message, signature, NULL,
>> +                                               body, body_size))
>> +                       return false;
>> +
>> +               skip_entry =3D _gvariant_iter_skip_entry;
>> +               get_basic =3D _gvariant_iter_next_entry_basic;
>> +       } else {
>>                 _dbus1_iter_init(&iter, message, signature, NULL,
>> -                               body, body_size);
>> +                                       body, body_size);
>> +
>> +               skip_entry =3D _dbus1_iter_skip_entry;
>> +               get_basic =3D _dbus1_iter_next_entry_basic;
>> +       }
>>
>>         argn =3D 0;
>>
>> -       while (*signature =3D=3D 's' || *signature =3D=3D 'o' || *signat=
ure =3D=3D
>> 'g') {
>> -               if (!message_iter_next_entry(&iter, &attr))
>> +       do {
>> +               type =3D l_dbus_message_iter_get_type(&iter);
>> +               if (!strchr("sog", type))
>> +                       goto next;
>> +
>> +               /* Don't let get_basic move iter->pos without moving
>> sig_pos */
>> +               memcpy(&tmp, &iter, sizeof(tmp));
>> +
>> +               if (!get_basic(&tmp, type, &attr))
>>                         return false;
>
>
> Is this to avoid double skipping this entry?  Can we find a less hacky way
> to do this?  Perhaps peek_basic, or restructure the loop in some way?

The problem is that get_basic moves the data position (iter->pos) but
doesn't move the iter->sig_pos, as fas as I can see.  Maybe instead we
should just do iter->sig_pos +=3D 1, similarly to what
message_iter_next_entry_valist does?

Best regards

--===============7386641185930074215==--

