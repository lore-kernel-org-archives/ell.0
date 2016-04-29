Content-Type: multipart/mixed; boundary="===============1087443368779001814=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 08/11] dbus: Remove memcpy and fix setting of FD_CLOEXEC
 on FDs
Date: Fri, 29 Apr 2016 11:11:34 -0500
Message-ID: <572387B6.7090706@gmail.com>
In-Reply-To: <1461900728-20662-13-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1087443368779001814==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/28/2016 10:32 PM, Andrew Zaborowski wrote:
> Make sure the size of the FD buffer passed to recvmsg is properly
> aligned, etc. and remove the memcpy which seems unneeded.  Also it looks
> like the fcntl() calls operated on one dbus socket FD instead of the
> message FDs.
> ---
>   ell/dbus.c | 14 +++++++-------
>   1 file changed, 7 insertions(+), 7 deletions(-)
>
> diff --git a/ell/dbus.c b/ell/dbus.c
> index 70da849..fc0f243 100644
> --- a/ell/dbus.c
> +++ b/ell/dbus.c
> @@ -638,7 +638,8 @@ static struct l_dbus_message *classic_recv_message(st=
ruct l_dbus *dbus)
>   	ssize_t len;
>   	void *header, *body;
>   	size_t header_size, body_size;
> -	int fds[16];
> +	uint8_t fd_buf[CMSG_SPACE(16 * sizeof(int))];

'man cmsg' recommends doing:
            union {
                /* ancillary data buffer, wrapped in a union in order to =

ensure
                   it is suitably aligned */
                char buf[CMSG_SPACE(sizeof myfds)];
                struct cmsghdr align;
            } u;

And it looks like systemd does the same.  This is probably what we =

should do as well.

> +	int *fds =3D NULL;
>   	uint32_t num_fds =3D 0;
>
>   	len =3D recv(fd, &hdr, DBUS_HEADER_SIZE, MSG_PEEK);
> @@ -659,8 +660,8 @@ static struct l_dbus_message *classic_recv_message(st=
ruct l_dbus *dbus)
>   	memset(&msg, 0, sizeof(msg));
>   	msg.msg_iov =3D iov;
>   	msg.msg_iovlen =3D 2;
> -	msg.msg_control =3D &fds;
> -	msg.msg_controllen =3D CMSG_SPACE(16 * sizeof(int));
> +	msg.msg_control =3D &fd_buf;
> +	msg.msg_controllen =3D sizeof(fd_buf);
>
>   	len =3D recvmsg(fd, &msg, MSG_CMSG_CLOEXEC);
>   	if (len < 0)
> @@ -675,19 +676,18 @@ static struct l_dbus_message *classic_recv_message(=
struct l_dbus *dbus)
>   			continue;
>
>   		num_fds =3D (cmsg->cmsg_len - CMSG_LEN(0)) / sizeof(int);
> -
> -		memcpy(fds, CMSG_DATA(cmsg), num_fds * sizeof(int));
> +		fds =3D (void *) CMSG_DATA(cmsg);
>
>   		/* Set FD_CLOEXEC on all file descriptors */
>   		for (i =3D 0; i < num_fds; i++) {
>   			long flags;
>
> -			flags =3D fcntl(fd, F_GETFD, NULL);
> +			flags =3D fcntl(fds[i], F_GETFD, NULL);
>   			if (flags < 0)
>   				continue;
>
>   			if (!(flags & FD_CLOEXEC))
> -				fcntl(fd, F_SETFD, flags | FD_CLOEXEC);
> +				fcntl(fds[i], F_SETFD, flags | FD_CLOEXEC);
>                   }
>   	}
>
>

Regards,
-Denis

--===============1087443368779001814==--

