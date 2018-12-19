Content-Type: multipart/mixed; boundary="===============8373030365573057229=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Wed, 19 Dec 2018 15:37:44 +0100
Message-ID: <449A0989-3CFF-4EB4-8A43-0FB3DE5AB310@holtmann.org>
In-Reply-To: <784eee4a-5745-42b0-6295-49ba09e55479@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8373030365573057229==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Martin,

>>> I have these in my dirty tree now:
>>> =

>>> =

>>> struct l_gpio_line *l_gpio_chip_get_line(struct l_gpio_chip *gpio_chip,
>>>                                         uint32_t line_num);
>>> =

>>> struct l_gpio_line *l_gpio_chip_find_line(struct l_gpio_chip *gpio_chip,
>>>                                          const char *line_label);
>>> =

>>> struct l_gpio_line *l_gpio_find_line(const char *line_label);
>>> =

>>> struct l_gpio_chip *l_gpio_line_get_chip(struct l_gpio_line *gpio_line);
>>> =

>>> const char *l_gpio_line_get_label(struct l_gpio_line *line);
>>> =

>>> =

>>> They are WIP, though.
>> so I am not 100% sure this is useful since it adds a complexity that mos=
t like is never going to be used. What I would first check is what happens =
when the underlying physical device goes away. Does the l_gpio_chip fd gets=
 a HUP signal. Since we might really need to allow for disconnect callback =
here.
> =

> I assume you mean POLLHUP here? If that's the case, then no: I don't get =
a POLLHUP event when removing an open gpiochip device.

why not? Can we fix that in the kernel. It is silly to have a stale fd arou=
nd that can signal that is is dead.

>> I am fine with the lines being address with the uint32 index number. Cre=
ating a struct for it seems kinda useless since you will always need specia=
l knowledge to some degree anyway. I rather have l_gpio_chip_find_line that=
 takes a line label and tries to find it. Especially with the background yo=
u might need to set more than one GPIO at once, then the line concept blows=
 up.
> =

> Yes, the one-struct-per-line approach doesn't really scale to handling mu=
ltiple lines in a single ioctl(). Now that I think about it, a single struc=
ture (and a convenient way to set it up) might be all we need. Something li=
ke:
> =

> uint32_t lines[] =3D {0, 4, 8};
> char *labels[] =3D {"3v3", "reset", "led", NULL};
> bool values[] =3D {true, true, false};
> =

> struct l_gpio *gpio;
> =

> gpio =3D l_gpio_new("/dev/gpiochip0");
> l_gpio_lines_by_num(gpio, lines, L_ARRAY_SIZE(lines), L_GPIO_OUT);
> l_gpio_set_values(gpio, values);
> l_gpio_free(gpio);
> =

> gpio =3D l_gpio_new("/dev/gpiochip0");
> l_gpio_lines_by_label(gpio, labels, L_GPIO_IN);
> l_gpio_get_values(gpio, values);
> l_gpio_free(gpio);
> =

> // And maybe a few convenience helpers:
> gpio =3D l_gpio_new_line_by_num("/dev/gpiochip0", values[1], L_GPIO_IN);
> l_gpio_free(gpio);
> =

> gpio =3D l_gpio_new_line_by_label(labels[1], L_GPIO_OUT);
> l_gpio_free(gpio);
> =

>> If the HUP is actually signaled on the /dev/gpiochipX fd, then I would i=
gnore udev. And instead add a helper to find a given l_gpio_chip_new_from_n=
ame() that then would walk either /dev/ (with scandir like libgpiod does) o=
r by going through sysfs. I would prefer sysfs since it will be mostly part=
 of a bus or class.
> =

> root(a)rpi3:~# ls /sys/bus/gpio/devices/
> gpiochip0  gpiochip1  gpiochip2
> =

> I need some guidance on how that should be done=E2=80=A6

That is just a reading directory operation to get the names and then you ne=
ed to retrieve their /dev/ name. This can still fail if udev start renaming=
 things left and right, but on a system that is not totally broken, this wi=
ll actually work. Since you will get the major/minor numbers of the device =
node from sysfs.

> =

>>> Opening e.g. /dev/gpiochip0 can happen in parallel, but requesting a ha=
ndle/virtual fd to gpioline0 on gpiochip0 is serialized.
>> I would just allow opening /dev/gpiochipX multiple times. I think there =
is not need for ELL to multiplex here.
> =

> I think this is in line with the example usage I proposed above.
> =

>> For one-shot triggers we could do a l_gpio_set(const char *chipname, con=
st char *linename) that then will try to find the chip and line by name and=
 toggle it.
> =

> Do we want to support both numeric and labeled line identifiers?
> =

> l_gpio_{get,set,clear}_by_chip_and_label(const char *chipname, const char=
 *label);
> l_gpio_{get,set,clear}_by_label(const char *label);
> l_gpio_{get,set,clear}_by_num(const char *chipname, uint32_t num);

I think that you always have to give the chipname since somehow you need to=
 find GPIO chip device node. Hoping that all lines have unique names is som=
ething that doesn=E2=80=99t look like a good idea.

Regards

Marcel


--===============8373030365573057229==--

