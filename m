Content-Type: multipart/mixed; boundary="===============4153138571395813681=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel at holtmann.org>
To: ell at lists.01.org
Subject: Re: [PATCH 3/3] Makefile: Bump library 'current' version.
Date: Wed, 10 Nov 2021 06:58:32 +0100
Message-ID: <1F9E641A-022D-4E02-87CC-83EFA4AA0599@holtmann.org>
In-Reply-To: 20211110001448.175980-4-ossama.othman@intel.com

--===============4153138571395813681==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

> The l_rtnl interface changed.  Bump the "current" ELL library version
> number accordingly.
> ---
> Makefile.am | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> =

> diff --git a/Makefile.am b/Makefile.am
> index 4e650c9..73f5298 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -8,8 +8,8 @@ ACLOCAL_AMFLAGS =3D -I build-aux
> # Interfaces added:		CURRENT++ REVISION=3D0 AGE++
> # Interfaces removed:		CURRENT++ REVISION=3D0 AGE=3D0
> =

> -ELL_CURRENT =3D 0
> -ELL_REVISION =3D 2
> +ELL_CURRENT =3D 1
> +ELL_REVISION =3D 0
> ELL_AGE =3D 0

actually we have bothered changing this as long as we are still 0.x and not=
 stable. So I rather skip this for now.

Regards

Marcel

--===============4153138571395813681==--

