Content-Type: multipart/mixed; boundary="===============3956891000123510888=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Replace copy_params/size_params with macros.
Date: Mon, 21 Mar 2016 11:42:16 -0500
Message-ID: <56F02468.3090100@gmail.com>
In-Reply-To: <1458367247-14607-2-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3956891000123510888==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/19/2016 01:00 AM, Andrew Zaborowski wrote:
> Passing va_list to functions this way doesn't work on i386 gcc, va_list
> seems to be a simple pointer as recommended by stdarg(3).  Passing a
> pointer to va_list seems to fix this, but stdarg(3) also says:
>
>     If ap is passed to a function that uses va_arg(ap,type), then the val=
ue
>     of ap is undefined after the return of that function.
>
> so it's better to just use a macro.
> ---
>   ell/dbus-service.c | 98 ++++++++++++++++++++++-------------------------=
-------
>   1 file changed, 40 insertions(+), 58 deletions(-)

Makes sense to me.  Thanks for looking into this one.

Applied, thanks.

Regards,
-Denis


--===============3956891000123510888==--

