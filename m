Content-Type: multipart/mixed; boundary="===============1695929801767563450=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: [PATCH v2] cert: Fix warning of possible uninitialized var
Date: Mon, 25 Jan 2021 17:40:27 +0000
Message-ID: <56983e54ba628ae3cbf051e53737ba054ac7781b.camel@intel.com>
In-Reply-To: <a4a76a10-fc28-92c4-2373-46579a7cc468@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1695929801767563450==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Sorry Denis....   In a conf call with Marcel, he suggested the patch in v3 =
just sent...


Also, if possible, we would like to get a 0.37 version of ELL labeled, sinc=
e this will be the first working
version for us since 0.35, and I need to account for the file name change o=
f pkcs5 --> cert-crypto


On Mon, 2021-01-25 at 10:34 -0600, Denis Kenzior wrote:
> Hi Brian,
> =

> On 1/18/21 12:20 PM, Brian Gix wrote:
> > ell/cert-crypto.c: In function =E2=80=98cert_pkcs12_pbkdf=E2=80=99:
> > ell/cert-crypto.c:244:3: error: =E2=80=98bmpstring=E2=80=99 may be used=
 uninitialized in this function [-Werror=3Dmaybe-
> > uninitialized]
> >    244 |   explicit_bzero(bmpstring, passwd_len);
> >        |   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > ---
> >   ell/cert-crypto.c | 10 ++++++----
> >   1 file changed, 6 insertions(+), 4 deletions(-)
> > =

> =

> Applied, thanks.
> =

> Regards,
> -Denis
>=20

--===============1695929801767563450==--

