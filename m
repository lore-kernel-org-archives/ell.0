Content-Type: multipart/mixed; boundary="===============2067751260763284843=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau at linux.intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH]run unit tests on both OpenSSL-1.x and OpenSSL-3.x
Date: Wed, 06 Apr 2022 15:15:05 -0700
Message-ID: <139b5e8-97c0-624c-ff3d-eaee4555498e@linux.intel.com>
In-Reply-To: CAKjfnjruDgyK0EB4RtqXoHy6CR2SU=iTt11UmfDtGw4AfDZhMw@mail.gmail.com

--===============2067751260763284843==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Tue, 29 Mar 2022, wen zhang wrote:

> Some unit tests are breaking on systems with OpenSSL 3.x.
> This patch detects the OpenSSL version, then if we are building Ell on
> OpenSSL 3.x, the legacy module options will be appended to openssl comman=
ds.

Hi Wen Zhang -

I noticed that ELL is not building the unit tests on the Fedora 36 beta =

due to this OpenSSL 3 command line issue with the legacy providers.

Unfortunately, your patch didn't work on Fedora 36. I see these lines =

added to the Makefile generated with the bootstrap-configure script:

OPENSSL_LEGACY_OPTS =3D
OPENSSL_LIBDIR =3D

In addition, the openssl legacy provider options are not included in the =

openssl commands.


Also, be sure to send patches using 'git send-email' so they do not use =

HTML or attachments. More patch submission guidelines are here: =

https://git.kernel.org/pub/scm/libs/ell/ell.git/tree/HACKING


Thanks,

--
Mat Martineau
Intel
--===============2067751260763284843==--

