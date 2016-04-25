Content-Type: multipart/mixed; boundary="===============7422792420663777495=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] util: Add suffix check for a string
Date: Mon, 25 Apr 2016 12:36:32 -0500
Message-ID: <571E55A0.2080605@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1604250914100.1671@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7422792420663777495==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

 >> +
>> +    str_len_diff =3D strlen(str) - strlen(suffix);
>
> strlen returns size_t (unsigned), which is a 64-bit type on 64-bit
> platforms. Hopefully no one is throwing around 4+GB null-terminated
> strings, but you never know. You can make sure the suffix is shorter
> before calculating the difference, avoiding signed integers altogether.

+1.  Please fix/resubmit this one.

Regards,
-Denis

--===============7422792420663777495==--

