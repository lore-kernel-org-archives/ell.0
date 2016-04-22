Content-Type: multipart/mixed; boundary="===============5683260101857691177=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/2] dbus: Add private _dbus_message_new_error
Date: Fri, 22 Apr 2016 02:03:58 +0200
Message-ID: <CAOq732+Q6d4TvY-NWMtsLzJzxobnCyPDyyaQDmyS3KmEqH6=dQ@mail.gmail.com>
In-Reply-To: <571599FD.8050407@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5683260101857691177==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 19 April 2016 at 04:37, Denis Kenzior <denkenz@gmail.com> wrote:
> On 04/18/2016 09:31 AM, Andrew Zaborowski wrote:
>>
>> ---
>>   ell/dbus-message.c | 47 +++++++++++++++++++++++++++++++----------------
>>   ell/dbus-private.h |  5 +++++
>>   2 files changed, 36 insertions(+), 16 deletions(-)
>>
>> diff --git a/ell/dbus-message.c b/ell/dbus-message.c
>> index a409e53..86cec96 100644
>> --- a/ell/dbus-message.c
>> +++ b/ell/dbus-message.c
>> @@ -328,33 +328,32 @@ LIB_EXPORT struct l_dbus_message
>> *l_dbus_message_new_method_return(
>>         return message;
>>   }
>>
>> -LIB_EXPORT struct l_dbus_message *l_dbus_message_new_error_valist(
>> -                                       struct l_dbus_message
>> *method_call,
>> -                                       const char *name,
>> -                                       const char *format, va_list args)
>> +struct l_dbus_message *_dbus_message_new_error(uint8_t version,
>> +                                               uint32_t reply_serial,
>> +                                               const char *destination,
>> +                                               const char *name,
>> +                                               const char *error)
>>   {
>> -       char str[1024];
>>         struct l_dbus_message *reply;
>> -       struct dbus_header *hdr =3D method_call->header;
>> -       const char *sender;
>> +       bool r;
>>
>>         if (!_dbus_valid_interface(name))
>>                 return NULL;
>>
>> -       vsnprintf(str, sizeof(str), format, args);
>>         reply =3D message_new_common(DBUS_MESSAGE_TYPE_ERROR,
>>
>> DBUS_MESSAGE_FLAG_NO_REPLY_EXPECTED,
>> -                                       hdr->version);
>> -
>> -       reply->reply_serial =3D _dbus_message_get_serial(method_call);
>> -
>> -       sender =3D l_dbus_message_get_sender(method_call);
>> -       if (sender)
>> -               reply->destination =3D l_strdup(sender);
>> +                                       version);
>>
>>         reply->error_name =3D l_strdup(name);
>> +       reply->destination =3D l_strdup(destination);
>> +       reply->reply_serial =3D reply_serial;
>>
>> -       if (!l_dbus_message_set_arguments(reply, "s", str)) {
>> +       if (error)
>> +               r =3D l_dbus_message_set_arguments(reply, "s", error);
>> +       else
>> +               r =3D l_dbus_message_set_arguments(reply, "");
>
>
> Under what circumstances would we want to create an error without at leas=
t a
> single string argument?

I don't know but didn't want to exclude that possibility since it's
legal.  Let me remove the check.

Best regards

--===============5683260101857691177==--

