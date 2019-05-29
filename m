Content-Type: multipart/mixed; boundary="===============4372219820327066108=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Wed, 29 May 2019 09:30:49 +0200
Message-ID: <6dcca23f-6f55-18c3-cc03-b092695e540d@geanix.com>
In-Reply-To: <9309b72d-fc2c-0acd-635c-debcbe81e246@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4372219820327066108==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 29/05/2019 01.46, Denis Kenzior wrote:
>> I have implemented my ofono driver using libgpiod for now. To use ell =

>> instead it would need to:
>>
>> 1. (optionally) lookup a gpio line by label
>> 2. open the gpio line as output with a default value
>> 3. set the value to true/false
>>
>> These could be supported by the following:
>>
>> =C2=A0=C2=A0 struct l_gpio_out;
> =

> I'm not super excited about the name.=C2=A0 Maybe l_gpio_writer?

Sounds good.

>>
>> =C2=A0=C2=A0 struct l_gpio_out *l_gpio_out(const char *chip, uint32_t li=
ne_num,
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 bool default_value);
>>
>> =C2=A0=C2=A0 struct l_gpio_out *l_gpio_out_label(const char *chip,
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 const char *label,
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 bool default_value);
> =

> So do you really want to limit yourself to just a single line per object?

I figured a single l_gpio_writer object could easily represent multiple =

lines. But for handling power to my peripheral only a single line is needed.

If/when we implement multi-line handling, the single-line functions can =

be turned into wrappers that set up 1-sized arrays.

>>
>> =C2=A0=C2=A0 void l_gpio_out_free(struct l_gpio_out *gpio_out);
>>
>> =C2=A0=C2=A0 bool l_gpio_out_set(struct l_gpio_out *gpio_out, bool value=
);
>>
>> =C2=A0=C2=A0 bool l_gpio_find(char *chip, uint32_t *line_num);
> =

> I'm guessing this is missing a const char * variable?

Ahh, yes. So like this:

     bool l_gpio_find(const char *label, char *chip, uint32_t *line_num);

I wanted this to search all available gpio chips and return the =

chip-name in char *chip.

My use-case as a BSP developer is to tell the application developer to =

simply open gpio label "FOO" and then let the BSP care about gpio chips =

and line numbers. The label might exist on gpio chip X on one board, and =

on gpio chip Y on another.

If we really want to support cases where a label exists on multiple =

chips, then we could implement the above as

     char **l_gpio_find_chip(const char *label);

The user can decide what to do if multiple devices are returned...

>>
>> This should allow to add the needed parts for multiple-lines, inputs, =

>> and gpio-chips at a later point. I.e. adding API for
>>
>> =C2=A0=C2=A0 struct l_gpio_chip;
>> =C2=A0=C2=A0 struct l_gpio_in;
>>
>> and maybe also
>>
>> =C2=A0=C2=A0 struct l_gpio_out *l_gpio_out_many(const char *chip,
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 uint32_t line_num1, bool val1,
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 ..., -1);
> =

> This still doesn't solve the dynamically discovered lines issue.

varargs are probably not the right choice.

> I would maybe do something like this.=C2=A0 Perhaps some of this might be =

> redundant or not needed...
> =

> struct l_gpio_info *l_gpio_discover_lines(const char *device);
> const char *l_gpio_info_get_name(struct l_gpio_info *);
> const char *l_gpio_info_get_label(struct l_gpio_info *);
> uint32_t l_gpio_info_get_num_lines(struct l_gpio_info *);
> char **l_gpio_get_lines(struct l_gpio_info *);
> uint32_t l_gpio_info_find_offset(struct l_gpio_info *, const char *name);
> const char *l_gpio_info_get_name(struct l_gpio_info *, uint32_t offset);
> void l_gpio_info_free(struct l_gpio_info *);

I think we should use l_gpio_device instead of l_gpio_info to make it =

clear that the names and labels are for the chip and not the line.

> int l_gpio_get_values_by_name(const char *device, const char *line, ...);
> int l_gpio_get_values_by_offset(const char *device, int offset, ...);
> =

> struct l_gpio_writer *l_gpio_new(const char *device, uint32_t n_lines, =

> const uint32_t lines[][2]);

I like this. I guess the following functions should have _writer in =

their names, and take a struct l_gpio_writer * as first argument?

> l_gpio_free(struct l_gpio *);
> bool l_gpio_set_linesv(struct l_gpio *gpio, uint32_t n_lines, const =

> uint32_t lines[][2]);
> bool l_gpio_set_line(struct l_gpio *gpio, uint32_t line, uint32_t value);
> bool l_gpio_set_lines(struct l_gpio *gpio, int line, ...);

I prefer the l_gpio_set_linesv() approach to this.

> So at the bare minimum, you could do:
> =

> struct l_gpio_info *info =3D l_gpio_discover_lines("/foo/bar");
> uint32_t line =3D l_gpio_info_find_offset(info, "gpio_line");
> uint32_t lines[1][2];
> struct l_gpio *gpio;
> =

> lines[0][0] =3D line;
> lines[0][1] =3D some_default;
> l_gpio_info_free(info);
> =

> gpio =3D l_gpio_new("/foo/bar", 1, lines);
> =

> // off
> l_gpio_set_line(gpio, lines[0][0], 0);
> =

> // on
> l_gpio_set_line(gpio, lines[0][0], 1);

How about:

char **devices;
struct l_gpio_device *device;
uint32_t lines[1][2];
struct l_gpio_writer *line;

devices =3D l_gpio_devices_with_line_label("my_label");
if (!devices)
	return;

if (l_strv_length(devices) !=3D 1) {
	l_error("label not unique");
	return;
}

device =3D l_gpio_device_new(devices[0]);
if (!device)
	return;

l_strfreev(devices);

if (!l_gpio_device_find_offset(device, "my_label", &lines[0][0]);
	return;

lines[0][1] =3D 0;

line =3D l_gpio_writer_new(device, 1, lines);
if (!line)
	return;

l_gpio_device_free(device);

// off
l_gpio_writer_set(line, lines[0][0], 0);

// on
l_gpio_writer_set(line, lines[0][0], 1);

// many
l_gpio_writer_setv(line, 1, lines);

l_gpio_writer_free(line);



We could also consider using a struct l_gpio_line_value to represent =

line numbers and values:

struct l_gpio_line_value {
	uint32_t line_number;
	uint32_t line_value;
};

and take an array of those as argument instead of uint32_t[][2].

// Martin


--===============4372219820327066108==--

