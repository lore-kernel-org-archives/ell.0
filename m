Content-Type: multipart/mixed; boundary="===============7915319862979946639=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Mon, 17 Dec 2018 20:05:55 +0100
Message-ID: <f835d758-f12d-96c3-fab6-dc79c0afae6f@geanix.com>
In-Reply-To: <5d1ae45e-941d-42e7-34c0-0b39a9ee7976@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7915319862979946639==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 17/12/2018 18.17, Denis Kenzior wrote:
>> The device tree can configure labels for each line that one can =

>> read/compare using GPIO_GET_LINEINFO_IOCTL. If that is not the case, =

>> one would have to either read the docs (often the schematic) or do =

>> trial'n'error.
>>
> =

> Okay, so I'm guessing we might need to expose this in the future somehow.

I have these in my dirty tree now:


struct l_gpio_line *l_gpio_chip_get_line(struct l_gpio_chip *gpio_chip,
                                          uint32_t line_num);

struct l_gpio_line *l_gpio_chip_find_line(struct l_gpio_chip *gpio_chip,
                                           const char *line_label);

struct l_gpio_line *l_gpio_find_line(const char *line_label);

struct l_gpio_chip *l_gpio_line_get_chip(struct l_gpio_line *gpio_line);

const char *l_gpio_line_get_label(struct l_gpio_line *line);


They are WIP, though.

>>> You have the main /dev/chip file descriptor and you have a file =

>>> descriptor returned from the GPIO_GET_LINEHANDLE_IOCTL.=C2=A0 What happ=
ens =

>>> to the fds returned by GPIO_GET_LINEHANDLE_IOCTL if the main =

>>> /dev/chip fd is closed?
>>
>> The virtual fds from GPIO_GET_LINEHANDLE_IOCTL stays valid after =

>> closing the /dev/gpiochipX fd. (So I should probably close those =

>> virtual fds after getting/setting the values.)
> =

> So if this is the case, do we even need to worry about reference =

> tracking between gpio_chip and gpio_line?
> =

> Perhaps all we need is a gpio_chip_info internal structure that can be =

> reference counted and used by gpio_chip and gpio_line.=C2=A0 And gpio_chi=
p =

> and gpio_line objects can be destroyed independently of each other.

Is there generic reference counting functionality in ell?

How much of the kernel API do we want to expose? Limiting ourselves to =

setting/getting a single gpio-line at the time is clearly the simplest, =

but I wonder how long it will be before someone requests support for =

handling multiple lines with a single structure (as is possible with the =

gpiohandle_request structure in the kernel API).

>>> There's no hotplug/unplug with gpio devices right?=C2=A0 So you can cou=
nt =

>>> of the /dev/chip & fd to be owned exlusively by the ell client?
>>
>> You can get USB gpio expanders:
>> http://nanorivertech.com/viperboard.html
>> So I guess /dev/gpiochipX nodes can come and go.
> =

> Probably out of scope for this simple API, just curious: how do we =

> detect that? udev?

It sound like a job for udev, yes.

>>
>> Multiple processes can use the same gpiochip, but only one process can =

>> request a line handle.
> =

> How do you define 'use the same gpiochip'?

Opening e.g. /dev/gpiochip0 can happen in parallel, but requesting a =

handle/virtual fd to gpioline0 on gpiochip0 is serialized.


-- =

Kind regards,
Martin Hundeb=C3=B8ll
Embedded Linux Consultant

+45 61 65 54 61
martin(a)geanix.com

Geanix IVS
https://geanix.com
DK39600706

--===============7915319862979946639==--

