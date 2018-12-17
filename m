Content-Type: multipart/mixed; boundary="===============0808670972916371937=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Mon, 17 Dec 2018 13:19:29 -0600
Message-ID: <4c3391e7-c256-cda5-e9b4-72b0e5fc9448@gmail.com>
In-Reply-To: <f835d758-f12d-96c3-fab6-dc79c0afae6f@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0808670972916371937==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Martin,

>> Okay, so I'm guessing we might need to expose this in the future somehow.
> =

> I have these in my dirty tree now:
> =

> =

> struct l_gpio_line *l_gpio_chip_get_line(struct l_gpio_chip *gpio_chip,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 uint32_t line_num);
> =

> struct l_gpio_line *l_gpio_chip_find_line(struct l_gpio_chip *gpio_chip,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 const char *line_label);

Okay, makes sense...

> =

> struct l_gpio_line *l_gpio_find_line(const char *line_label);

How does that work?

> =

> struct l_gpio_chip *l_gpio_line_get_chip(struct l_gpio_line *gpio_line);

This might be tricky depending on how you setup the tracking =

relationship between line & chip.

> =

> const char *l_gpio_line_get_label(struct l_gpio_line *line);
> =


Makes sense..

> =

> They are WIP, though.

Sure, understood.

>> So if this is the case, do we even need to worry about reference =

>> tracking between gpio_chip and gpio_line?
>>
>> Perhaps all we need is a gpio_chip_info internal structure that can be =

>> reference counted and used by gpio_chip and gpio_line.=C2=A0 And gpio_ch=
ip =

>> and gpio_line objects can be destroyed independently of each other.
> =

> Is there generic reference counting functionality in ell?

No, but ell is not thread safe, so you can just simply use a counter. =

Some of our classes use __sync_sub_and_fetch, but that is really =

overkill and pointless.

> =

> How much of the kernel API do we want to expose? Limiting ourselves to =

> setting/getting a single gpio-line at the time is clearly the simplest, =

> but I wonder how long it will be before someone requests support for =

> handling multiple lines with a single structure (as is possible with the =

> gpiohandle_request structure in the kernel API).

I think the immediate goal is to get enough into ell so that you can =

work on your oFono bits.  We can then go on from there.

Regards,
-Denis

--===============0808670972916371937==--

