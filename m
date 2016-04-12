Content-Type: multipart/mixed; boundary="===============7058657308178437805=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH v2 05/11] dbus: GVariant message cookie and reply cookie
 are 64-bit
Date: Wed, 13 Apr 2016 00:00:59 +0200
Message-ID: <CAOq732JZ4G7f5xQpCyqyxMFoO7TxGZ=vvitb2TL0-q8aaxxaBQ@mail.gmail.com>
In-Reply-To: <570D661A.5080106@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7058657308178437805==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 12 April 2016 at 23:18, Denis Kenzior <denkenz@gmail.com> wrote:
> On 04/11/2016 08:56 PM, Andrew Zaborowski wrote:
>>
>> They're 64-bit but the systemd docs discourage using the upper 32 bits,
>> so we take advantage of that and only support cookie values that fit 32
>> bits to avoid too big code changes (we use the dbus1 header layout for
>> the cookie storage so we'd have to move the cookie/serial out of that
>> header like we do with sender, path, etc.).  This only tries to fix the
>> parsing and encoding.
>> ---
>>   ell/dbus-message.c | 60
>> ++++++++++++++++++++++++++++++++++++++++++++++--------
>>   1 file changed, 52 insertions(+), 8 deletions(-)
>>
>> diff --git a/ell/dbus-message.c b/ell/dbus-message.c
>> index 964b925..eb47eb3 100644
>> --- a/ell/dbus-message.c
>> +++ b/ell/dbus-message.c
>> @@ -111,13 +111,27 @@ void _dbus_message_set_serial(struct l_dbus_message
>> *msg, uint32_t serial)
>>   {
>>         struct dbus_header *hdr =3D msg->header;
>>
>> -       hdr->serial =3D serial;
>> +       if (_dbus_message_is_gvariant(msg)) {
>> +               if (_dbus_message_get_endian(msg) =3D=3D
>> +                               DBUS_MESSAGE_LITTLE_ENDIAN) {
>> +                       hdr->serial =3D serial;
>> +                       hdr->field_length =3D 0;
>> +               } else {
>> +                       hdr->serial =3D 0;
>> +                       hdr->field_length =3D serial;
>> +               }
>
>
> This looks really complicated.  Can we just add a union to dbus_header
> instead to reflect the new GVariant serialization format?

Ok, I also think that will be cleaner but will need to touch more
places in dbus-message.c to do this change.

Best regards

--===============7058657308178437805==--

