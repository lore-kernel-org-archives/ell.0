Content-Type: multipart/mixed; boundary="===============6421527269857338005=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v5 02/12] dhcp-server: basic DHCP server skeleton
Date: Mon, 19 Oct 2020 19:43:25 -0500
Message-ID: <a458c1e4-9998-a760-447f-a7149db0e92b@gmail.com>
In-Reply-To: <20201019232814.1541221-2-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6421527269857338005==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/19/20 6:28 PM, James Prestwood wrote:
> ---
>   Makefile.am       |   1 +
>   ell/dhcp-server.c | 343 ++++++++++++++++++++++++++++++++++++++++++++++
>   ell/dhcp.h        |  36 +++++
>   ell/ell.sym       |  13 ++
>   4 files changed, 393 insertions(+)
>   create mode 100644 ell/dhcp-server.c
> =

> v5:
>   * Store start/end IP in host order. This fixes some endianness problems
>     when searching for the next available IP
>   * Fixed debug_destroy not getting set

<snip>

> +	/*
> +	 * Assign a default ip range if not already. This will default to
> +	 * server->address + 1 ... 254
> +	 */
> +	if (!server->start_ip) {
> +		server->start_ip =3D L_BE32_TO_CPU(server->address) + 1;
> +		server->end_ip =3D (server->start_ip & 0x00ffffff) | 0xfe000000;

Looks like the endianness got confused here, so I fixed this to use 0xfffff=
f00 =

and 0xfe respectively.

> +	}
> +

Applied, thanks.

Regards,
-Denis
--===============6421527269857338005==--

