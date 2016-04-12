Content-Type: multipart/mixed; boundary="===============0199458595546923518=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 08/11] dbus: Fix the kdbus message encoding
Date: Tue, 12 Apr 2016 17:25:27 -0500
Message-ID: <570D75D7.7000704@gmail.com>
In-Reply-To: <CAOq732K6svEyShfP5qziUMyggjDHG_A5tdTqRy32HxOnhX3tjQ@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0199458595546923518==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/12/2016 05:10 PM, Andrzej Zaborowski wrote:
> Hi Denis,
>
> On 12 April 2016 at 23:46, Denis Kenzior <denkenz@gmail.com> wrote:
>> On 04/11/2016 08:56 PM, Andrew Zaborowski wrote:
>>>
>>> Keep sending the message header+padding as a separate
>>> KDBUS_ITEM_PAYLOAD_OFF buffer like in DBus-1, the systemd busctl utility
>>> also seems to do that.  But fix what we send after the header.
>>> ---
>>>    ell/dbus-kernel.c  | 17 +++++++++--------
>>>    ell/dbus-message.c | 19 +++++++++++++++++++
>>>    ell/dbus-private.h |  3 +++
>>>    3 files changed, 31 insertions(+), 8 deletions(-)
>>>
>>> diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
>>> index 7797153..da5920f 100644
>>> --- a/ell/dbus-kernel.c
>>> +++ b/ell/dbus-kernel.c
>>> @@ -427,14 +427,15 @@ int _dbus_kernel_send(int fd, size_t bloom_size,
>>> uint8_t bloom_n_hash,
>>>          item->vec.size =3D header_size;
>>>          item =3D KDBUS_ITEM_NEXT(item);
>>>
>>> -       body =3D _dbus_message_get_body(message, &body_size);
>>> -       if (body_size > 0) {
>>> -               item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(struct
>>> kdbus_vec);
>>> -               item->type =3D KDBUS_ITEM_PAYLOAD_VEC;
>>> -               item->vec.address =3D (uintptr_t) body;
>>> -               item->vec.size =3D body_size;
>>> -               item =3D KDBUS_ITEM_NEXT(item);
>>> -       }
>>> +       _dbus_message_build_contents(message, NULL, &body_size);
>>> +       body =3D alloca(body_size);
>>
>>
>> This will fail badly somewhere around body_size >=3D 64k, depending on t=
he
>> platform.  Why can't we write the contents directly like we used to?
>
> Hmm true.  But the body is now enclosed in a variant, so what buffer
> do you suggest to write that into and assign to item->ver.address?
>

This is actually a nasty issue with kdbus.  As you say, variant must be =

a single type, this is specified in DBus-1 Spec somewhere.  So if we are =

to enclose it in a variant like kdbus wants, then it either needs to be:
1. enclosed in '()'
2. special cased.

You're doing 1, however won't this result in the message signature being =

different depending on the the transport being used?

Can we special case the building of this variant for gvariant based =

messages?  Similar to how we're generating the signature on the fly in =

the builder?

Regards,
-Denis

--===============0199458595546923518==--

