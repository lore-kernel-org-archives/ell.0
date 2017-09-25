Content-Type: multipart/mixed; boundary="===============9004304752454723413=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/4] util: Add l_strlcpy
Date: Mon, 25 Sep 2017 17:28:58 -0500
Message-ID: <21211d12-c773-8b5f-cf24-809c4e8272bc@gmail.com>
In-Reply-To: <alpine.OSX.2.21.1709251505380.10397@mjmartin-mac01.sea.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9004304752454723413==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

>>
>> how does a direct for/while loop implementation compare speed wise to =

>> calling strlen & memcpy?
> =

> It's about twice as fast to use strlen/memcpy. The direct implementation =

> I used for comparison:
> =

>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 const char *orig_src =3D src;
> =

>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (len) {
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 while (*src !=3D '\0' && --len) {
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 *dst++ =
=3D *src++;
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 }
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 *dst =3D '\0';
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return (src - orig_src) + str=
len(src);
> =

> I modified the unit test to run a bunch of iterations with some more =

> string sizes and to take performance samples during the strlcpy test. =

> gperftools showed that the direct code spent 57.39% of execution time =

> inside l_strlcpy and the strlen/memcpy technique spent 16.06% of =

> execution time inside l_strlcpy. Turning off the profiling stuff and =

> just using 'time', direct took 53.973 seconds and strlen/memcpy took =

> 25.176 seconds of user time.
> =


Interesting, seems counter-intuitive since we're walking the string =

twice.  I went ahead and applied the original patch 2 + 3.  Much =

appreciated!

Regards,
-Denis

--===============9004304752454723413==--

