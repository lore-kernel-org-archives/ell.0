Content-Type: multipart/mixed; boundary="===============4023750870833371377=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v1 1/2] dbus: Add support to tcp address
Date: Mon, 15 Apr 2019 11:59:29 -0500
Message-ID: <00a29598-5f92-ac7d-28bd-fa0ca263588a@gmail.com>
In-Reply-To: <1555331007-26977-2-git-send-email-rhpr@cesar.org.br>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4023750870833371377==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ramon,

On 04/15/2019 07:23 AM, Ramon Ribeiro wrote:
> This patch allows a dbus client to connect to a dbus-daemon server
> address listenning a TCP transport protocol.
> A non-blocking TCP socket is created to avoid blocking the main event
> loop.
> ---
>   ell/dbus.c | 151 ++++++++++++++++++++++++++++++++++++++++++++++++++++++=
+++++--
>   1 file changed, 146 insertions(+), 5 deletions(-)
> =


<snip>

> +
> +	tv.tv_sec =3D 1;
> +	tv.tv_usec =3D 0;
> +
> +	// Wait until sockets be ready, otherwise a timeout is thrown
> +	if (select(fd + 1, &rfds, &wfds, NULL, &tv) =3D=3D 0) {
> +		close(fd);
> +		return NULL;
> +	}

How does this help?  You're still sleeping in select and not allowing =

the main event loop to run.  You would need to setup an l_io for these =

fds (so that they're part of the main-event loop epoll_wait call) and =

wait for the connect to succeed or go on to next address.

Regards,
-Denis

--===============4023750870833371377==--

