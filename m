Content-Type: multipart/mixed; boundary="===============3676058315476495545=="
MIME-Version: 1.0
From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] uuid: Added l_uuid_parse
Date: Fri, 01 Feb 2019 22:14:59 +0100
Message-ID: <nycvar.YFH.7.76.1902012213390.32294@n3.vanv.qr>
In-Reply-To: <b90e57e8-4a9a-5826-3564-1a4161d4a7fa@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3676058315476495545==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Friday 2019-02-01 18:22, Denis Kenzior wrote:

> Hi Micha=C5=82,
>
>> I've also changed printf/scanf formatting to use PRIx/SCNx macros, for
>> better portability
>
> Hmm, portability where?  Is this an actual concern? Any platform that ell=
 can
> actually run on, PRIx/SCNx =3D=3D 'x', no?
>
> The use of PRI* macros makes the printf statement quite a bit less readab=
le
> IMO.  I can understand the need when using size_t or other esoteric types=
 that
> depend on the arch, but uint8_t isn't one of them...

size_t isn't esoteric, it has its own standard specifier, %zu.
Unless, of course, you're somehow depending on MSVCRT6...

--===============3676058315476495545==--

