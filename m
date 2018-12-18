Content-Type: multipart/mixed; boundary="===============3687499363455349292=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Tue, 18 Dec 2018 20:03:17 +0100
Message-ID: <E2EE5281-71F9-4455-8313-568B7D30A604@holtmann.org>
In-Reply-To: <f835d758-f12d-96c3-fab6-dc79c0afae6f@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3687499363455349292==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Martin,

>>> The device tree can configure labels for each line that one can read/co=
mpare using GPIO_GET_LINEINFO_IOCTL. If that is not the case, one would hav=
e to either read the docs (often the schematic) or do trial'n'error.
>>> =

>> Okay, so I'm guessing we might need to expose this in the future somehow.
> =

> I have these in my dirty tree now:
> =

> =

> struct l_gpio_line *l_gpio_chip_get_line(struct l_gpio_chip *gpio_chip,
>                                         uint32_t line_num);
> =

> struct l_gpio_line *l_gpio_chip_find_line(struct l_gpio_chip *gpio_chip,
>                                          const char *line_label);
> =

> struct l_gpio_line *l_gpio_find_line(const char *line_label);
> =

> struct l_gpio_chip *l_gpio_line_get_chip(struct l_gpio_line *gpio_line);
> =

> const char *l_gpio_line_get_label(struct l_gpio_line *line);
> =

> =

> They are WIP, though.

so I am not 100% sure this is useful since it adds a complexity that most l=
ike is never going to be used. What I would first check is what happens whe=
n the underlying physical device goes away. Does the l_gpio_chip fd gets a =
HUP signal. Since we might really need to allow for disconnect callback her=
e.

I am fine with the lines being address with the uint32 index number. Creati=
ng a struct for it seems kinda useless since you will always need special k=
nowledge to some degree anyway. I rather have l_gpio_chip_find_line that ta=
kes a line label and tries to find it. Especially with the background you m=
ight need to set more than one GPIO at once, then the line concept blows up.

>>>> You have the main /dev/chip file descriptor and you have a file descri=
ptor returned from the GPIO_GET_LINEHANDLE_IOCTL.  What happens to the fds =
returned by GPIO_GET_LINEHANDLE_IOCTL if the main /dev/chip fd is closed?
>>> =

>>> The virtual fds from GPIO_GET_LINEHANDLE_IOCTL stays valid after closin=
g the /dev/gpiochipX fd. (So I should probably close those virtual fds afte=
r getting/setting the values.)
>> So if this is the case, do we even need to worry about reference trackin=
g between gpio_chip and gpio_line?
>> Perhaps all we need is a gpio_chip_info internal structure that can be r=
eference counted and used by gpio_chip and gpio_line.  And gpio_chip and gp=
io_line objects can be destroyed independently of each other.
> =

> Is there generic reference counting functionality in ell?
> =

> How much of the kernel API do we want to expose? Limiting ourselves to se=
tting/getting a single gpio-line at the time is clearly the simplest, but I=
 wonder how long it will be before someone requests support for handling mu=
ltiple lines with a single structure (as is possible with the gpiohandle_re=
quest structure in the kernel API).
> =

>>>> There's no hotplug/unplug with gpio devices right?  So you can count o=
f the /dev/chip & fd to be owned exlusively by the ell client?
>>> =

>>> You can get USB gpio expanders:
>>> http://nanorivertech.com/viperboard.html
>>> So I guess /dev/gpiochipX nodes can come and go.
>> Probably out of scope for this simple API, just curious: how do we detec=
t that? udev?
> =

> It sound like a job for udev, yes.

If the HUP is actually signaled on the /dev/gpiochipX fd, then I would igno=
re udev. And instead add a helper to find a given l_gpio_chip_new_from_name=
() that then would walk either /dev/ (with scandir like libgpiod does) or b=
y going through sysfs. I would prefer sysfs since it will be mostly part of=
 a bus or class.

> =

>>> =

>>> Multiple processes can use the same gpiochip, but only one process can =
request a line handle.
>> How do you define 'use the same gpiochip'?
> =

> Opening e.g. /dev/gpiochip0 can happen in parallel, but requesting a hand=
le/virtual fd to gpioline0 on gpiochip0 is serialized.

I would just allow opening /dev/gpiochipX multiple times. I think there is =
not need for ELL to multiplex here.

For one-shot triggers we could do a l_gpio_set(const char *chipname, const =
char *linename) that then will try to find the chip and line by name and to=
ggle it.

Regards

Marcel


--===============3687499363455349292==--

