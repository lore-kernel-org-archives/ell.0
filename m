Content-Type: multipart/mixed; boundary="===============0971947825038223811=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] dhcp-server: Fix lease expiry time calculation
Date: Tue, 01 Jun 2021 09:38:39 -0500
Message-ID: <183b5df6-d81c-392c-c106-68f82ec2912a@gmail.com>
In-Reply-To: <20210601020346.35502-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0971947825038223811==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 5/31/21 9:03 PM, Andrew Zaborowski wrote:
> We were comparing the l_time_now() (usecs) with lease->lifetime (secs)
> and then converting the result from usecs to secs, so the "diff" and the
> "to_sec" operations should be switched around.  While there also replace
> the "diff" operation so that if lease->lifetime is already in the past
> (e.g. because processing took to long), we schedule the timeout in 0
> seconds instead of the absolute value of the difference.
> =

> Since we're using uint32_t for the timestamps, use the overflow-safe(r)
> comparison.
> ---
>   ell/dhcp-server.c | 6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
> =

> diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
> index d390856..9e39fe6 100644
> --- a/ell/dhcp-server.c
> +++ b/ell/dhcp-server.c
> @@ -192,6 +192,7 @@ static void set_next_expire_timer(struct l_dhcp_serve=
r *server,
>   {
>   	struct l_dhcp_lease *next;
>   	unsigned int next_timeout;
> +	uint32_t now;
>   =

>   	/*
>   	 * If this is an expiring lease put it into the expired queue, removing
> @@ -213,8 +214,9 @@ static void set_next_expire_timer(struct l_dhcp_serve=
r *server,
>   		return;
>   	}
>   =

> -	next_timeout =3D l_time_to_secs(l_time_diff(l_time_now(),
> -							next->lifetime));
> +	now =3D l_time_to_secs(l_time_now());
> +	next_timeout =3D (int32_t) (next->lifetime - now) > 0 ?
> +		next->lifetime - now : 0;

0 is not a valid timeout value, it is used to rearm the timer.  So this cas=
e =

probably needs a different approach.

>   =

>   	if (server->next_expire)
>   		l_timeout_modify(server->next_expire, next_timeout);
> =


Regards,
-Denis
--===============0971947825038223811==--

