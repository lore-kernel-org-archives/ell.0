Content-Type: multipart/mixed; boundary="===============3403557739388995549=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Thu, 20 Dec 2018 14:40:12 -0600
Message-ID: <cccdeab9-7df6-f542-6bc3-b39af8017f6a@gmail.com>
In-Reply-To: <291bc8b4-d950-70a7-a41c-1033643905a2@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3403557739388995549==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Martin,

On 12/20/2018 01:45 PM, Martin Hundeb=C3=B8ll wrote:
> Hi Denis,
> =

> On 20/12/2018 18.51, Denis Kenzior wrote:
>> Ah, okay.=C2=A0 I think I get what you're trying to do.=C2=A0 So you wan=
t to =

>> have something like:
>>
>> struct l_gpio *l_gpio_new(const char *file_path, ...);
>>
>> Which would open(file_path), and issue GPIO_GET_CHIPINFO_IOCTL and =

>> GPIO_GET_LINEINFO_IOCTL to find the right lines, then
>>
>> GPIO_GET_LINEHANDLE_IOCTL with GPIOHANDLE_REQUEST_OUTPUT and =

>> GPIOHANDLE_REQUEST_INPUT flags set to obtain exclusive rights to the =

>> lines.
>>
>> bool l_gpio_set_values(struct l_gpio *, ...);
>>
>> would issue a GPIOHANDLE_SET_LINE_VALUES_IOCTL
>>
>> bool l_gpio_get_values(struct l_gpio *, ...);
>>
>> would issue a GPIOHANDLE_GET_LINE_VALUES_IOCTL,
>>
>> Am I right so far?
> =

> Yes, this is pretty much how I have come to imagine it.
> =


Okay.  One more doubt I have is what is the practical purpose of =

obtaining exclusive rights to the GPIO lines for reading only.  That =

seems kind of useless?  Especially if you need to provide default values =

for GPIOHANDLE_REQUEST_OUTPUT requests?

Perhaps reading should be on a different object?

>> And use it something like:
>>
>> struct l_gpio *gpio =3D l_gpio_new("/foo/bar", "3v3", "reset", "led", =

>> NULL);
>> l_gpio_set_values(gpio, true, true, false);
>> l_gpio_get_values(gpio, &foo, &bar, &baz);
>>
>> So the only issue I see here is how does one discover the lines for a =

>> given chip?=C2=A0 You might still want a l_gpio_chip abstraction to =

>> discover lines / line numbers, no?
> =

> How about a "raw" API like:
> =

> input_lines =3D l_gpio_lines("/some/chip", L_GPIO_IN, 1, 2, 6, -1);
> output_lines =3D l_gpio_lines("/some/chip", L_GPIO_OUT, 1, true, 2, false=
, =

> -1);
> =

> Output lines need a default value to set when the kernel changes them =

> from high-impedance inputs to outputs. I don't particular like how the =

> defaults are set in the above. Feel free to propose something better!

Another issue with varargs is that they presume knowledge at compile =

time.  So the above works if you don't need to query the chip and =

dynamically add lines to / from the request.  Perhaps this is the 99% =

use case anyway.

Can you open the chip for both input & output?

> =

> Lookup by label is then available via helpers:
> =

> chip_path =3D l_gpio_label_chip("chip-label");
> input_lines =3D l_gpio_label_lines(chip_path, L_GPIO_IN, "3v3", "reset", =

> "led", NULL);
> =

> chip_path =3D l_gpio_chip_with_line_labels("3v3", "reset", "led", NULL);
> output_lines =3D l_gpio_label_lines(chip_path, L_GPIO_OUT, "3v3", "reset"=
, =


I guess you need the defaults here...

> "led", NULL);
>

The only other possibility would be to add ability to add lines =

dynamically. Maybe roughly:

l_gpio_request *req =3D l_gpio_request_new();
int line =3D l_gpio_chip_lookup_line(chip, "3v3");
l_gpio_add_line(gpio, line, 0 // default);
gpio =3D l_gpio_new("/foo/bar", L_GPIO_OUT, req);

 From the above, what is absolutely required for your oFono work?  Just =

the vararg style constructor with L_GPIO_OUT and being able to specify =

by line or by label?

Regards,
-Denis

--===============3403557739388995549==--

