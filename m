Content-Type: multipart/mixed; boundary="===============6675210271522721138=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 06/13] pkcs5: Add the PKCS#12 KDF
Date: Fri, 11 Dec 2020 15:50:33 +0000
Message-ID: <481d483e-22b3-9604-40c4-4cbc58a2ba2c@gmail.com>
In-Reply-To: <CAOq732J+dz7SEh9sV9x=SZE0ii1KGAWBYvZj2_RGMcyp1BqZTw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6675210271522721138==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>> So is this just a UCS2BE conversion?  If so, then using l_utf8_to_ucs2be=
 might
>> be clearer.
> =

> Basically yes.  But with l_utf8_to_ucs2be this will look something like:
> =

>    uint8_t *usc2;
> =

>    if (!l_utf8_validate(utf))
>      return false;

You'll potentially need this step in either version actually. =

utf8_get_codepoint isn't really enough to tell whether the entire string is =

valid utf8.  Where is the password coming from?

Also, I would think you'd pre-validate utf8 validity before ever getting to=
 this =

point?

> =

>    ucs2 =3D l_utf8_to_ucs2be(utf, out_len);
>    if (!str)
>      return false;
> =

>    memcpy(out_buf, ucs2, *out_len);
>    explicit_bzero(ucs2);
>    l_free(ucs2);
> =

> I can do that but it seems we're doing less work without using
> l_utf8_to_ucs2be here.

You could add an own buffer version of utf8_to_ucs2be.  But even this memcp=
y =

version seems to be cleaner than open-coding it.

Regards,
-Denis
--===============6675210271522721138==--

