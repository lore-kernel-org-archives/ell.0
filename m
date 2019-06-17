Content-Type: multipart/mixed; boundary="===============2919835217268324786=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCHv4] gpio: add get/set helpers for GPIO lines
Date: Mon, 17 Jun 2019 15:42:24 -0500
Message-ID: <e113f3f8-9fee-d546-5ade-c4d276611f04@gmail.com>
In-Reply-To: <833f6aba-8703-d0e2-54b2-55b6af717ebb@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2919835217268324786==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Martin,

> =

>>> +LIB_EXPORT char *l_gpio_chip_get_line_label(struct l_gpio_chip *chip,
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 uint3=
2_t offset)
>>
>> Is there a particular reason to return char * here?=C2=A0 Why not const =

>> char * and have the caller l_strdup as needed?
> =

> The info object is allocated on the stack, so we cannot return the .name =

> member to the caller.
> =


Sure, but there's no reason why we couldn't make info a static function =

scope variable.  Or use a different static char buffer.  Bet you'll be =

the first one that wishes you didn't need to free the label :)

But anyhow, I went ahead and applied v5.  Lets see if you hate this =

enough (or possibly other aspects) that you will want to tweak the API.

Regards,
-Denis

--===============2919835217268324786==--

