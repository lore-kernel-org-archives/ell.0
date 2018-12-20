Content-Type: multipart/mixed; boundary="===============0024097771775628471=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Thu, 20 Dec 2018 11:51:18 -0600
Message-ID: <984bab07-c9c2-eef0-e56b-ba282542d97f@gmail.com>
In-Reply-To: <b6757a23-1c19-169e-77f6-dacf7b1d9e1c@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0024097771775628471==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Martin,

>>>> So this implies some sort of temporary state being kept by l_gpio. =

>>>> Not sure I like that...
>>>
>>> GPIO lines are more or less meant to be acquired (hogged in =

>>> kernel-nomenclature) by the controlling process. The reservation is =

>>> tied to the virtual file descriptor, which maps to one or more gpio =

>>> lines on a gpio chip. Closing the virtual fd releases the line(s).
>>>
>>> In my previous patches I simply acquired the gpio line while =

>>> setting/getting the value, and then released again before returning.
>>
>> But isn't the intent to do this here as well?=C2=A0 At least on l_gpio =

>> level it doesn't seem like we should be keeping the virtual fd.
> =

> It was my initial intent to do a simple "open vfd -> set/get value -> =

> close vfd", but as our discussion has evolved, I am more inclined to =

> stick to what the kernel API exposes, and simply tie the l_gpio instance =

> to a single set of gpio-lines. If the user need different sets of lines, =

> he should create multiple l_gpio instances.

Ah, okay.  I think I get what you're trying to do.  So you want to have =

something like:

struct l_gpio *l_gpio_new(const char *file_path, ...);

Which would open(file_path), and issue GPIO_GET_CHIPINFO_IOCTL and =

GPIO_GET_LINEINFO_IOCTL to find the right lines, then

GPIO_GET_LINEHANDLE_IOCTL with GPIOHANDLE_REQUEST_OUTPUT and =

GPIOHANDLE_REQUEST_INPUT flags set to obtain exclusive rights to the lines.

bool l_gpio_set_values(struct l_gpio *, ...);

would issue a GPIOHANDLE_SET_LINE_VALUES_IOCTL

bool l_gpio_get_values(struct l_gpio *, ...);

would issue a GPIOHANDLE_GET_LINE_VALUES_IOCTL,

Am I right so far?

And use it something like:

struct l_gpio *gpio =3D l_gpio_new("/foo/bar", "3v3", "reset", "led", NULL);
l_gpio_set_values(gpio, true, true, false);
l_gpio_get_values(gpio, &foo, &bar, &baz);

So the only issue I see here is how does one discover the lines for a =

given chip?  You might still want a l_gpio_chip abstraction to discover =

lines / line numbers, no?

Maybe something like:

chip =3D l_gpio_chip_new("/foo/bar");
gpio =3D chip.acquire(chip, "3v3", "reset", "led");
l_gpio_set_values(gpio, ...);
l_gpio_get_values(gpio, ...);

Regards,
-Denis

--===============0024097771775628471==--

