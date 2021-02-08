Content-Type: multipart/mixed; boundary="===============7016986277792767646=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] acd: check fd return to satisfy static analysis
Date: Mon, 08 Feb 2021 13:34:34 -0600
Message-ID: <bd5c81a8-b609-77d9-536e-69e9ddef53ef@gmail.com>
In-Reply-To: <20210208192756.580521-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7016986277792767646==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 2/8/21 1:27 PM, James Prestwood wrote:
> ---
>   ell/acd.c | 9 ++++++++-
>   1 file changed, 8 insertions(+), 1 deletion(-)
> =

> diff --git a/ell/acd.c b/ell/acd.c
> index 6381747..d5c5024 100644
> --- a/ell/acd.c
> +++ b/ell/acd.c
> @@ -129,6 +129,9 @@ static int acd_send_packet(struct l_acd *acd, uint32_=
t source_ip)
>   	int n;
>   	int fd =3D l_io_get_fd(acd->io);
>   =

> +	if (fd < 0)
> +		return fd;
> +

Nah, don't bother with these.  If the socket is invalid, the destroy handle=
r =

should be set / notified.

>   	memset(&dest, 0, sizeof(dest));
>   	memset(&p, 0, sizeof(p));
>   =

> @@ -260,9 +263,13 @@ static bool acd_read_handler(struct l_io *io, void *=
user_data)
>   	int source_conflict;
>   	int target_conflict;
>   	bool probe;
> +	int fd =3D l_io_get_fd(acd->io);
> +
> +	if (fd < 0)
> +		return true;

And it can't be negative in the read handler anyway.

>   =

>   	memset(&arp, 0, sizeof(arp));
> -	len =3D read(l_io_get_fd(acd->io), &arp, sizeof(arp));
> +	len =3D read(fd, &arp, sizeof(arp));
>   	if (len < 0)
>   		return false;
>   =

> =


Regards,
-Denis
--===============7016986277792767646==--

