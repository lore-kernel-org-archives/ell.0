Content-Type: multipart/mixed; boundary="===============5018665866842774235=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/2] dbus: Check that property signature has one data type
Date: Thu, 21 Apr 2016 21:21:00 -0500
Message-ID: <57198A8C.5070607@gmail.com>
In-Reply-To: <1461286637-30810-2-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5018665866842774235==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/21/2016 07:57 PM, Andrew Zaborowski wrote:
> ---
>   ell/dbus-service.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/ell/dbus-service.c b/ell/dbus-service.c
> index 9d2110f..44baaaf 100644
> --- a/ell/dbus-service.c
> +++ b/ell/dbus-service.c
> @@ -408,7 +408,7 @@ LIB_EXPORT bool l_dbus_interface_property(struct l_db=
us_interface *interface,
>   	if (unlikely(!signature || !getter))
>   		return false;
>
> -	if (!_dbus_valid_signature(signature))
> +	if (_dbus_num_children(signature) !=3D 1)
>   		return false;

Good catch.

>
>   	/* Pre-calculate the needed meta-info length */
>

Applied, thanks.

Regards,
-Denis

--===============5018665866842774235==--

