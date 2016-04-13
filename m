Content-Type: multipart/mixed; boundary="===============4632077872152188555=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH v2 08/11] dbus: Fix the kdbus message encoding
Date: Wed, 13 Apr 2016 02:23:41 +0200
Message-ID: <CAOq732+DekrA_XZe05vXM9n6o8pW1sSMj3Py6SGfAR4vnKqbsg@mail.gmail.com>
In-Reply-To: <570D8F62.1080106@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4632077872152188555==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 13 April 2016 at 02:14, Denis Kenzior <denkenz@gmail.com> wrote:
> Hi Andrew,
>
>> But we'll still need a memcpy, unless we use a separate io vector when
>>
>> sending the message to the kdbus FD, but I'd have to check if it
>> doesn't break the splitting rules.
>>
>
> So one thought here would be to add extra space in the beginning of the b=
ody
> used by gvariant builder.  That way we can fill it with the variant conte=
nts
> when we finalize the builder.  We might need to keep an extra book-keeping
> variable, something like body_offset, to know where the body actually
> begins.  It will be always 0 for dbus-1.

This is something we could do.  Actually the variant stuff (the 0 byte
and the signature) and the offset are all at the end so it's easy.

So we could have the gvariant builder fill in the signature when
finalizing the body and another function fill in the offset byte(s).
Perhaps I need to rename _dbus_message_build_contents to something
like _dbus_message_get_post_header or something else to diferentiate
if from _dbus_message_get_body.

Best regards

--===============4632077872152188555==--

