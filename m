Content-Type: multipart/mixed; boundary="===============1991446097207398445=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCHv2] gpio: add simple get/set helpers for GPIO lines
Date: Tue, 28 May 2019 18:46:15 -0500
Message-ID: <9309b72d-fc2c-0acd-635c-debcbe81e246@gmail.com>
In-Reply-To: <3e3c2bdf-a3a2-6a82-8013-a137ac2bb208@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1991446097207398445==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Martin,

> I have implemented my ofono driver using libgpiod for now. To use ell =

> instead it would need to:
> =

> 1. (optionally) lookup a gpio line by label
> 2. open the gpio line as output with a default value
> 3. set the value to true/false
> =

> These could be supported by the following:
> =

>  =C2=A0 struct l_gpio_out;

I'm not super excited about the name.  Maybe l_gpio_writer?

> =

>  =C2=A0 struct l_gpio_out *l_gpio_out(const char *chip, uint32_t line_num,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 bool default_value);
> =

>  =C2=A0 struct l_gpio_out *l_gpio_out_label(const char *chip,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 const char *label,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 bool default_value);

So do you really want to limit yourself to just a single line per object?

> =

>  =C2=A0 void l_gpio_out_free(struct l_gpio_out *gpio_out);
> =

>  =C2=A0 bool l_gpio_out_set(struct l_gpio_out *gpio_out, bool value);
> =

>  =C2=A0 bool l_gpio_find(char *chip, uint32_t *line_num);

I'm guessing this is missing a const char * variable?

> =

> This should allow to add the needed parts for multiple-lines, inputs, =

> and gpio-chips at a later point. I.e. adding API for
> =

>  =C2=A0 struct l_gpio_chip;
>  =C2=A0 struct l_gpio_in;
> =

> and maybe also
> =

>  =C2=A0 struct l_gpio_out *l_gpio_out_many(const char *chip,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 uint32_t line_num1, bool val1,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 ..., -1);

This still doesn't solve the dynamically discovered lines issue.

I would maybe do something like this.  Perhaps some of this might be =

redundant or not needed...

struct l_gpio_info *l_gpio_discover_lines(const char *device);
const char *l_gpio_info_get_name(struct l_gpio_info *);
const char *l_gpio_info_get_label(struct l_gpio_info *);
uint32_t l_gpio_info_get_num_lines(struct l_gpio_info *);
char **l_gpio_get_lines(struct l_gpio_info *);
uint32_t l_gpio_info_find_offset(struct l_gpio_info *, const char *name);
const char *l_gpio_info_get_name(struct l_gpio_info *, uint32_t offset);
void l_gpio_info_free(struct l_gpio_info *);
int l_gpio_get_values_by_name(const char *device, const char *line, ...);
int l_gpio_get_values_by_offset(const char *device, int offset, ...);

struct l_gpio_writer *l_gpio_new(const char *device, uint32_t n_lines, =

const uint32_t lines[][2]);
l_gpio_free(struct l_gpio *);
bool l_gpio_set_linesv(struct l_gpio *gpio, uint32_t n_lines, const =

uint32_t lines[][2]);
bool l_gpio_set_line(struct l_gpio *gpio, uint32_t line, uint32_t value);
bool l_gpio_set_lines(struct l_gpio *gpio, int line, ...);

So at the bare minimum, you could do:

struct l_gpio_info *info =3D l_gpio_discover_lines("/foo/bar");
uint32_t line =3D l_gpio_info_find_offset(info, "gpio_line");
uint32_t lines[1][2];
struct l_gpio *gpio;

lines[0][0] =3D line;
lines[0][1] =3D some_default;
l_gpio_info_free(info);

gpio =3D l_gpio_new("/foo/bar", 1, lines);

// off
l_gpio_set_line(gpio, lines[0][0], 0);

// on
l_gpio_set_line(gpio, lines[0][0], 1);

> =

> // Martin

Regards,
-Denis

--===============1991446097207398445==--

