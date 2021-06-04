Content-Type: multipart/mixed; boundary="===============3026561046304659495=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] avoid using inet_ntoa()
Date: Fri, 04 Jun 2021 11:01:10 -0500
Message-ID: <2582f783-6333-86a5-32e3-fe6c0deb4e37@gmail.com>
In-Reply-To: <2e6706da52bdcb3ce3caedbb63da81cb222ba561.1622713571.git.davide.caratti@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3026561046304659495==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Davide,

On 6/3/21 4:50 AM, Davide Caratti wrote:
> use inet_ntop() and a temporary buffer, like it's done elsewhere for IPv6.
> =

> Signed-off-by: Davide Caratti <davide.caratti@gmail.com>
> ---
>   ell/acd.c                    |  5 +++--
>   ell/dhcp-lease.c             |  3 ++-
>   ell/dhcp-server.c            | 11 +++++++----
>   ell/dhcp.c                   | 17 +++++++++++++++--
>   ell/rtnl.c                   |  7 +++++--
>   examples/https-server-test.c |  4 +++-

Strictly speaking the examples/ change should be in its own patch.  See HAC=
KING.

>   6 files changed, 35 insertions(+), 12 deletions(-)
> =

> diff --git a/ell/acd.c b/ell/acd.c
> index 6989f82..e267a96 100644
> --- a/ell/acd.c
> +++ b/ell/acd.c
> @@ -57,10 +57,11 @@
>   =

>   #define IP_STR(uint_ip) \
>   ({ \
> +	char _buf[INET_ADDRSTRLEN]; \
>   	struct in_addr _in; \
> -	char *_out; \
> +	const char *_out; \
>   	_in.s_addr =3D uint_ip; \
> -	_out =3D inet_ntoa(_in); \
> +	_out =3D inet_ntop(AF_INET, &_in, _buf, INET_ADDRSTRLEN) ?: "(inv)"; \
>   	_out; \
>   })
>   =

> diff --git a/ell/dhcp-lease.c b/ell/dhcp-lease.c
> index 44c815f..94b67b4 100644
> --- a/ell/dhcp-lease.c
> +++ b/ell/dhcp-lease.c
> @@ -178,12 +178,13 @@ error:
>   static inline char *get_ip(uint32_t ip)
>   {
>   	struct in_addr addr;
> +	char buf[INET_ADDRSTRLEN];
>   =

>   	if (ip =3D=3D 0)
>   		return NULL;
>   =

>   	addr.s_addr =3D ip;
> -	return l_strdup(inet_ntoa(addr));
> +	return l_strdup(inet_ntop(AF_INET, &addr, buf, INET_ADDRSTRLEN));
>   }
>   =

>   LIB_EXPORT char *l_dhcp_lease_get_address(const struct l_dhcp_lease *le=
ase)
> diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
> index ebd4438..43f06b3 100644
> --- a/ell/dhcp-server.c
> +++ b/ell/dhcp-server.c
> @@ -91,10 +91,11 @@ struct l_dhcp_server {
>   =

>   #define IP_STR(uint_ip) \
>   ({ \
> +	char _buf[INET_ADDRSTRLEN]; \
>   	struct in_addr _in; \
> -	char *_out; \
> +	const char *_out; \
>   	_in.s_addr =3D uint_ip; \
> -	_out =3D inet_ntoa(_in); \
> +	_out =3D inet_ntop(AF_INET, &_in, _buf, INET_ADDRSTRLEN) ?: "(inv)"; \
>   	_out; \
>   })
>   =

> @@ -750,6 +751,7 @@ LIB_EXPORT void l_dhcp_server_destroy(struct l_dhcp_s=
erver *server)
>   =

>   LIB_EXPORT bool l_dhcp_server_start(struct l_dhcp_server *server)
>   {
> +	char buf[INET_ADDRSTRLEN];
>   	struct in_addr ia;
>   =

>   	if (unlikely(!server))
> @@ -838,9 +840,10 @@ LIB_EXPORT bool l_dhcp_server_start(struct l_dhcp_se=
rver *server)
>   	ia.s_addr =3D server->address;
>   =

>   	/* In case of unit testing we don't want this to be a fatal error */
> -	if (!l_acd_start(server->acd, inet_ntoa(ia))) {
> +	if (!inet_ntop(AF_INET, &ia, buf, INET_ADDRSTRLEN) ||
> +	    !l_acd_start(server->acd, buf)) {

Note that we use only tabs for indentation...  See doc/coding-style.txt for=
 details

>   		SERVER_DEBUG("Failed to start ACD on %s, continuing without",
> -				IP_STR(server->address));
> +			     IP_STR(server->address));
as above

>   =

>   		l_acd_destroy(server->acd);
>   		server->acd =3D NULL;
> diff --git a/ell/dhcp.c b/ell/dhcp.c
> index a4afa95..d7809cb 100644
> --- a/ell/dhcp.c
> +++ b/ell/dhcp.c
> @@ -55,6 +55,17 @@
>   =

>   #define BITS_PER_LONG (sizeof(unsigned long) * 8)
>   =

> +#define IP_STR(uint_ip) \
> +({ \
> +	char _buf[INET_ADDRSTRLEN]; \
> +	struct in_addr _in; \
> +	const char *_out; \
> +	_in.s_addr =3D uint_ip; \
> +	_out =3D inet_ntop(AF_INET, &_in, _buf, INET_ADDRSTRLEN) ?: "(inv)"; \
> +	_out; \
> +})
> +
> +

no double empty lines please

>   enum dhcp_state {
>   	DHCP_STATE_INIT,
>   	DHCP_STATE_SELECTING,
> @@ -778,6 +789,7 @@ static void dhcp_client_rx_message(const void *data, =
size_t len, void *userdata)
>   	struct l_dhcp_client *client =3D userdata;
>   	const struct dhcp_message *message =3D data;
>   	struct dhcp_message_iter iter;
> +	char buf[INET_ADDRSTRLEN];
>   	uint8_t msg_type =3D 0;
>   	uint8_t t, l;
>   	const void *v;
> @@ -911,9 +923,10 @@ static void dhcp_client_rx_message(const void *data,=
 size_t len, void *userdata)
>   		ia.s_addr =3D client->lease->address;
>   =

>   		/* For unit testing we don't want this to be a fatal error */
> -		if (!l_acd_start(client->acd, inet_ntoa(ia))) {
> +		if (!inet_ntop(AF_INET, &ia, buf, INET_ADDRSTRLEN) ||
> +		    !l_acd_start(client->acd, buf)) {
>   			CLIENT_DEBUG("Failed to start ACD on %s, continuing",
> -						inet_ntoa(ia));
> +				     IP_STR(ia.s_addr));

Not sure introducing IP_STR macro just for this is worth it, but ok...

same here for indentation

>   			l_acd_destroy(client->acd);
>   			client->acd =3D NULL;
>   		}
> diff --git a/ell/rtnl.c b/ell/rtnl.c
> index 957e749..82ad941 100644
> --- a/ell/rtnl.c
> +++ b/ell/rtnl.c
> @@ -752,6 +752,7 @@ LIB_EXPORT uint32_t l_rtnl_set_powered(struct l_netli=
nk *rtnl, int ifindex,
>   LIB_EXPORT void l_rtnl_ifaddr4_extract(const struct ifaddrmsg *ifa, int=
 bytes,
>   				char **label, char **ip, char **broadcast)
>   {
> +	char buf[INET_ADDRSTRLEN];
>   	struct in_addr in_addr;
>   	struct rtattr *attr;
>   =

> @@ -763,7 +764,8 @@ LIB_EXPORT void l_rtnl_ifaddr4_extract(const struct i=
faddrmsg *ifa, int bytes,
>   				break;
>   =

>   			in_addr =3D *((struct in_addr *) RTA_DATA(attr));
> -			*ip =3D l_strdup(inet_ntoa(in_addr));
> +			*ip =3D l_strdup(inet_ntop(AF_INET, &in_addr, buf,
> +						 INET_ADDRSTRLEN)); >
>   			break;
>   		case IFA_BROADCAST:
> @@ -771,7 +773,8 @@ LIB_EXPORT void l_rtnl_ifaddr4_extract(const struct i=
faddrmsg *ifa, int bytes,
>   				break;
>   =

>   			in_addr =3D *((struct in_addr *) RTA_DATA(attr));
> -			*broadcast =3D l_strdup(inet_ntoa(in_addr));
> +			*broadcast =3D l_strdup(inet_ntop(AF_INET, &in_addr, buf,
> +							INET_ADDRSTRLEN));
>   =

>   			break;
>   		case IFA_LABEL:
> diff --git a/examples/https-server-test.c b/examples/https-server-test.c
> index 6362722..ddf326c 100644
> --- a/examples/https-server-test.c
> +++ b/examples/https-server-test.c
> @@ -199,12 +199,14 @@ int main(int argc, char *argv[])
>   			https_tls_ready, https_tls_disconnected, NULL);
>   =

>   	if (getenv("TLS_DEBUG")) {
> +		char b[INET_ADDRSTRLEN];
>   		char *str;
>   =

>   		l_tls_set_debug(tls, https_tls_debug_cb, NULL, NULL);
>   =

>   		str =3D l_strdup_printf("/tmp/ell-certchain-%s.pem",
> -					inet_ntoa(client_addr.sin_addr));
> +				      inet_ntop(AF_INET, &client_addr.sin_addr,
> +						b, INET_ADDRSTRLEN) ?: "NA");

Looks like indentation problem here too.  Maybe you want to put the inet_nt=
op =

business outside of l_strdup_printf call to make things more readable?

>   		l_tls_set_cert_dump_path(tls, str);
>   		l_free(str);
>   	}
> =


Regards,
-Denis
--===============3026561046304659495==--

