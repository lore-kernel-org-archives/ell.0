Content-Type: multipart/mixed; boundary="===============8406053370142502980=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Wed, 19 Dec 2018 18:50:02 +0100
Message-ID: <da19a6cf-8443-f67a-2ac3-187b44ee05e6@geanix.com>
In-Reply-To: <0f4a154d-3977-1d27-bde9-6d28ae83aec3@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8406053370142502980==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 19/12/2018 17.46, Denis Kenzior wrote:
>>>>> so I am not 100% sure this is useful since it adds a complexity =

>>>>> that most like is never going to be used. What I would first check =

>>>>> is what happens when the underlying physical device goes away. Does =

>>>>> the l_gpio_chip fd gets a HUP signal. Since we might really need to =

>>>>> allow for disconnect callback here.
>>>>
>>>> I assume you mean POLLHUP here? If that's the case, then no: I don't =

>>>> get a POLLHUP event when removing an open gpiochip device.
>>>
>>> why not? Can we fix that in the kernel. It is silly to have a stale =

>>> fd around that can signal that is is dead.
>>
>> There is no .poll in the gpio chardev fileops. I can check with Linus =

>> Walleij if he is open to adding it.
> =

> Just a thought, but we can add l_gpio_chip_set_disconnect_watch at a =

> later date, if/when this becomes available.=C2=A0 You don't need this for =

> oFono work right now, right?

No need in my case, no. I'm only using on-soc gpio controllers.

>>>>> I am fine with the lines being address with the uint32 index =

>>>>> number. Creating a struct for it seems kinda useless since you will =

>>>>> always need special knowledge to some degree anyway. I rather have =

>>>>> l_gpio_chip_find_line that takes a line label and tries to find it. =

>>>>> Especially with the background you might need to set more than one =

>>>>> GPIO at once, then the line concept blows up.
>>>>
>>>> Yes, the one-struct-per-line approach doesn't really scale to =

>>>> handling multiple lines in a single ioctl(). Now that I think about =

>>>> it, a single structure (and a convenient way to set it up) might be =

>>>> all we need. Something like:
>>>>
>>>> uint32_t lines[] =3D {0, 4, 8};
>>>> char *labels[] =3D {"3v3", "reset", "led", NULL};
>>>> bool values[] =3D {true, true, false};
>>>>
>>>> struct l_gpio *gpio;
>>>>
>>>> gpio =3D l_gpio_new("/dev/gpiochip0");
>>>> l_gpio_lines_by_num(gpio, lines, L_ARRAY_SIZE(lines), L_GPIO_OUT);
> =

> So this implies some sort of temporary state being kept by l_gpio.=C2=A0 =
Not =

> sure I like that...

GPIO lines are more or less meant to be acquired (hogged in =

kernel-nomenclature) by the controlling process. The reservation is tied =

to the virtual file descriptor, which maps to one or more gpio lines on =

a gpio chip. Closing the virtual fd releases the line(s).

In my previous patches I simply acquired the gpio line while =

setting/getting the value, and then released again before returning.

>>>> l_gpio_set_values(gpio, values);
> =

> Why not use varargs here?=C2=A0 So something like:
> =

> l_gpio_set_by_index(gpio, 0, true, 4, true, 8, false, -1);

I would very much like to use varargs, but we should consider the =

stateful approach explained above.

// Martin

>>>> l_gpio_free(gpio);
>>>>
>>>> gpio =3D l_gpio_new("/dev/gpiochip0");
>>>> l_gpio_lines_by_label(gpio, labels, L_GPIO_IN);
>>>> l_gpio_get_values(gpio, values);
> =

> l_gpio_get_values(gpio, "3v3", &v1, "reset", &v2, "led", &v3, NULL);
> =

>>>> l_gpio_free(gpio);
>>>>
>>>> // And maybe a few convenience helpers:
>>>> gpio =3D l_gpio_new_line_by_num("/dev/gpiochip0", values[1], L_GPIO_IN=
);
>>>> l_gpio_free(gpio);
>>>>
>>>> gpio =3D l_gpio_new_line_by_label(labels[1], L_GPIO_OUT);
>>>> l_gpio_free(gpio);
>>>>
> =

> Regards,
> -Denis

-- =

Kind regards,
Martin Hundeb=C3=B8ll
Embedded Linux Consultant

+45 61 65 54 61
martin(a)geanix.com

Geanix IVS
https://geanix.com
DK39600706

--===============8406053370142502980==--

