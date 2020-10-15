Content-Type: multipart/mixed; boundary="===============8574168896591915300=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 01/14] net: add l_net_get_ip_address()
Date: Thu, 15 Oct 2020 13:19:16 -0500
Message-ID: <f48d6079-8027-7472-ca1e-32317b5644e7@gmail.com>
In-Reply-To: <20201015171731.396538-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8574168896591915300==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/15/20 12:17 PM, James Prestwood wrote:
> ---
>   ell/net.c | 32 ++++++++++++++++++++++++++++++++
>   ell/net.h |  1 +
>   2 files changed, 33 insertions(+)
> =


Don't forget ell/ell.sym changes

> diff --git a/ell/net.c b/ell/net.c
> index 0bff535..5551779 100644
> --- a/ell/net.c
> +++ b/ell/net.c
> @@ -29,6 +29,7 @@
>   #include <unistd.h>
>   #include <errno.h>
>   #include <sys/ioctl.h>
> +#include <netinet/ip.h>
>   =

>   #include "net.h"
>   #include "net-private.h"
> @@ -336,3 +337,34 @@ char **net_domain_list_parse(const uint8_t *raw, siz=
e_t raw_len)
>   =

>   	return ret;
>   }
> +
> +LIB_EXPORT uint32_t l_net_get_ip_address(int ifindex)

Can we change the signature to:

bool l_net_get_address(int ifindex, struct in_addr *out)

That makes it more explicit that only IPv4 address is returned.

> +{
> +	struct ifreq ifr;
> +	int sk, err;
> +	struct sockaddr_in *server_ip;
> +	uint32_t ret =3D 0;
> +
> +	sk =3D socket(PF_INET, SOCK_DGRAM | SOCK_CLOEXEC, 0);
> +	if (sk < 0)
> +		return 0;
> +
> +	memset(&ifr, 0, sizeof(ifr));
> +	ifr.ifr_ifindex =3D ifindex;
> +
> +	err =3D ioctl(sk, SIOCGIFNAME, &ifr);
> +	if (err < 0)
> +		goto done;
> +
> +	err =3D ioctl(sk, SIOCGIFADDR, &ifr);
> +	if (err < 0)
> +		goto done;
> +
> +	server_ip =3D (struct sockaddr_in *) &ifr.ifr_addr;
> +	ret =3D server_ip->sin_addr.s_addr;
> +
> +done:
> +	close(sk);
> +
> +	return ret;
> +}
> diff --git a/ell/net.h b/ell/net.h
> index 6808e07..abaf785 100644
> --- a/ell/net.h
> +++ b/ell/net.h
> @@ -34,6 +34,7 @@ bool l_net_get_mac_address(uint32_t ifindex, uint8_t *o=
ut_addr);
>   char *l_net_get_name(uint32_t ifindex);
>   bool l_net_hostname_is_root(const char *hostname);
>   bool l_net_hostname_is_localhost(const char *hostname);
> +uint32_t l_net_get_ip_address(int ifindex);
>   =

>   #ifdef __cplusplus
>   }
> =


Regards,
-Denis
--===============8574168896591915300==--

