Content-Type: multipart/mixed; boundary="===============5830579741845269323=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 1/2] dbus: Add support to tcp address
Date: Wed, 17 Apr 2019 15:13:56 -0500
Message-ID: <db251807-3382-39ef-426f-4c906193c4c6@gmail.com>
In-Reply-To: <1555419938-28430-2-git-send-email-rhpr@cesar.org.br>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5830579741845269323==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ramon,

On 04/16/2019 08:05 AM, Ramon Ribeiro wrote:
> This patch allows a dbus client to connect to a dbus-daemon server
> address listenning a TCP transport protocol.
> A non-blocking TCP socket is created to avoid blocking the main event
> loop.
> ---
>   ell/dbus.c | 125 ++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++---
>   1 file changed, 120 insertions(+), 5 deletions(-)
> =

> diff --git a/ell/dbus.c b/ell/dbus.c
> index 3a84c90..897e4b8 100644
> --- a/ell/dbus.c
> +++ b/ell/dbus.c
> @@ -31,8 +31,10 @@
>   #include <stdarg.h>
>   #include <stdlib.h>
>   #include <string.h>
> +#include <netdb.h>
>   #include <sys/socket.h>
>   #include <sys/un.h>
> +#include <netinet/in.h>
>   #include <errno.h>
>   =

>   #include "util.h"
> @@ -43,6 +45,7 @@
>   #include "dbus.h"
>   #include "private.h"
>   #include "dbus-private.h"
> +#include "main.h"
>   =

>   #define DEFAULT_SYSTEM_BUS_ADDRESS "unix:path=3D/var/run/dbus/system_bu=
s_socket"
>   =

> @@ -75,6 +78,7 @@ struct l_dbus_ops {
>   struct l_dbus {
>   	struct l_io *io;
>   	char *guid;
> +	char *transport;
>   	bool negotiate_unix_fd;
>   	bool support_unix_fd;
>   	bool is_ready;
> @@ -466,7 +470,8 @@ static bool auth_read_handler(struct l_io *io, void *=
user_data)
>   				return false;
>   =

>   			break;
> -		}
> +		} else if (len =3D=3D 0)
> +			close(fd);
>   =


You still need to return false from the handler or tell l_io about the =

IO being closed some other way.

>   		offset +=3D len;
>   	}
> @@ -511,7 +516,10 @@ static bool auth_read_handler(struct l_io *io, void =
*user_data)
>   		} else if (!strncmp(ptr, "REJECTED ", 9)) {
>   			static const char *command =3D "AUTH ANONYMOUS\r\n";
>   =

> -			dbus->negotiate_unix_fd =3D true;
> +			if (!strcmp(dbus->transport, "unix"))
> +				dbus->negotiate_unix_fd =3D true;
> +			else
> +				dbus->negotiate_unix_fd =3D false;
>   =

>   			classic->auth_command =3D l_strdup(command);
>   			classic->auth_state =3D WAITING_FOR_OK;
> @@ -680,6 +688,8 @@ static struct l_dbus_message *classic_recv_message(st=
ruct l_dbus *dbus)
>   	len =3D recv(fd, &hdr, DBUS_HEADER_SIZE, MSG_PEEK | MSG_DONTWAIT);
>   	if (len !=3D DBUS_HEADER_SIZE)
>   		return NULL;
> +	else if (len =3D=3D 0)
> +		close(fd);

Aren't we returning NULL above if len !=3D DBUS_HEADER_SIZE?  So how is =

this check ever true?

Also, just closing the socket isn't really enough, you need to tell the =

io object that the channel is closed.  E.g. by closing the fd and =

returning false from the read handler or by calling l_io_destroy.

>   =

>   	header_size =3D align_len(DBUS_HEADER_SIZE + hdr.dbus1.field_length, 8=
);
>   	header =3D l_malloc(header_size);
> @@ -1033,7 +1043,8 @@ static const struct l_dbus_ops classic_ops =3D {
>   	.name_acquire =3D classic_name_acquire,
>   };
>   =

> -static struct l_dbus *setup_dbus1(int fd, const char *guid)
> +static struct l_dbus *setup_dbus1(int fd, const char *guid,
> +				  const char *transport)
>   {
>   	static const unsigned char creds =3D 0x00;
>   	char uid[6], hexuid[12], *ptr =3D hexuid;
> @@ -1065,11 +1076,13 @@ static struct l_dbus *setup_dbus1(int fd, const c=
har *guid)
>   =

>   	dbus_init(dbus, fd);
>   	dbus->guid =3D l_strdup(guid);
> +	dbus->transport =3D l_strdup(transport);

Would a flag or an enum be enough?

>   =

>   	classic->auth_command =3D l_strdup_printf("AUTH EXTERNAL %s\r\n", hexu=
id);
>   	classic->auth_state =3D WAITING_FOR_OK;
>   =

> -	dbus->negotiate_unix_fd =3D true;
> +	if (!strcmp(transport, "unix"))
> +		dbus->negotiate_unix_fd =3D true;
>   	dbus->support_unix_fd =3D false;
>   =

>   	l_io_set_read_handler(dbus->io, auth_read_handler, dbus, NULL);
> @@ -1145,7 +1158,105 @@ static struct l_dbus *setup_unix(char *params)
>   		return NULL;
>   	}
>   =

> -	return setup_dbus1(fd, guid);
> +	return setup_dbus1(fd, guid, "unix");
> +}
> +
> +static bool on_tcp_connected(struct l_io *io, void *user_data)
> +{
> +	bool *is_connected =3D user_data;
> +
> +	*is_connected =3D true;
> +
> +	return true;
> +}
> +
> +static struct l_dbus *setup_tcp(char *params)
> +{
> +	struct addrinfo hints;
> +	struct addrinfo *results, *rp;
> +	struct l_io *io_connect;
> +	char *host =3D NULL, *port =3D NULL, *family =3D NULL, *guid =3D NULL;

So generally the Linux kernel coding style discourages such constructs. =

Each variable should be declared on a separate line.

> +	unsigned long port_number;
> +	bool is_connected =3D false;
> +	int err;
> +	int fd =3D -1;
> +
> +	while (params) {
> +		char *key =3D strsep(&params, ",");
> +		char *value;
> +
> +		if (!key)
> +			break;
> +
> +		value =3D strchr(key, '=3D');
> +		if (!value)
> +			continue;
> +
> +		*value++ =3D '\0';
> +
> +		if (!strcmp(key, "host"))
> +			host =3D value;
> +		else if (!strcmp(key, "port"))
> +			port =3D value;
> +		else if (!strcmp(key, "family"))
> +			family =3D value;
> +		else if (!strcmp(key, "guid"))
> +			guid =3D value;
> +	}
> +
> +	if (!host || !port)
> +		return NULL;
> +
> +	port_number =3D strtoul(port, NULL, 10);
> +
> +	if (port_number =3D=3D 0 || port_number >=3D 65536)
> +		return NULL;
> +
> +	memset(&hints, 0, sizeof(hints));
> +
> +	hints.ai_family =3D AF_UNSPEC;
> +	if (family) {
> +		if (!strcmp(family, "ipv4"))
> +			hints.ai_family =3D AF_INET;
> +		else if (!strcmp(family, "ipv6"))
> +			hints.ai_family =3D AF_INET6;
> +	}
> +
> +	hints.ai_socktype =3D SOCK_STREAM;
> +	hints.ai_flags =3D 0;
> +	hints.ai_protocol =3D 0;
> +
> +	if (getaddrinfo(host, port, &hints, &results) !=3D 0)
> +		return NULL;

So are you intending to support hostname resolution here?  Since you're =

not passing AI_NUMERICHOST or friends, I assume that you do.  Again, =

this means that you're blocking the library.

Non-blocking address resolution is actually a huge pain.  You can try to =

do threads, but since the rest of ell isn't thread safe, this is tricky. =

  The real solution is to port something like g_resolv from ConnMan to ell.

If you can live with only accepting IP addresses here, then that's what =

I would do first and live with the limitation until a non-blocking =

address resolution is added to ell.

> +
> +	for (rp =3D results, is_connected =3D false;
> +	     rp !=3D NULL && !is_connected; rp =3D rp->ai_next) {
> +		fd =3D socket(rp->ai_family, rp->ai_socktype | SOCK_NONBLOCK,
> +			    rp->ai_protocol);
> +		if (fd < 0)
> +			continue;
> +
> +		if (!connect(fd, rp->ai_addr, rp->ai_addrlen))
> +			break;
> +
> +		err =3D errno;
> +
> +		if (err !=3D EINPROGRESS) {
> +			close(fd);
> +			continue;
> +		}
> +
> +		io_connect =3D l_io_new(fd);
> +		l_io_set_write_handler(io_connect,
> +				       on_tcp_connected, &is_connected, NULL);
> +		l_main_iterate(1000);

Yikes.  Please don't do this, we don't do nested or re-entrant event =

loops and l_main_iterate is only meant to be used by integration with =

3rd library event loops.

> +		if (is_connected)
> +			l_io_destroy(io_connect);
> +	}
> +
> +	freeaddrinfo(results);
> +
> +	return setup_dbus1(fd, guid, "tcp");
>   }
>   =

>   static struct l_dbus *setup_address(const char *address)
> @@ -1170,6 +1281,9 @@ static struct l_dbus *setup_address(const char *add=
ress)
>   			/* Function will modify params string */
>   			dbus =3D setup_unix(params);
>   			break;
> +		} else if (!strcmp(transport, "tcp")) {
> +			dbus =3D setup_tcp(params);
> +			break;
>   		}
>   	}
>   =

> @@ -1232,6 +1346,7 @@ LIB_EXPORT void l_dbus_destroy(struct l_dbus *dbus)
>   =

>   	l_free(dbus->guid);
>   	l_free(dbus->unique_name);
> +	l_free(dbus->transport);
>   =

>   	_dbus_object_tree_free(dbus->tree);
>   =

> =


Regards,
-Denis

--===============5830579741845269323==--

