Content-Type: multipart/mixed; boundary="===============5341458853782683525=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Avoid EPOLL_CTL_ADD on kdbus fd before hello command
Date: Tue, 05 Apr 2016 10:13:14 -0500
Message-ID: <5703D60A.1000007@gmail.com>
In-Reply-To: <1459821880-7050-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5341458853782683525==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/04/2016 09:04 PM, Andrew Zaborowski wrote:
> Reorder the kdbus initialisation to avoid epoll_ctl(fd, EPOLL_CTL_ADD,
> ...) being called (from watch_add in l_io_new in dbus_init) before
> KDBUS_CMD_HELLO is sent.  On the kernel side the kdbus handle is in the
> BUS_OWNER state until the hello command changes is to CONNECTED state,
> and will exit from f_ops->poll and not do anything to make epoll work.
> handle->conn is created only once in CONNECTED state but only the
> first f_ops->poll call by a given eventpoll has a chance to add the
> handle->conn->wait to its poll table.
> ---
>   ell/dbus.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>

Applied, thanks.

Does kdbus work reliably now?

Regards,
-Denis


--===============5341458853782683525==--

