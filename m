Content-Type: multipart/mixed; boundary="===============4034740678075633893=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 4/4] path: Use l_timespec_to_usecs() to avoid overflow.
Date: Mon, 02 Mar 2020 15:50:10 -0600
Message-ID: <6d498de9-6ea7-1f26-e158-c1b743f8c5da@gmail.com>
In-Reply-To: <20200302212817.15524-5-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4034740678075633893==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 3/2/20 3:28 PM, Ossama Othman wrote:
> ---
>   ell/path.c | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)
> =

> diff --git a/ell/path.c b/ell/path.c
> index df5a703..e911c01 100644
> --- a/ell/path.c
> +++ b/ell/path.c
> @@ -162,8 +162,7 @@ LIB_EXPORT uint64_t l_path_get_mtime(const char *path)
>   	if (ret < 0)
>   		return L_TIME_INVALID;
>   =

> -	return (uint64_t) sb.st_mtim.tv_sec * 1000000 +
> -		sb.st_mtim.tv_nsec / 1000;
> +	return l_timespec_to_usecs(&sb.st_mtim);

So while theoretically possible to overflow, this is _highly_ unlikely. =

I think we are looking at 35-36 bits of sec info, which is 1-2 thousand =

years in the future.

I guess I'm ok if we try and deal with overflow just in case someone is =

setting some really large mtime values as long as l_timespec_to_usecs =

isn't overly expensive.

>   }
>   =

>   /**
> =


Regards,
-Denis
--===============4034740678075633893==--

