Content-Type: multipart/mixed; boundary="===============7971179001487197135=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp-server: Fix lease expiry time calculation
Date: Fri, 04 Jun 2021 11:49:37 -0500
Message-ID: <748fe26e-cc56-ef9c-95cd-480844486f35@gmail.com>
In-Reply-To: <20210601235332.95056-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7971179001487197135==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 6/1/21 6:53 PM, Andrew Zaborowski wrote:
> We were comparing the l_time_now() (usecs) to lease->lifetime (secs)
> and then converting the result from usecs to secs, so the "diff" and the
> "to_secs" operations need to be switched around.  While there, use the
> opportunity to replace the "diff" operation so that if lease->lifetime is
> already in the past (e.g. because processing took to long), we schedule
> the timeout in 1 millisec instead of the absolute value of the difference.
> =

> Since we're using uint32_t for the timestamps, use the overflow-safe(r)
> comparisons in set_next_expire_timer and in is_expired_lease.
> ---
>   ell/dhcp-server.c | 12 +++++++-----
>   1 file changed, 7 insertions(+), 5 deletions(-)
> =

> diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
> index ebd4438..38193a2 100644
> --- a/ell/dhcp-server.c
> +++ b/ell/dhcp-server.c
> @@ -104,7 +104,7 @@ struct l_dhcp_server {
>   =

>   static bool is_expired_lease(struct l_dhcp_lease *lease)
>   {
> -	if (lease->lifetime < l_time_to_secs(l_time_now()))
> +	if ((int32_t) (lease->lifetime - l_time_to_secs(l_time_now())) < 0)

Why not use l_time_before / l_time_after.  And with these changes I'm not s=
ure =

there's any point to store lease->lifetime in seconds.  I suspect this was =
done =

originally to use 'second' versions of l_timeout_*.

>   		return true;
>   =

>   	return false;
> @@ -191,7 +191,8 @@ static void set_next_expire_timer(struct l_dhcp_serve=
r *server,
>   					struct l_dhcp_lease *expired)
>   {
>   	struct l_dhcp_lease *next;
> -	unsigned int next_timeout;
> +	unsigned long next_timeout;

Why unsigned long?  It is different between 32 bit and 64 bit, so if you ne=
ed =

overflow protection, just use uint64_t instead?

> +	uint32_t now;
>   =

>   	/*
>   	 * If this is an expiring lease put it into the expired queue, removing
> @@ -214,11 +215,12 @@ static void set_next_expire_timer(struct l_dhcp_ser=
ver *server,
>   		return;
>   	}
>   =

> -	next_timeout =3D l_time_to_secs(l_time_diff(l_time_now(),
> -							next->lifetime));
> +	now =3D l_time_to_secs(l_time_now());
> +	next_timeout =3D (int32_t) (next->lifetime - now) > 0 ?
> +		(next->lifetime - now) * 1000L : 1;

Why 1000L?  next_timeout is unsigned?

Also, why not use existing l_time_after, l_time_diff and l_time_to_msecs ut=
ilities?

>   =

>   	if (server->next_expire)
> -		l_timeout_modify(server->next_expire, next_timeout);
> +		l_timeout_modify_ms(server->next_expire, next_timeout);
>   	else
>   		server->next_expire =3D l_timeout_create(server->lease_seconds,
>   							lease_expired_cb,
> =


Regards,
-Denis
--===============7971179001487197135==--

