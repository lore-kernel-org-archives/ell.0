Content-Type: multipart/mixed; boundary="===============9221331692083653965=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 15/15] dbus: Don't send replies to messages with no reply
 flag.
Date: Sat, 26 Mar 2016 00:52:27 +0100
Message-ID: <CAOq732L75HvFVN4kFvGXyOxynkSH=91-zFf6=kSuAoJ_hco6TQ@mail.gmail.com>
In-Reply-To: <56F42E23.6090300@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9221331692083653965==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 24 March 2016 at 19:12, Denis Kenzior <denkenz@gmail.com> wrote:
> On 03/21/2016 05:10 PM, Andrew Zaborowski wrote:
>> diff --git a/ell/dbus-message.c b/ell/dbus-message.c
>> index a7c9699..5ecac8d 100644
>> --- a/ell/dbus-message.c
>> +++ b/ell/dbus-message.c
>> @@ -43,6 +43,7 @@
>>
>>   #define DBUS_MESSAGE_FLAG_NO_REPLY_EXPECTED   0x01
>>   #define DBUS_MESSAGE_FLAG_NO_AUTO_START               0x02
>> +#define DBUS_MESSAGE_FLAG_DISCARD              0x04
>
>
> No, you're over-riding the ALLOW_INTERACTIVE_AUTHORIZATION flag.

Oops.

>>
>>
>>   #define DBUS_MESSAGE_FIELD_PATH               1
>>   #define DBUS_MESSAGE_FIELD_INTERFACE  2
>> @@ -185,6 +186,22 @@ LIB_EXPORT bool
>> l_dbus_message_get_no_autostart(struct l_dbus_message *msg)
>>
>>   }
>>
>> +bool _dbus_message_get_discard(struct l_dbus_message *msg)
>> +{
>> +       struct dbus_header *hdr;
>> +
>> +       if (unlikely(!msg))
>> +               return false;
>> +
>> +       hdr =3D msg->header;
>> +
>> +       if (hdr->flags & DBUS_MESSAGE_FLAG_DISCARD)
>> +               return true;
>
>
> No, please don't do it this way.  hdr gets sent over the wire.  We need to
> store this flag locally.  Lets just add
>
> bool discard : 1;
>
> to struct l_dbus_message

Ok.

>
>> +
>> +       return false;
>> +
>
>
> Spurious whitespace
>
>> +}
>> +
>>   static struct l_dbus_message *message_new_common(uint8_t type, uint8_t
>> flags,
>>                                                 uint8_t version)
>>   {
>> @@ -285,10 +302,13 @@ LIB_EXPORT struct l_dbus_message
>> *l_dbus_message_new_method_return(
>>         struct l_dbus_message *message;
>>         struct dbus_header *hdr =3D method_call->header;
>>         const char *sender;
>> +       uint8_t flags =3D DBUS_MESSAGE_FLAG_NO_REPLY_EXPECTED;
>> +
>> +       if (l_dbus_message_get_no_reply(method_call))
>> +               flags |=3D DBUS_MESSAGE_FLAG_DISCARD;
>>
>>         message =3D message_new_common(DBUS_MESSAGE_TYPE_METHOD_RETURN,
>> -
>> DBUS_MESSAGE_FLAG_NO_REPLY_EXPECTED,
>> -                                       hdr->version);
>> +                                       flags, hdr->version);
>
>
> if (l_dbus_message_get_no_reply(method_call))
>         message->discard =3D true;

Ok, I'll fix this and send a new version.

Best regards

--===============9221331692083653965==--

