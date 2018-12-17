Content-Type: multipart/mixed; boundary="===============1641194809124711644=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Mon, 17 Dec 2018 11:17:15 -0600
Message-ID: <5d1ae45e-941d-42e7-34c0-0b39a9ee7976@gmail.com>
In-Reply-To: <5caee1b5-5240-f2c4-0786-f8b95ca9425e@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1641194809124711644==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Martin,

> The device tree can configure labels for each line that one can =

> read/compare using GPIO_GET_LINEINFO_IOCTL. If that is not the case, one =

> would have to either read the docs (often the schematic) or do =

> trial'n'error.
> =


Okay, so I'm guessing we might need to expose this in the future somehow.

>>
>> You have the main /dev/chip file descriptor and you have a file =

>> descriptor returned from the GPIO_GET_LINEHANDLE_IOCTL.=C2=A0 What happe=
ns =

>> to the fds returned by GPIO_GET_LINEHANDLE_IOCTL if the main /dev/chip =

>> fd is closed?
> =

> The virtual fds from GPIO_GET_LINEHANDLE_IOCTL stays valid after closing =

> the /dev/gpiochipX fd. (So I should probably close those virtual fds =

> after getting/setting the values.)

So if this is the case, do we even need to worry about reference =

tracking between gpio_chip and gpio_line?

Perhaps all we need is a gpio_chip_info internal structure that can be =

reference counted and used by gpio_chip and gpio_line.  And gpio_chip =

and gpio_line objects can be destroyed independently of each other.

> =

>> There's no hotplug/unplug with gpio devices right?=C2=A0 So you can coun=
t =

>> of the /dev/chip & fd to be owned exlusively by the ell client?
> =

> You can get USB gpio expanders:
> http://nanorivertech.com/viperboard.html
> So I guess /dev/gpiochipX nodes can come and go.

Probably out of scope for this simple API, just curious: how do we =

detect that? udev?

> =

> Multiple processes can use the same gpiochip, but only one process can =

> request a line handle.

How do you define 'use the same gpiochip'?

Regards,
-Denis

--===============1641194809124711644==--

