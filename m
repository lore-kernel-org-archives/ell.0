Content-Type: multipart/mixed; boundary="===============0568131750553480701=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] uuid: Added l_uuid_parse
Date: Fri, 01 Feb 2019 11:25:56 -0600
Message-ID: <163e920a-7101-5333-b03c-438c3fd0f096@gmail.com>
In-Reply-To: <20190201172248.ylwlb42ilq42cenl@kynes>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0568131750553480701==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Micha=C5=82,

> I don't think that's true. Since format passed to scanf expects a fixed
> input length, this works as expected:
> =

>      const char *string_uuid =3D "65fcc697-0776-5bf9-8573-72a51080c7detoo=
long";
>      l_uuid_parse(string_uuid, strlen(string_uuid) - strlen('toolong'), u=
uid);
> =

> The use case would be retrieving the UUID from a substring (at given
> offset), e.g. from a path. I'll add the unit test for this.

But then you know the expected UUID length anyway.  So you can simply =

check that strlen(string_uuid) is at least that long and pass in the =

expected UUID length to sscanf.

Regards,
-Denis

--===============0568131750553480701==--

