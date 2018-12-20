Content-Type: multipart/mixed; boundary="===============7976450851644059367=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Thu, 20 Dec 2018 09:00:41 +0100
Message-ID: <b6757a23-1c19-169e-77f6-dacf7b1d9e1c@geanix.com>
In-Reply-To: <35ac9913-a4bd-eb44-62ed-943cf0fead8f@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7976450851644059367==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 19/12/2018 20.43, Denis Kenzior wrote:
>>>>>>> I am fine with the lines being address with the uint32 index
>>>>>>> number. Creating a struct for it seems kinda useless since you =

>>>>>>> will always need special knowledge to some degree anyway. I =

>>>>>>> rather have l_gpio_chip_find_line that takes a line label and =

>>>>>>> tries to find it. Especially with the background you might need =

>>>>>>> to set more than one GPIO at once, then the line concept blows up.
>>>>>>
>>>>>> Yes, the one-struct-per-line approach doesn't really scale to =

>>>>>> handling multiple lines in a single ioctl(). Now that I think =

>>>>>> about it, a single structure (and a convenient way to set it up) =

>>>>>> might be all we need. Something like:
>>>>>>
>>>>>> uint32_t lines[] =3D {0, 4, 8};
>>>>>> char *labels[] =3D {"3v3", "reset", "led", NULL};
>>>>>> bool values[] =3D {true, true, false};
>>>>>>
>>>>>> struct l_gpio *gpio;
>>>>>>
>>>>>> gpio =3D l_gpio_new("/dev/gpiochip0");
>>>>>> l_gpio_lines_by_num(gpio, lines, L_ARRAY_SIZE(lines), L_GPIO_OUT);
>>>
>>> So this implies some sort of temporary state being kept by l_gpio. =

>>> Not sure I like that...
>>
>> GPIO lines are more or less meant to be acquired (hogged in =

>> kernel-nomenclature) by the controlling process. The reservation is =

>> tied to the virtual file descriptor, which maps to one or more gpio =

>> lines on a gpio chip. Closing the virtual fd releases the line(s).
>>
>> In my previous patches I simply acquired the gpio line while =

>> setting/getting the value, and then released again before returning.
> =

> But isn't the intent to do this here as well?=C2=A0 At least on l_gpio le=
vel =

> it doesn't seem like we should be keeping the virtual fd.

It was my initial intent to do a simple "open vfd -> set/get value -> =

close vfd", but as our discussion has evolved, I am more inclined to =

stick to what the kernel API exposes, and simply tie the l_gpio instance =

to a single set of gpio-lines. If the user need different sets of lines, =

he should create multiple l_gpio instances.

> If we want to =

> keep that open, then we need a whole new class for that.=C2=A0 One that m=
ight =

> need to expose l_io or some other way to subscribe to changes on gpio =

> lines.=C2=A0 From what I understood this functionality isn't needed yet, =
so =

> it can be added later...

The kernel API don't signal any changes on either the gpiochip fd or the =

gpiohandle fd. Changes on gpio-lines are exposed through a gpioevent =

virtual fd that is acquired using GPIO_GET_LINEEVENT_IOCTL.

It implements .poll() to signal changes and .read() to supply details =

about those changes, so users can use l_io to monitor it for events.

gpioevents are mutual exclusive to gpiohandles, so one cannot acquire a =

line for gpioevent if it is already acquired as a gpiohandle, and =

vice-versa. That might require two distinct classes to handle?

This event handling is of course not needed right now, but we should =

consider it when designing the get/set interface.

>>
>>>>>> l_gpio_set_values(gpio, values);
>>>
>>> Why not use varargs here?=C2=A0 So something like:
>>>
>>> l_gpio_set_by_index(gpio, 0, true, 4, true, 8, false, -1);
>>
>> I would very much like to use varargs, but we should consider the =

>> stateful approach explained above.
>>
> =

> That statement seems to be contradictory?=C2=A0 Can you explain?

Sorry, I meant to use varargs in either l_gpio_new() or l_gpio_set_lines().


Anyways, thanks for being patient.

// Martin

--===============7976450851644059367==--

