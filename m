Content-Type: multipart/mixed; boundary="===============6681941316571574997=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/4] autotools: Only used -Wcast-align with gcc
Date: Thu, 15 Dec 2016 07:57:18 +0100
Message-ID: <876A9361-B751-4FA5-BF3D-245576450505@holtmann.org>
In-Reply-To: <20161214225121.9439-2-ell@ongy.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6681941316571574997==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Markus,

> clang can currently not compile NLMSG_NEXT with -Wcast-align.
> I asked about this in #llvm on irc.oftc.net, where I was told the best
> solution is to disable -Wcast-align for now.

can we get a little bit more background on this. I had also some issues wit=
h native gcc usage on Raspberry PI. And yes, the netlink macros are some of=
fenders.

> ---
> acinclude.m4 | 4 +++-
> 1 file changed, 3 insertions(+), 1 deletion(-)
> =

> diff --git a/acinclude.m4 b/acinclude.m4
> index 8aab4ee..b1dbabe 100644
> --- a/acinclude.m4
> +++ b/acinclude.m4
> @@ -58,6 +58,8 @@ AC_DEFUN([COMPILER_FLAGS], [
> 		CFLAGS+=3D" -Wdeclaration-after-statement"
> 		CFLAGS+=3D" -Wmissing-declarations"
> 		CFLAGS+=3D" -Wredundant-decls"
> -		CFLAGS+=3D" -Wcast-align"
> +		if ( $CC -v 2>/dev/null | grep "gcc version" ); then
> +			CFLAGS+=3D" -Wcast-align"
> +		fi

Are you sure there is not a better autoconf macro for checking if we use gc=
c vs clang.

Regards

Marcel


--===============6681941316571574997==--

