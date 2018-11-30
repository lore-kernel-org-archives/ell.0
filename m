Content-Type: multipart/mixed; boundary="===============1877404788434234462=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 1/2] main: Add support for $NOTIFY_SOCKET
Date: Fri, 30 Nov 2018 10:23:50 -0600
Message-ID: <fdcce245-89d1-b7aa-6d1e-c8c82092106e@gmail.com>
In-Reply-To: <20181130094402.22111-1-luiz.dentz@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1877404788434234462==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Luiz,

On 11/30/2018 03:44 AM, Luiz Augusto von Dentz wrote:
> From: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>
> =

> This adds support for sending states to the service manager using the
> socket set in $NOTIFY_SOCKET:
> =

> https://www.freedesktop.org/software/systemd/man/sd_notify.html
> ---
>   ell/main.c | 71 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/main.h |  2 ++
>   2 files changed, 73 insertions(+)
> =


<snip>

> @@ -324,6 +329,40 @@ static void idle_dispatch(void *data, void *user_dat=
a)
>   	idle->flags &=3D ~IDLE_FLAG_DISPATCHING;
>   }
>   =

> +static void create_sd_notify_socket(void)
> +{
> +	const char *sock;
> +	struct sockaddr_un addr;
> +
> +	/* check if NOTIFY_SOCKET has been set */
> +	sock =3D getenv("NOTIFY_SOCKET");
> +	if (!sock)
> +		return;
> +
> +	/* check for abstract socket or absolute path */
> +	if (sock[0] !=3D '@' && sock[0] !=3D '/')
> +		return;
> +
> +	notify_fd =3D socket(AF_UNIX, SOCK_DGRAM | SOCK_CLOEXEC, 0);
> +	if (notify_fd < 0) {
> +		notify_fd =3D 0;
> +		return;
> +	}
> +
> +	memset(&addr, 0, sizeof(addr));
> +	addr.sun_family =3D AF_UNIX;
> +	strncpy(addr.sun_path, sock, sizeof(addr.sun_path) - 1);
> +
> +	if (addr.sun_path[0] =3D=3D '@')
> +		addr.sun_path[0] =3D '\0';
> +
> +	if (bind(notify_fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
> +		close(notify_fd);
> +		notify_fd =3D 0;
> +	}
> +}
> +
> +

I removed this double empty line and applied this patch, thanks.

Regards,
-Denis


--===============1877404788434234462==--

