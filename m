Content-Type: multipart/mixed; boundary="===============0946142744020171874=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 4/4] dbus: Handle partial reads and writes
Date: Wed, 04 May 2016 13:10:52 +0200
Message-ID: <CAOq732KCay4DHK=7c+TL0opixS102izdyrxBy6UydNFP=8em4w@mail.gmail.com>
In-Reply-To: <1462359793-18789-4-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0946142744020171874==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Sorry for the unterminated commit message.  For the record here's a
short discussion of how the FDs are received in recvmsg calls,
https://bugs.freedesktop.org/show_bug.cgi?id=3D80559 .  Re-reading it, I
understand we're not doing enough to handle the corner cases but with
this patch we at least do what systemd does.

Best regards

On 4 May 2016 at 13:03, Andrew Zaborowski <andrew.zaborowski@intel.com> w=
rote:
> Loop until we have received or sent all of the data requested.  We pass
> MSG_WAITALL to potentially reduce the number of iterations.  Make sure
> we free body and header in classic_recv_message when
> dbus_message_build() returns an error.
>
> Calling sendms and recvmsg multiple times makes it even more tricky to
> understand what will happen with the FDs passed as oob data when a
> partial read/write happens or when there are multiple messsages with FDs
> attached in the queue.  What this patch does should be equivalent to
> what systemd dbus code does.  It seems to assume that the FDs are
> attached to the last byte of the message so on a partial write, the FDs
> are not written and the full array can be passed to sendmsg() again.
> I'm not sure if this is documented anywhere but I've seen an explicit
> statement of this at ...
> ---
>  ell/dbus.c | 179 +++++++++++++++++++++++++++++++++++++------------------=
------
>  1 file changed, 110 insertions(+), 69 deletions(-)
>
> diff --git a/ell/dbus.c b/ell/dbus.c
> index 35378b2..3ca7b87 100644
> --- a/ell/dbus.c
> +++ b/ell/dbus.c
> @@ -579,63 +579,126 @@ static void classic_free(struct l_dbus *dbus)
>         l_free(classic);
>  }
>
> +static bool msg_op(int fd, bool send, struct iovec iov[],
> +                       int **fds, uint32_t *num_fds)
> +{
> +       int r;
> +       struct msghdr msg;
> +       struct cmsghdr *cmsg;
> +       uint8_t *fd_buf =3D NULL;
> +       int buf_fds;
> +       int iovlen =3D 2;
> +
> +       if (send)
> +               buf_fds =3D *num_fds;
> +       else {
> +               buf_fds =3D 16;
> +               *num_fds =3D 0;
> +       }
> +
> +       if (buf_fds) {
> +               fd_buf =3D alloca(CMSG_SPACE(buf_fds * sizeof(int)));
> +
> +               if (send) {
> +                       msg.msg_control =3D fd_buf;
> +                       msg.msg_controllen =3D CMSG_LEN(buf_fds * sizeof(=
int));
> +
> +                       /* Set up fd_buf contents */
> +                       cmsg =3D CMSG_FIRSTHDR(&msg);
> +                       cmsg->cmsg_len =3D msg.msg_controllen;
> +                       cmsg->cmsg_level =3D SOL_SOCKET;
> +                       cmsg->cmsg_type =3D SCM_RIGHTS;
> +                       memcpy(CMSG_DATA(cmsg), *fds, buf_fds * sizeof(in=
t));
> +               }
> +       }
> +
> +       while (iovlen) {
> +               memset(&msg, 0, sizeof(msg));
> +               msg.msg_iov =3D iov;
> +               msg.msg_iovlen =3D iovlen;
> +               msg.msg_control =3D fd_buf;
> +               msg.msg_controllen =3D fd_buf ?
> +                       CMSG_LEN(buf_fds * sizeof(int)) : 0;
> +
> +               if (send)
> +                       r =3D sendmsg(fd, &msg, 0);
> +               else
> +                       r =3D recvmsg(fd, &msg, MSG_CMSG_CLOEXEC | MSG_WA=
ITALL);
> +
> +               if (r <=3D 0) {
> +                       if (r !=3D -1 || errno !=3D EINTR)
> +                               return false;
> +
> +                       continue;
> +               }
> +
> +               while (iovlen && r >=3D (int) iov[0].iov_len) {
> +                       r -=3D iov[0].iov_len;
> +                       iov++;
> +                       iovlen--;
> +               }
> +
> +               if (iovlen) {
> +                       iov[0].iov_base +=3D r;
> +                       iov[0].iov_len -=3D r;
> +               }
> +
> +               if (send)
> +                       continue;
> +
> +               for (cmsg =3D CMSG_FIRSTHDR(&msg); cmsg;
> +                               cmsg =3D CMSG_NXTHDR(&msg, cmsg)) {
> +                       int cnt;
> +
> +                       if (cmsg->cmsg_level !=3D SOL_SOCKET ||
> +                                               cmsg->cmsg_type !=3D SCM_=
RIGHTS)
> +                               continue;
> +
> +                       cnt =3D (cmsg->cmsg_len - CMSG_LEN(0)) / sizeof(i=
nt);
> +
> +                       *fds =3D l_realloc(*fds, (*num_fds + cnt) * sizeo=
f(int));
> +
> +                       memcpy(*fds + *num_fds, CMSG_DATA(cmsg),
> +                                       cnt * sizeof(int));
> +
> +                       *num_fds +=3D cnt;
> +                }
> +       }
> +
> +       return true;
> +}
> +
>  static bool classic_send_message(struct l_dbus *dbus,
>                                         struct l_dbus_message *message)
>  {
>         int fd =3D l_io_get_fd(dbus->io);
> -       struct msghdr msg;
>         struct iovec iov[2];
> -       ssize_t len;
>         int *fds;
>         uint32_t num_fds =3D 0;
> -       struct cmsghdr *cmsg;
>
>         iov[0].iov_base =3D _dbus_message_get_header(message, &iov[0].iov=
_len);
>         iov[1].iov_base =3D _dbus_message_get_body(message, &iov[1].iov_l=
en);
>
> -       memset(&msg, 0, sizeof(msg));
> -       msg.msg_iov =3D iov;
> -       msg.msg_iovlen =3D 2;
> -
>         if (dbus->support_unix_fd)
>                 fds =3D _dbus_message_get_fds(message, &num_fds);
>
> -       if (num_fds) {
> -               msg.msg_control =3D alloca(CMSG_SPACE(num_fds * sizeof(in=
t)));
> -               msg.msg_controllen =3D CMSG_LEN(num_fds * sizeof(int));
> -
> -               cmsg =3D CMSG_FIRSTHDR(&msg);
> -               cmsg->cmsg_len =3D msg.msg_controllen;
> -               cmsg->cmsg_level =3D SOL_SOCKET;
> -               cmsg->cmsg_type =3D SCM_RIGHTS;
> -               memcpy(CMSG_DATA(cmsg), fds, num_fds * sizeof(int));
> -       }
> -
> -       len =3D sendmsg(fd, &msg, 0);
> -       if (len < 0)
> -               return false;
> -
> -       return true;
> +       return msg_op(fd, true, iov, &fds, &num_fds);
>  }
>
>  static struct l_dbus_message *classic_recv_message(struct l_dbus *dbus)
>  {
>         int fd =3D l_io_get_fd(dbus->io);
>         struct dbus_header hdr;
> -       struct msghdr msg;
>         struct iovec iov[2];
> -       struct cmsghdr *cmsg;
>         ssize_t len;
>         void *header, *body;
>         size_t header_size, body_size;
> -       union {
> -               uint8_t bytes[CMSG_SPACE(16 * sizeof(int))];
> -               struct cmsghdr align;
> -       } fd_buf;
>         int *fds =3D NULL;
>         uint32_t num_fds =3D 0;
> +       struct l_dbus_message *msg;
> +       unsigned int i;
>
> -       len =3D recv(fd, &hdr, DBUS_HEADER_SIZE, MSG_PEEK);
> +       len =3D recv(fd, &hdr, DBUS_HEADER_SIZE, MSG_PEEK | MSG_WAITALL);
>         if (len !=3D DBUS_HEADER_SIZE)
>                 return NULL;
>
> @@ -650,59 +713,37 @@ static struct l_dbus_message *classic_recv_message(=
struct l_dbus *dbus)
>         iov[1].iov_base =3D body;
>         iov[1].iov_len  =3D body_size;
>
> -       memset(&msg, 0, sizeof(msg));
> -       msg.msg_iov =3D iov;
> -       msg.msg_iovlen =3D 2;
> -       msg.msg_control =3D &fd_buf;
> -       msg.msg_controllen =3D sizeof(fd_buf);
> -
> -       len =3D recvmsg(fd, &msg, MSG_CMSG_CLOEXEC);
> -       if (len < 0)
> -               goto cmsg_fail;
> -
> -       for (cmsg =3D CMSG_FIRSTHDR(&msg); cmsg;
> -                               cmsg =3D CMSG_NXTHDR(&msg, cmsg)) {
> -               unsigned int i;
> -
> -               if (cmsg->cmsg_level !=3D SOL_SOCKET ||
> -                                       cmsg->cmsg_type !=3D SCM_RIGHTS)
> -                       continue;
> -
> -               num_fds =3D (cmsg->cmsg_len - CMSG_LEN(0)) / sizeof(int);
> -               fds =3D (void *) CMSG_DATA(cmsg);
> -
> -               /* Set FD_CLOEXEC on all file descriptors */
> -               for (i =3D 0; i < num_fds; i++) {
> -                       long flags;
> -
> -                       flags =3D fcntl(fds[i], F_GETFD, NULL);
> -                       if (flags < 0)
> -                               continue;
> -
> -                       if (!(flags & FD_CLOEXEC))
> -                               fcntl(fds[i], F_SETFD, flags | FD_CLOEXEC=
);
> -                }
> -       }
> +       if (!msg_op(fd, false, iov, &fds, &num_fds))
> +               goto fail;
>
>         if (hdr.endian !=3D DBUS_NATIVE_ENDIAN) {
>                 l_util_debug(dbus->debug_handler,
>                                 dbus->debug_data, "Endianness incorrect");
> -               goto bad_msg;
> +               goto fail;
>         }
>
>         if (hdr.version !=3D 1) {
>                 l_util_debug(dbus->debug_handler,
>                                 dbus->debug_data, "Protocol version incor=
rect");
> -               goto bad_msg;
> +               goto fail;
>         }
>
> -       return dbus_message_build(header, header_size, body, body_size,
> +       msg =3D dbus_message_build(header, header_size, body, body_size,
>                                         fds, num_fds);
> +       if (!msg)
> +               goto fail;
>
> -bad_msg:
> -cmsg_fail:
> -       l_free(header);
> +       l_free(fds);
> +
> +       return msg;
> +
> +fail:
> +       for (i =3D 0; i < num_fds; i++)
> +               close(fds[i]);
> +
> +       l_free(fds);
>         l_free(body);
> +       l_free(header);
>
>         return NULL;
>  }
> --
> 2.7.4
>

--===============0946142744020171874==--

