Content-Type: multipart/mixed; boundary="===============1089316309313681798=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: Re: [PATCHv4] gpio: add get/set helpers for GPIO lines
Date: Mon, 17 Jun 2019 12:13:40 +0200
Message-ID: <833f6aba-8703-d0e2-54b2-55b6af717ebb@geanix.com>
In-Reply-To: <6102f3b7-a8b8-e99e-11ae-6ede07043b1d@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1089316309313681798==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 05/06/2019 18.04, Denis Kenzior wrote:
>> +LIB_EXPORT char **l_gpio_chips_with_line_label(const char *line_label)
>> +{
>> +=C2=A0=C2=A0=C2=A0 struct dirent *entry;
>> +=C2=A0=C2=A0=C2=A0 DIR *dp;
>> +=C2=A0=C2=A0=C2=A0 char **chips =3D NULL;
>> +
>> +=C2=A0=C2=A0=C2=A0 dp =3D opendir("/sys/bus/gpio/devices");
>> +=C2=A0=C2=A0=C2=A0 if (dp =3D=3D NULL)
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return NULL;
>> +
>> +=C2=A0=C2=A0=C2=A0 while ((entry =3D readdir(dp))) {
> =

> May want to skip directories.=C2=A0 e.g. something like:
> =

> if (entry->d_type !=3D DT_REG)
>  =C2=A0=C2=A0=C2=A0=C2=A0continue;

The files in /sys/bus/gpio/devices are links, so I've added a check for =

DT_LNK.

<snip>

>> +LIB_EXPORT char *l_gpio_chip_get_line_label(struct l_gpio_chip *chip,
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 uint3=
2_t offset)
> =

> Is there a particular reason to return char * here?=C2=A0 Why not const c=
har =

> * and have the caller l_strdup as needed?

The info object is allocated on the stack, so we cannot return the .name =

member to the caller.

>> +{
>> +=C2=A0=C2=A0=C2=A0 struct gpioline_info info;
>> +
>> +=C2=A0=C2=A0=C2=A0 if (!chip)
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return NULL;
>> +
>> +=C2=A0=C2=A0=C2=A0 if (offset >=3D chip->n_lines)
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return NULL;
>> +
>> +=C2=A0=C2=A0=C2=A0 memset(&info, 0, sizeof(info));
>> +=C2=A0=C2=A0=C2=A0 info.line_offset =3D offset;
>> +
>> +=C2=A0=C2=A0=C2=A0 if (ioctl(chip->fd, GPIO_GET_LINEINFO_IOCTL, &info) =
< 0)
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return NULL;
>> +
>> +=C2=A0=C2=A0=C2=A0 return l_strdup(info.name);
>> +}
>> +
>> +LIB_EXPORT char *l_gpio_chip_get_line_consumer(struct l_gpio_chip *chip,
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 uint3=
2_t offset)
> =

> Is there a particular reason to return char * here?=C2=A0 Why not const c=
har =

> * and have the caller l_strdup as needed?

Same here.

// Martin

--===============1089316309313681798==--

