Content-Type: multipart/mixed; boundary="===============7035303311095934948=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Mon, 17 Dec 2018 11:04:42 +0100
Message-ID: <5caee1b5-5240-f2c4-0786-f8b95ca9425e@geanix.com>
In-Reply-To: <0ae81caf-99ef-91c3-8fb7-a673024ba19e@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7035303311095934948==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 14/12/2018 18.18, Denis Kenzior wrote:
>> I am not sure if the l_gpio_chip_{set,get}_line_value() functions are =

>> the right approach.
>>
>> I am working on a (ofono) user for this class, where I need to lookup =

>> a line, and store it in a private data structure. With the l_gpio_chip =

>> + line number approach I need to have two gpio-related members in my =

>> private struct.
>>
> =

> Never worked with GPIOs, so this may be a silly question, but...
> =

> How does one figure out the line number that is needed?=C2=A0 You just ha=
ve =

> to know based on some docs?

The device tree can configure labels for each line that one can =

read/compare using GPIO_GET_LINEINFO_IOCTL. If that is not the case, one =

would have to either read the docs (often the schematic) or do =

trial'n'error.

>> If we instead required callers to first create a l_gpio_chip instance, =

>> and use that to get l_gpio_line instances, then we could store a =

>> reference to the chip in the line instance, which would make it =

>> simpler for users to keep a reference to line.
> =

> Possible, but the question is how does the kernel behave...
> =

>>
>> That creates a new set of problems though, where l_gpio_line instances =

>> can get dangling references to freed l_gpio_chip instances. Maybe a =

>> list of references to "child" lines in l_gpio_chip could be maintained =

>> and freed when freeing the l_gpio_chip "parent".
>>
> =

> You have the main /dev/chip file descriptor and you have a file =

> descriptor returned from the GPIO_GET_LINEHANDLE_IOCTL.=C2=A0 What happen=
s to =

> the fds returned by GPIO_GET_LINEHANDLE_IOCTL if the main /dev/chip fd =

> is closed?

The virtual fds from GPIO_GET_LINEHANDLE_IOCTL stays valid after closing =

the /dev/gpiochipX fd. (So I should probably close those virtual fds =

after getting/setting the values.)

> There's no hotplug/unplug with gpio devices right?=C2=A0 So you can count=
 of =

> the /dev/chip & fd to be owned exlusively by the ell client?

You can get USB gpio expanders:
http://nanorivertech.com/viperboard.html
So I guess /dev/gpiochipX nodes can come and go.

Multiple processes can use the same gpiochip, but only one process can =

request a line handle.

// Martin

--===============7035303311095934948==--

