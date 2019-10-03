Content-Type: multipart/mixed; boundary="===============0836973013810563379=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] unit: fix build with musl libc
Date: Thu, 03 Oct 2019 10:58:53 -0500
Message-ID: <1b318150-9b2b-4c14-9f10-82e84601d4bb@gmail.com>
In-Reply-To: <20191003150306.11761-1-ncopa@alpinelinux.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0836973013810563379==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Natanael,

On 10/3/19 10:03 AM, Natanael Copa wrote:
> Define WAIT_ANY if needed. It is not specified in POSIX so we cannot
> expect it to be defined.
> =

> This fixes build with musl libc.
> ---
>   unit/test-dbus-message-fds.c | 4 ++++
>   unit/test-dbus-properties.c  | 4 ++++
>   unit/test-dbus.c             | 4 ++++
>   3 files changed, 12 insertions(+)
> =

> diff --git a/unit/test-dbus-message-fds.c b/unit/test-dbus-message-fds.c
> index 6f68bae..6a23141 100644
> --- a/unit/test-dbus-message-fds.c
> +++ b/unit/test-dbus-message-fds.c
> @@ -41,6 +41,10 @@
>   #define WAIT_ANY (-1) /* Any process */
>   #endif
>   =

> +#ifndef WAIT_ANY
> +#define WAIT_ANY (-1)
> +#endif
> +

I'm confused.  Don't we have the exact same 3 lines just above?

>   #define TEST_BUS_ADDRESS "unix:path=3D/tmp/ell-test-bus"
>   =

>   static pid_t dbus_daemon_pid =3D -1;

Regards,
-Denis
--===============0836973013810563379==--

