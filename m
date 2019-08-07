Content-Type: multipart/mixed; boundary="===============3149465308271249170=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/4] unit: Update expected peer identity strings in TLS
Date: Wed, 07 Aug 2019 18:40:49 -0500
Message-ID: <44bb79f3-d284-c27c-99e5-37a3cc6e1169@gmail.com>
In-Reply-To: <CAOq732LiDAS5zS5T2S9v-dZc_rKJaL3QPDhWCminDZu_Gq9qnQ@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3149465308271249170==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>> Also, what happens if the strings contain a '/' character? Or is that
>> not possible?
> =

> So apparently openssl has some \ unescaping support for these strings
> when you generate the certificate and probably the characters are
> escaped again when you extract this string from a cert.  We could
> replicate this but in terms of security I think it doesn't add
> anything, users will just need to remember to not escape the
> characters in the iwd configs.
> =


This response doesn't fill me with a lot of confidence :)  How is domain =

name suffix matching code (for example) going to deal with random '/' =

characters if they serve as delimiters?

Regards,
-Denis

--===============3149465308271249170==--

