Content-Type: multipart/mixed; boundary="===============9083259045651054724=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Wed, 19 Dec 2018 13:43:04 -0600
Message-ID: <35ac9913-a4bd-eb44-62ed-943cf0fead8f@gmail.com>
In-Reply-To: <da19a6cf-8443-f67a-2ac3-187b44ee05e6@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9083259045651054724==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Martin,

>>>>>> I am fine with the lines being address with the uint32 index
>>>>>> number. Creating a struct for it seems kinda useless since you =

>>>>>> will always need special knowledge to some degree anyway. I rather =

>>>>>> have l_gpio_chip_find_line that takes a line label and tries to =

>>>>>> find it. Especially with the background you might need to set more =

>>>>>> than one GPIO at once, then the line concept blows up.
>>>>>
>>>>> Yes, the one-struct-per-line approach doesn't really scale to =

>>>>> handling multiple lines in a single ioctl(). Now that I think about =

>>>>> it, a single structure (and a convenient way to set it up) might be =

>>>>> all we need. Something like:
>>>>>
>>>>> uint32_t lines[] =3D {0, 4, 8};
>>>>> char *labels[] =3D {"3v3", "reset", "led", NULL};
>>>>> bool values[] =3D {true, true, false};
>>>>>
>>>>> struct l_gpio *gpio;
>>>>>
>>>>> gpio =3D l_gpio_new("/dev/gpiochip0");
>>>>> l_gpio_lines_by_num(gpio, lines, L_ARRAY_SIZE(lines), L_GPIO_OUT);
>>
>> So this implies some sort of temporary state being kept by l_gpio.  =

>> Not sure I like that...
> =

> GPIO lines are more or less meant to be acquired (hogged in =

> kernel-nomenclature) by the controlling process. The reservation is tied =

> to the virtual file descriptor, which maps to one or more gpio lines on =

> a gpio chip. Closing the virtual fd releases the line(s).
> =

> In my previous patches I simply acquired the gpio line while =

> setting/getting the value, and then released again before returning.

But isn't the intent to do this here as well?  At least on l_gpio level =

it doesn't seem like we should be keeping the virtual fd.  If we want to =

keep that open, then we need a whole new class for that.  One that might =

need to expose l_io or some other way to subscribe to changes on gpio =

lines.  From what I understood this functionality isn't needed yet, so =

it can be added later...

> =

>>>>> l_gpio_set_values(gpio, values);
>>
>> Why not use varargs here?=C2=A0 So something like:
>>
>> l_gpio_set_by_index(gpio, 0, true, 4, true, 8, false, -1);
> =

> I would very much like to use varargs, but we should consider the =

> stateful approach explained above.
> =


That statement seems to be contradictory?  Can you explain?

Regards,
-Denis

--===============9083259045651054724==--

