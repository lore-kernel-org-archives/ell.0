Content-Type: multipart/mixed; boundary="===============8112368444572240086=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH v2 08/11] dbus: Fix the kdbus message encoding
Date: Wed, 13 Apr 2016 00:10:25 +0200
Message-ID: <CAOq732K6svEyShfP5qziUMyggjDHG_A5tdTqRy32HxOnhX3tjQ@mail.gmail.com>
In-Reply-To: <570D6CCC.4050903@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8112368444572240086==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 12 April 2016 at 23:46, Denis Kenzior <denkenz@gmail.com> wrote:
> On 04/11/2016 08:56 PM, Andrew Zaborowski wrote:
>>
>> Keep sending the message header+padding as a separate
>> KDBUS_ITEM_PAYLOAD_OFF buffer like in DBus-1, the systemd busctl utility
>> also seems to do that.  But fix what we send after the header.
>> ---
>>   ell/dbus-kernel.c  | 17 +++++++++--------
>>   ell/dbus-message.c | 19 +++++++++++++++++++
>>   ell/dbus-private.h |  3 +++
>>   3 files changed, 31 insertions(+), 8 deletions(-)
>>
>> diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
>> index 7797153..da5920f 100644
>> --- a/ell/dbus-kernel.c
>> +++ b/ell/dbus-kernel.c
>> @@ -427,14 +427,15 @@ int _dbus_kernel_send(int fd, size_t bloom_size,
>> uint8_t bloom_n_hash,
>>         item->vec.size =3D header_size;
>>         item =3D KDBUS_ITEM_NEXT(item);
>>
>> -       body =3D _dbus_message_get_body(message, &body_size);
>> -       if (body_size > 0) {
>> -               item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(struct
>> kdbus_vec);
>> -               item->type =3D KDBUS_ITEM_PAYLOAD_VEC;
>> -               item->vec.address =3D (uintptr_t) body;
>> -               item->vec.size =3D body_size;
>> -               item =3D KDBUS_ITEM_NEXT(item);
>> -       }
>> +       _dbus_message_build_contents(message, NULL, &body_size);
>> +       body =3D alloca(body_size);
>
>
> This will fail badly somewhere around body_size >=3D 64k, depending on the
> platform.  Why can't we write the contents directly like we used to?

Hmm true.  But the body is now enclosed in a variant, so what buffer
do you suggest to write that into and assign to item->ver.address?

Best regards

--===============8112368444572240086==--

