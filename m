Content-Type: multipart/mixed; boundary="===============0657897840743986351=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v4 1/5] ecc: moved ecc from IWD into ell
Date: Sun, 09 Dec 2018 11:26:25 -0600
Message-ID: <2047423e-94cb-296a-571a-ea3eec738568@gmail.com>
In-Reply-To: <7B5B0376-AD43-4C0E-A454-01F0D2BF67F0@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0657897840743986351==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

> so I am not a big fan of these nested directory structures in the first p=
lace and especially not a big fan of the 3rdparty thing.
> =

> If we modify the source files to make them compile or use our internal de=
finitions, then it is no longer external code. If it is code that purely ex=
ternal, we can do ell/ecc-external.[ch] or something like that. We can do t=
he same as we do in ell/siphash.c where we take the code as ELL code and ac=
knowledge the original code and its origin.

So I'd like to separate as much as possible the original 3rd party code =

from what we ended up adding (which was quite a bit) to it in order to =

support EAP-PWD/SAE/OWE.  I want to make it easier to update this file =

from external sources if we need to (e.g. as vulnerabilities / bugs are =

potentially discovered and fixed.)  In iwd we created this hodge-podge =

of the original 3rdparty code + our additions and I don't think that was =

a good idea.

If you want to keep it in ecc-external.c, that would be fine.  3rdparty =

subdirectory seems clearer, but whichever accomplishes the above is fine.

> =

> Lets go back one step and tell me what this is based on? Is this the old =
BlueZ code or is this the micro-ecc?

The code was from BlueZ's version of ecc with slight modifications.  And =

that is another issue.  The goal of this is to standardize this across =

the projects.

> =

> Do we need such a rich API? Can we start with a smaller one for things we=
 actually need from it.
> =


This is about as minimal as we can get for what iwd needs for SAE/OWE/PWD.

Regards,
-Denis

--===============0657897840743986351==--

