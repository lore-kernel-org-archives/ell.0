Content-Type: multipart/mixed; boundary="===============4074884667578395102=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 2/2] main: Add support for $WATCHDOG_USEC
Date: Fri, 30 Nov 2018 10:25:28 -0600
Message-ID: <2bd49ad6-ae2f-5eb7-64f0-4317f4cfb146@gmail.com>
In-Reply-To: <20181130094402.22111-2-luiz.dentz@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4074884667578395102==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Luiz,

On 11/30/2018 03:44 AM, Luiz Augusto von Dentz wrote:
> From: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>
> =

> This adds handling to watchdog set by service manager by sending
> "WATCHDOG=3D1" to it in intervals shorter than what is set in
> $WATCHDOG_USEC.
> ---
>   ell/main.c | 32 ++++++++++++++++++++++++++++++++
>   1 file changed, 32 insertions(+)
> =


<snip>

> @@ -359,7 +375,21 @@ static void create_sd_notify_socket(void)
>   	if (bind(notify_fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
>   		close(notify_fd);
>   		notify_fd =3D 0;
> +		return;
>   	}
> +
> +	watchdog_usec =3D getenv("WATCHDOG_USEC");
> +	if (!watchdog_usec)
> +		return;
> +
> +	msec =3D atoi(watchdog_usec) / 1000;
> +	if (msec < 0)

So I changed this to if (msec < WATCHDOG_TRIGGER_FREQ), otherwise you =

can end up with 0 for the msec value.  We might want to put an even =

higher clamp value for this.

> +		return;
> +
> +	msec /=3D WATCHDOG_TRIGGER_FREQ;
> +
> +	watchdog =3D l_timeout_create_ms(msec, watchdog_callback,
> +					L_INT_TO_PTR(msec), NULL);
>   }
>   =


Applied, thanks.

Regards,
-Denis

--===============4074884667578395102==--

