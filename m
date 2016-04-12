Content-Type: multipart/mixed; boundary="===============2940731487331021391=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 03/12] dbus: Check some more return values when parsing
 messages
Date: Tue, 12 Apr 2016 03:23:39 +0200
Message-ID: <CAOq732+i7zSPfLzMLLQhU+n7rWmkOnK9xyWPu3DKNS2m87h6kA@mail.gmail.com>
In-Reply-To: <570C04ED.5090302@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2940731487331021391==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 11 April 2016 at 22:11, Denis Kenzior <denkenz@gmail.com> wrote:
> On 04/09/2016 11:02 PM, Andrew Zaborowski wrote:
>>
>> Without this we will still segfault on some incoming messages.
>> ---
>>   ell/dbus-kernel.c  |  2 ++
>>   ell/dbus-message.c | 32 +++++++++++++++++++++-----------
>>   2 files changed, 23 insertions(+), 11 deletions(-)
>>
>> diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
>> index 2b41177..09721c2 100644
>> --- a/ell/dbus-kernel.c
>> +++ b/ell/dbus-kernel.c
>> @@ -561,6 +561,8 @@ static int _dbus_kernel_make_message(struct kdbus_msg
>> *kmsg,
>>
>>         *out_message =3D dbus_message_build(header, header_size, body,
>> body_size,
>>                                                 NULL, 0);
>> +       if (!*out_message)
>> +               return -EBADMSG;
>>
>>         if (kmsg->src_id !=3D KDBUS_SRC_ID_KERNEL) {
>>                 sprintf(unique_bus_name, ":1.%llu", kmsg->src_id);
>> diff --git a/ell/dbus-message.c b/ell/dbus-message.c
>> index 6e2831b..92054d1 100644
>> --- a/ell/dbus-message.c
>> +++ b/ell/dbus-message.c
>> @@ -568,16 +568,21 @@ static bool get_header_field_from_iter_valist(stru=
ct
>> l_dbus_message *message,
>>         if (_dbus_message_is_gvariant(message)) {
>>                 uint32_t header_length;
>>
>> -               _gvariant_iter_init(&header, message, "yyyyuuu", NULL,
>> -                                       message->header,
>> message->header_size);
>> +               if (!_gvariant_iter_init(&header, message, "yyyyuuu",
>> NULL,
>> +                                       message->header,
>> message->header_size))
>> +                       return false;
>> +
>>                 if (!message_iter_next_entry(&header, &endian,
>> &message_type,
>>                                                 &flags, &version,
>> &body_length,
>>                                                 &serial, &header_length))
>>                         return false;
>>
>> -               _gvariant_iter_init(&header, message, "a(yv)", NULL,
>> -                                       message->header + 16,
>> header_length);
>> -               _gvariant_iter_enter_array(&header, &array);
>> +               if (!_gvariant_iter_init(&header, message, "a(yv)", NULL,
>> +                                       message->header + 16,
>> header_length))
>> +                       return false;
>> +
>> +               if (!_gvariant_iter_enter_array(&header, &array))
>> +                       return false;
>>         } else {
>>                 _dbus1_iter_init(&header, message, "yyyyuua(yv)", NULL,
>>                                 message->header, message->header_size);
>> @@ -695,8 +700,11 @@ struct l_dbus_message *dbus_message_build(void
>> *header, size_t header_size,
>>
>>         message->sealed =3D true;
>>
>> -       get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE, 'g',
>> -                                               &message->signature);
>> +       if (!get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE, 'g',
>> +                                               &message->signature)) {
>
>
> Don't think you can do that actually.
>
> According to DBus Spec:
> "The signature of the message body. If omitted, it is assumed to be the
> empty signature "" (i.e. the body must be 0-length)."


Good point! This is what made the dbus-properties unit test fail for me.

Best regards

--===============2940731487331021391==--

