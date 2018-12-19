Content-Type: multipart/mixed; boundary="===============6160415507622998779=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Wed, 19 Dec 2018 15:28:44 +0100
Message-ID: <784eee4a-5745-42b0-6295-49ba09e55479@geanix.com>
In-Reply-To: <E2EE5281-71F9-4455-8313-568B7D30A604@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6160415507622998779==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

On 18/12/2018 20.03, Marcel Holtmann wrote:
>> I have these in my dirty tree now:
>>
>>
>> struct l_gpio_line *l_gpio_chip_get_line(struct l_gpio_chip *gpio_chip,
>>                                          uint32_t line_num);
>>
>> struct l_gpio_line *l_gpio_chip_find_line(struct l_gpio_chip *gpio_chip,
>>                                           const char *line_label);
>>
>> struct l_gpio_line *l_gpio_find_line(const char *line_label);
>>
>> struct l_gpio_chip *l_gpio_line_get_chip(struct l_gpio_line *gpio_line);
>>
>> const char *l_gpio_line_get_label(struct l_gpio_line *line);
>>
>>
>> They are WIP, though.
> =

> so I am not 100% sure this is useful since it adds a complexity that most=
 like is never going to be used. What I would first check is what happens w=
hen the underlying physical device goes away. Does the l_gpio_chip fd gets =
a HUP signal. Since we might really need to allow for disconnect callback h=
ere.

I assume you mean POLLHUP here? If that's the case, then no: I don't get =

a POLLHUP event when removing an open gpiochip device.

> I am fine with the lines being address with the uint32 index number. Crea=
ting a struct for it seems kinda useless since you will always need special=
 knowledge to some degree anyway. I rather have l_gpio_chip_find_line that =
takes a line label and tries to find it. Especially with the background you=
 might need to set more than one GPIO at once, then the line concept blows =
up.

Yes, the one-struct-per-line approach doesn't really scale to handling =

multiple lines in a single ioctl(). Now that I think about it, a single =

structure (and a convenient way to set it up) might be all we need. =

Something like:

uint32_t lines[] =3D {0, 4, 8};
char *labels[] =3D {"3v3", "reset", "led", NULL};
bool values[] =3D {true, true, false};

struct l_gpio *gpio;

gpio =3D l_gpio_new("/dev/gpiochip0");
l_gpio_lines_by_num(gpio, lines, L_ARRAY_SIZE(lines), L_GPIO_OUT);
l_gpio_set_values(gpio, values);
l_gpio_free(gpio);

gpio =3D l_gpio_new("/dev/gpiochip0");
l_gpio_lines_by_label(gpio, labels, L_GPIO_IN);
l_gpio_get_values(gpio, values);
l_gpio_free(gpio);

// And maybe a few convenience helpers:
gpio =3D l_gpio_new_line_by_num("/dev/gpiochip0", values[1], L_GPIO_IN);
l_gpio_free(gpio);

gpio =3D l_gpio_new_line_by_label(labels[1], L_GPIO_OUT);
l_gpio_free(gpio);

> If the HUP is actually signaled on the /dev/gpiochipX fd, then I would ig=
nore udev. And instead add a helper to find a given l_gpio_chip_new_from_na=
me() that then would walk either /dev/ (with scandir like libgpiod does) or=
 by going through sysfs. I would prefer sysfs since it will be mostly part =
of a bus or class.

root(a)rpi3:~# ls /sys/bus/gpio/devices/
gpiochip0  gpiochip1  gpiochip2

I need some guidance on how that should be done...

>> Opening e.g. /dev/gpiochip0 can happen in parallel, but requesting a han=
dle/virtual fd to gpioline0 on gpiochip0 is serialized.
> =

> I would just allow opening /dev/gpiochipX multiple times. I think there i=
s not need for ELL to multiplex here.

I think this is in line with the example usage I proposed above.

> For one-shot triggers we could do a l_gpio_set(const char *chipname, cons=
t char *linename) that then will try to find the chip and line by name and =
toggle it.

Do we want to support both numeric and labeled line identifiers?

l_gpio_{get,set,clear}_by_chip_and_label(const char *chipname, const =

char *label);
l_gpio_{get,set,clear}_by_label(const char *label);
l_gpio_{get,set,clear}_by_num(const char *chipname, uint32_t num);


// Martin

--===============6160415507622998779==--

