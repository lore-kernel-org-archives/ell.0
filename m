Content-Type: multipart/mixed; boundary="===============0967001507851399644=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: Re: [PATCHv4] gpio: add get/set helpers for GPIO lines
Date: Mon, 17 Jun 2019 23:01:18 +0200
Message-ID: <76a4c8bc-889b-350b-0264-6b7ce02ce0c5@geanix.com>
In-Reply-To: <e113f3f8-9fee-d546-5ade-c4d276611f04@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0967001507851399644==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 17/06/2019 22.42, Denis Kenzior wrote:
>>>> +LIB_EXPORT char *l_gpio_chip_get_line_label(struct l_gpio_chip *chip,
>>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 uint3=
2_t offset)
>>>
>>> Is there a particular reason to return char * here?=C2=A0 Why not const =

>>> char * and have the caller l_strdup as needed?
>>
>> The info object is allocated on the stack, so we cannot return the =

>> .name member to the caller.
>>
> =

> Sure, but there's no reason why we couldn't make info a static function =

> scope variable.=C2=A0 Or use a different static char buffer.=C2=A0 Bet yo=
u'll be =

> the first one that wishes you didn't need to free the label :)

I briefly considered caching the labels in a hashmap in struct =

l_gpiochip, but I deemed it too clumsy :)

// Martin



--===============0967001507851399644==--

