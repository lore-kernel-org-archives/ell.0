Content-Type: multipart/mixed; boundary="===============2188126599203519028=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Thu, 20 Dec 2018 20:45:48 +0100
Message-ID: <291bc8b4-d950-70a7-a41c-1033643905a2@geanix.com>
In-Reply-To: <984bab07-c9c2-eef0-e56b-ba282542d97f@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2188126599203519028==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 20/12/2018 18.51, Denis Kenzior wrote:
> Ah, okay.=C2=A0 I think I get what you're trying to do.=C2=A0 So you want=
 to have =

> something like:
> =

> struct l_gpio *l_gpio_new(const char *file_path, ...);
> =

> Which would open(file_path), and issue GPIO_GET_CHIPINFO_IOCTL and =

> GPIO_GET_LINEINFO_IOCTL to find the right lines, then
> =

> GPIO_GET_LINEHANDLE_IOCTL with GPIOHANDLE_REQUEST_OUTPUT and =

> GPIOHANDLE_REQUEST_INPUT flags set to obtain exclusive rights to the line=
s.
> =

> bool l_gpio_set_values(struct l_gpio *, ...);
> =

> would issue a GPIOHANDLE_SET_LINE_VALUES_IOCTL
> =

> bool l_gpio_get_values(struct l_gpio *, ...);
> =

> would issue a GPIOHANDLE_GET_LINE_VALUES_IOCTL,
> =

> Am I right so far?

Yes, this is pretty much how I have come to imagine it.

> And use it something like:
> =

> struct l_gpio *gpio =3D l_gpio_new("/foo/bar", "3v3", "reset", "led", NUL=
L);
> l_gpio_set_values(gpio, true, true, false);
> l_gpio_get_values(gpio, &foo, &bar, &baz);
> =

> So the only issue I see here is how does one discover the lines for a =

> given chip?=C2=A0 You might still want a l_gpio_chip abstraction to disco=
ver =

> lines / line numbers, no?

How about a "raw" API like:

input_lines =3D l_gpio_lines("/some/chip", L_GPIO_IN, 1, 2, 6, -1);
output_lines =3D l_gpio_lines("/some/chip", L_GPIO_OUT, 1, true, 2, false, =

-1);

Output lines need a default value to set when the kernel changes them =

from high-impedance inputs to outputs. I don't particular like how the =

defaults are set in the above. Feel free to propose something better!

Lookup by label is then available via helpers:

chip_path =3D l_gpio_label_chip("chip-label");
input_lines =3D l_gpio_label_lines(chip_path, L_GPIO_IN, "3v3", "reset", =

"led", NULL);

chip_path =3D l_gpio_chip_with_line_labels("3v3", "reset", "led", NULL);
output_lines =3D l_gpio_label_lines(chip_path, L_GPIO_OUT, "3v3", "reset", =

"led", NULL);

Again, I would like something nicer here.

> Maybe something like:
> =

> chip =3D l_gpio_chip_new("/foo/bar");
> gpio =3D chip.acquire(chip, "3v3", "reset", "led");
> l_gpio_set_values(gpio, ...);
> l_gpio_get_values(gpio, ...);

It all boils down to line handles (and probably line events too, at some =

point). The chip and line info are only important when looking up lines, =

and secondary after that.

// Martin

--===============2188126599203519028==--

