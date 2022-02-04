Content-Type: multipart/mixed; boundary="===============0083593192072105924=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 4/5] util: add l_secure_select_byte
Date: Fri, 04 Feb 2022 12:16:16 -0600
Message-ID: <68397c7f-a3e0-ca35-f8c0-595edaab8945@gmail.com>
In-Reply-To: 554cdd2aa640cc7ebb34768e9bdfe78dacef1ca3.camel@gmail.com

--===============0083593192072105924==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,
>>
>> Why not use secure_select from ell/useful.h ?
> =

> Ugh, we should keep these things in one place, unless there was a
> reason for doing it this way?
> =


It was needed for l_ecc_point_from_sswu() (SAE-H2E).  I don't remember why =
I =

didn't switch iwd over.  We should try to do so.

In general, ell/useful.h would be the place for such utilities.

Regards,
-Denis
--===============0083593192072105924==--

