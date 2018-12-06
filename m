Content-Type: multipart/mixed; boundary="===============1748815392590179838=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: RE: [PATCH ELL] dbus: Fix uninitialized build warning
Date: Thu, 06 Dec 2018 23:38:34 +0000
Message-ID: <DEBB0CAA2616974FAE35E4B560B9A4375C13DF87@ORSMSX103.amr.corp.intel.com>
In-Reply-To: <20181206233729.20555-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1748815392590179838==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi all,

This fixes a warning when building from within bluez build environment

> -----Original Message-----
> From: Gix, Brian
> Sent: Thursday, December 6, 2018 3:37 PM
> To: ell(a)lists.01.org
> Cc: denkenz(a)gmail.com; Martineau, Mathew J
> <mathew.j.martineau@intel.com>; Zaborowski, Andrew
> <andrew.zaborowski@intel.com>; marcel(a)holtmann.org; Gix, Brian
> <brian.gix@intel.com>
> Subject: [PATCH ELL] dbus: Fix uninitialized build warning
> =

> ---
>  ell/dbus.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> =

> diff --git a/ell/dbus.c b/ell/dbus.c
> index 2a27116..55aee0e 100644
> --- a/ell/dbus.c
> +++ b/ell/dbus.c
> @@ -598,7 +598,7 @@ static bool classic_send_message(struct l_dbus
> *dbus,
>  	struct msghdr msg;
>  	struct iovec iov[2], *iovpos;
>  	ssize_t r;
> -	int *fds;
> +	int *fds =3D NULL;
>  	uint32_t num_fds =3D 0;
>  	struct cmsghdr *cmsg;
>  	int iovlen;
> --
> 2.14.5


--===============1748815392590179838==--

