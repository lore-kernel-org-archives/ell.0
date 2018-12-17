Content-Type: multipart/mixed; boundary="===============7368062956564941739=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Mon, 17 Dec 2018 20:27:17 +0100
Message-ID: <58aa7f42-78ca-258c-ac38-281dbef74c5d@geanix.com>
In-Reply-To: <4c3391e7-c256-cda5-e9b4-72b0e5fc9448@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7368062956564941739==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

On 17/12/2018 20.19, Denis Kenzior wrote:
>> struct l_gpio_line *l_gpio_find_line(const char *line_label);
> =

> How does that work?

It does a scandir on /dev/ filtering on "gpiochip" and then traverses =

each line on each found gpiochip - pretty much like libgpiod does:

https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/tree/src/lib/iter=
.c

>> struct l_gpio_chip *l_gpio_line_get_chip(struct l_gpio_line *gpio_line);
> =

> This might be tricky depending on how you setup the tracking =

> relationship between line & chip.

If we put the primary fd in the internal gpio structure, this function =

could create a new struct l_gpio_chip using GPIO_GET_CHIPINFO_IOCTL. But =

I should probably postpone that to later.

>>> So if this is the case, do we even need to worry about reference =

>>> tracking between gpio_chip and gpio_line?
>>>
>>> Perhaps all we need is a gpio_chip_info internal structure that can =

>>> be reference counted and used by gpio_chip and gpio_line.=C2=A0 And =

>>> gpio_chip and gpio_line objects can be destroyed independently of =

>>> each other.
>>
>> Is there generic reference counting functionality in ell?
> =

> No, but ell is not thread safe, so you can just simply use a counter. =

> Some of our classes use __sync_sub_and_fetch, but that is really =

> overkill and pointless.

I started out with this:


static struct l_gpio *gpio_get(struct l_gpio *gpio)
{
         gpio->refcount++;

         return gpio;
}

static void gpio_put(struct l_gpio *gpio)
{
         if (--gpio->refcount =3D=3D 0)
                 l_free(gpio);
}

>> How much of the kernel API do we want to expose? Limiting ourselves to =

>> setting/getting a single gpio-line at the time is clearly the =

>> simplest, but I wonder how long it will be before someone requests =

>> support for handling multiple lines with a single structure (as is =

>> possible with the gpiohandle_request structure in the kernel API).
> =

> I think the immediate goal is to get enough into ell so that you can =

> work on your oFono bits.=C2=A0 We can then go on from there.

Copy that.

-- =

Kind regards,
Martin Hundeb=C3=B8ll
Embedded Linux Consultant

+45 61 65 54 61
martin(a)geanix.com

Geanix IVS
https://geanix.com
DK39600706

--===============7368062956564941739==--

