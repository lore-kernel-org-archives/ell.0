Content-Type: multipart/mixed; boundary="===============5771435367930582991=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/4] time: Use l_timespec_to_usecs() to avoid overflow.
Date: Mon, 02 Mar 2020 15:44:02 -0600
Message-ID: <32e9a01e-2eb9-ef3b-3675-f6690fbe9a0b@gmail.com>
In-Reply-To: <20200302212817.15524-4-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5771435367930582991==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 3/2/20 3:28 PM, Ossama Othman wrote:
> ---
>   ell/time.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =

> diff --git a/ell/time.c b/ell/time.c
> index becf985..3bf75e6 100644
> --- a/ell/time.c
> +++ b/ell/time.c
> @@ -67,7 +67,7 @@ LIB_EXPORT uint64_t l_time_now(void)
>   =

>   	clock_gettime(CLOCK_BOOTTIME, &now);
>   =

> -	return now.tv_sec * 1000000 + now.tv_nsec / 1000;
> +	return l_timespec_to_usecs(&now);

This is time since boot, so I sincerely doubt we want to care about 68+ =

year uptimes.

It might be worthwhile to use ULL constants though just to be pedantic.

>   }
>   =

>   /**
> =


Regards,
-Denis
--===============5771435367930582991==--

