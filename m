Content-Type: multipart/mixed; boundary="===============7477952857223091945=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2] cert: Fix warning of possible uninitialized var
Date: Mon, 25 Jan 2021 10:34:30 -0600
Message-ID: <a4a76a10-fc28-92c4-2373-46579a7cc468@gmail.com>
In-Reply-To: <20210118182028.964376-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7477952857223091945==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

On 1/18/21 12:20 PM, Brian Gix wrote:
> ell/cert-crypto.c: In function =E2=80=98cert_pkcs12_pbkdf=E2=80=99:
> ell/cert-crypto.c:244:3: error: =E2=80=98bmpstring=E2=80=99 may be used u=
ninitialized in this function [-Werror=3Dmaybe-uninitialized]
>    244 |   explicit_bzero(bmpstring, passwd_len);
>        |   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> ---
>   ell/cert-crypto.c | 10 ++++++----
>   1 file changed, 6 insertions(+), 4 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============7477952857223091945==--

