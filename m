Content-Type: multipart/mixed; boundary="===============6580400557696310697=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Wed, 29 May 2019 11:46:41 -0500
Message-ID: <30aa4457-4941-d6c0-1906-5a47eaf5857a@gmail.com>
In-Reply-To: <6dcca23f-6f55-18c3-cc03-b092695e540d@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6580400557696310697==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Martin,

>> So do you really want to limit yourself to just a single line per object?
> =

> I figured a single l_gpio_writer object could easily represent multiple =

> lines. But for handling power to my peripheral only a single line is =

> needed.
> =

> If/when we implement multi-line handling, the single-line functions can =

> be turned into wrappers that set up 1-sized arrays.
> =


I think you're not going to gain much up front and will make your job =

(or someone else's) much harder if you do that.

>>>
>>> =C2=A0=C2=A0 void l_gpio_out_free(struct l_gpio_out *gpio_out);
>>>
>>> =C2=A0=C2=A0 bool l_gpio_out_set(struct l_gpio_out *gpio_out, bool valu=
e);
>>>
>>> =C2=A0=C2=A0 bool l_gpio_find(char *chip, uint32_t *line_num);
>>
>> I'm guessing this is missing a const char * variable?
> =

> Ahh, yes. So like this:
> =

>  =C2=A0=C2=A0=C2=A0 bool l_gpio_find(const char *label, char *chip, uint3=
2_t *line_num);
> =

> I wanted this to search all available gpio chips and return the =

> chip-name in char *chip.

So chip is a return value? In that case char **chip.  But I'm still =

confused how you're going to accomplish this?  Are you going to scan =

sysfs for this?

> =

> My use-case as a BSP developer is to tell the application developer to =

> simply open gpio label "FOO" and then let the BSP care about gpio chips =

> and line numbers. The label might exist on gpio chip X on one board, and =

> on gpio chip Y on another.
> =

> If we really want to support cases where a label exists on multiple =

> chips, then we could implement the above as
> =

>  =C2=A0=C2=A0=C2=A0 char **l_gpio_find_chip(const char *label);

This sounds more general

> =

> The user can decide what to do if multiple devices are returned...
> =

>>>
>>> This should allow to add the needed parts for multiple-lines, inputs, =

>>> and gpio-chips at a later point. I.e. adding API for
>>>
>>> =C2=A0=C2=A0 struct l_gpio_chip;
>>> =C2=A0=C2=A0 struct l_gpio_in;
>>>
>>> and maybe also
>>>
>>> =C2=A0=C2=A0 struct l_gpio_out *l_gpio_out_many(const char *chip,
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 uint32_t line_num1, bool val1,
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 ..., -1);
>>
>> This still doesn't solve the dynamically discovered lines issue.
> =

> varargs are probably not the right choice.

I think ultimately we may want both, but I'm fine holding off =

implementing them until that day comes.

> =

>> I would maybe do something like this.=C2=A0 Perhaps some of this might b=
e =

>> redundant or not needed...
>>
>> struct l_gpio_info *l_gpio_discover_lines(const char *device);
>> const char *l_gpio_info_get_name(struct l_gpio_info *);
>> const char *l_gpio_info_get_label(struct l_gpio_info *);
>> uint32_t l_gpio_info_get_num_lines(struct l_gpio_info *);
>> char **l_gpio_get_lines(struct l_gpio_info *);
>> uint32_t l_gpio_info_find_offset(struct l_gpio_info *, const char *name);
>> const char *l_gpio_info_get_name(struct l_gpio_info *, uint32_t offset);
>> void l_gpio_info_free(struct l_gpio_info *);
> =

> I think we should use l_gpio_device instead of l_gpio_info to make it =

> clear that the names and labels are for the chip and not the line.

That's fine, or use l_gpio_chip or l_gpio_chip_info to keep in line with =

the kernel naming.

> =

>> int l_gpio_get_values_by_name(const char *device, const char *line, ...);
>> int l_gpio_get_values_by_offset(const char *device, int offset, ...);
>>
>> struct l_gpio_writer *l_gpio_new(const char *device, uint32_t n_lines, =

>> const uint32_t lines[][2]);
> =

> I like this. I guess the following functions should have _writer in =

> their names, and take a struct l_gpio_writer * as first argument?

I'm also fine naming them l_gpio.  Not sure what looks better yet =

honestly.  We can fight over that later.

> =

>> l_gpio_free(struct l_gpio *);
>> bool l_gpio_set_linesv(struct l_gpio *gpio, uint32_t n_lines, const =

>> uint32_t lines[][2]);
>> bool l_gpio_set_line(struct l_gpio *gpio, uint32_t line, uint32_t value);
>> bool l_gpio_set_lines(struct l_gpio *gpio, int line, ...);
> =

> I prefer the l_gpio_set_linesv() approach to this.
> =


Sure, lets implement the set_line & set_linesv first.

>> So at the bare minimum, you could do:
>>
>> struct l_gpio_info *info =3D l_gpio_discover_lines("/foo/bar");
>> uint32_t line =3D l_gpio_info_find_offset(info, "gpio_line");
>> uint32_t lines[1][2];
>> struct l_gpio *gpio;
>>
>> lines[0][0] =3D line;
>> lines[0][1] =3D some_default;
>> l_gpio_info_free(info);
>>
>> gpio =3D l_gpio_new("/foo/bar", 1, lines);
>>
>> // off
>> l_gpio_set_line(gpio, lines[0][0], 0);
>>
>> // on
>> l_gpio_set_line(gpio, lines[0][0], 1);
> =

> How about:
> =

> char **devices;
> struct l_gpio_device *device;
> uint32_t lines[1][2];
> struct l_gpio_writer *line;
> =

> devices =3D l_gpio_devices_with_line_label("my_label");
> if (!devices)
>  =C2=A0=C2=A0=C2=A0=C2=A0return;
> =

> if (l_strv_length(devices) !=3D 1) {
>  =C2=A0=C2=A0=C2=A0=C2=A0l_error("label not unique");
>  =C2=A0=C2=A0=C2=A0=C2=A0return;
> }
> =

> device =3D l_gpio_device_new(devices[0]);
> if (!device)
>  =C2=A0=C2=A0=C2=A0=C2=A0return;
> =

> l_strfreev(devices);
> =

> if (!l_gpio_device_find_offset(device, "my_label", &lines[0][0]);
>  =C2=A0=C2=A0=C2=A0=C2=A0return;
> =

> lines[0][1] =3D 0;
> =

> line =3D l_gpio_writer_new(device, 1, lines);
> if (!line)
>  =C2=A0=C2=A0=C2=A0=C2=A0return;
> =

> l_gpio_device_free(device);
> =

> // off
> l_gpio_writer_set(line, lines[0][0], 0);
> =

> // on
> l_gpio_writer_set(line, lines[0][0], 1);
> =

> // many
> l_gpio_writer_setv(line, 1, lines);
> =

> l_gpio_writer_free(line);
> =

>

That looks fine to me.

> =

> We could also consider using a struct l_gpio_line_value to represent =

> line numbers and values:
> =

> struct l_gpio_line_value {
>  =C2=A0=C2=A0=C2=A0=C2=A0uint32_t line_number;
line_offset I guess.
>  =C2=A0=C2=A0=C2=A0=C2=A0uint32_t line_value;
> };
> =

> and take an array of those as argument instead of uint32_t[][2].

Yep.  I thought about that, but generally I dislike introducing =

non-opaque types into the public namespace unless absolutely needed. =

But in this case it doesn't matter a whole lot, so I'm fine either way.

Regards,
-Denis

--===============6580400557696310697==--

