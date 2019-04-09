Content-Type: multipart/mixed; boundary="===============4216325543871080671=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dbus: Add support to tcp address
Date: Tue, 09 Apr 2019 11:44:55 -0500
Message-ID: <cafac104-9103-25f4-eedf-4093b6bda2a7@gmail.com>
In-Reply-To: <20190331140042.6798-2-rhpr@cesar.org.br>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4216325543871080671==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ramon,

On 03/31/2019 09:00 AM, Ramon Henrique wrote:
> From: Ramon Ribeiro <rhpr@cesar.org.br>
> =

> This patch allows a dbus client to connect to a dbus-daemon server
> address listenning a TCP transport protocol
> ---
>   ell/dbus.c | 95 +++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++---
>   1 file changed, 91 insertions(+), 4 deletions(-)
> =

> diff --git a/ell/dbus.c b/ell/dbus.c
> index 92be396..256a70c 100644
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
> @@ -75,6 +77,7 @@ struct l_dbus_ops {
>   struct l_dbus {
>   	struct l_io *io;
>   	char *guid;
> +	char *transport;
>   	bool negotiate_unix_fd;
>   	bool support_unix_fd;
>   	bool is_ready;
> @@ -511,7 +514,10 @@ static bool auth_read_handler(struct l_io *io, void =
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
> @@ -1033,7 +1039,8 @@ static const struct l_dbus_ops classic_ops =3D {
>   	.name_acquire =3D classic_name_acquire,
>   };
>   =

> -static struct l_dbus *setup_dbus1(int fd, const char *guid)
> +static struct l_dbus *setup_dbus1(int fd, const char *guid,
> +				  const char *transport)
>   {
>   	static const unsigned char creds =3D 0x00;
>   	char uid[6], hexuid[12], *ptr =3D hexuid;
> @@ -1065,11 +1072,13 @@ static struct l_dbus *setup_dbus1(int fd, const c=
har *guid)
>   =

>   	dbus_init(dbus, fd);
>   	dbus->guid =3D l_strdup(guid);
> +	dbus->transport =3D l_strdup(transport);
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
> @@ -1145,7 +1154,81 @@ static struct l_dbus *setup_unix(char *params)
>   		return NULL;
>   	}
>   =

> -	return setup_dbus1(fd, guid);
> +	return setup_dbus1(fd, guid, "unix");
> +}
> +
> +static struct l_dbus *setup_tcp(char *params)
> +{
> +	struct addrinfo hints;
> +	struct addrinfo *results, *rp;
> +	char *host =3D NULL, *port =3D NULL, *family =3D NULL, *guid =3D NULL;
> +	int port_number =3D -1;
> +	int fd;
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
> +	port_number =3D atoi(port);

So in general, the use of atoi is discouraged.  Use strtoul or similar =

instead.  You have much finer understanding / control of the error =

conditions with strtoul.

> +
> +	if (port_number < 0 || port_number >=3D 65536)
> +		return NULL;

Hmm, according to D-Bus specification, port of zero is invalid (unless =

you're the server):

port	(number)	The tcp port the server will open. A zero value let the =

server choose a free port provided from the underlaying operating =

system. libdbus is able to retrieve the real used port from the server.

> +
> +	memset(&hints, 0, sizeof(hints));
> +
> +	if (family !=3D NULL && !strcmp(family, "ipv4"))
> +		hints.ai_family =3D AF_INET;
> +	else if (family !=3D NULL && !strcmp(family, "ipv6"))
> +		hints.ai_family =3D AF_INET6;
> +	else
> +		hints.ai_family =3D AF_UNSPEC;
> +
> +	hints.ai_socktype =3D SOCK_STREAM;
> +	hints.ai_flags =3D 0;
> +	hints.ai_protocol =3D 0;
> +
> +	if (getaddrinfo(host, port, &hints, &results) !=3D 0)
> +		return NULL;
> +
> +	for (rp =3D results; rp !=3D NULL; rp =3D rp->ai_next) {
> +		fd =3D socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
> +		if (fd < 0)
> +			continue;
> +
> +		if (connect(fd, rp->ai_addr, rp->ai_addrlen) !=3D -1)
> +			break;
> +

So you're using a blocking connect here that might take some time and =

are thus blocking the main event loop.  You can get away with this with =

AF_UNIX since the connection is local and probably nearly instantaneous. =

  With TCP I'm not sure this is a good idea...  Can we run the connect =

loop in a non-blocking fashion?

> +		close(fd);
> +	}
> +
> +	if (rp =3D=3D NULL)
> +		return NULL;
> +
> +	freeaddrinfo(results);
> +
> +	return setup_dbus1(fd, guid, "tcp");
>   }
>   =

>   static struct l_dbus *setup_address(const char *address)
> @@ -1170,6 +1253,9 @@ static struct l_dbus *setup_address(const char *add=
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

> @@ -1232,6 +1318,7 @@ LIB_EXPORT void l_dbus_destroy(struct l_dbus *dbus)
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

--===============4216325543871080671==--

