Content-Type: multipart/mixed; boundary="===============8873503734451369470=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v5 09/12] unit: update dhcp test to use new builder APIs
Date: Mon, 19 Oct 2020 19:56:27 -0500
Message-ID: <86189ed2-052e-b580-7426-7a63cfbadc7c@gmail.com>
In-Reply-To: <20201019232814.1541221-9-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8873503734451369470==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/19/20 6:28 PM, James Prestwood wrote:
> ---
>   unit/test-dhcp.c | 83 +++++++++++++++++++++---------------------------
>   1 file changed, 37 insertions(+), 46 deletions(-)
> =


<snip>

> diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
> index 6ae8d71..955ed29 100644
> --- a/unit/test-dhcp.c
> +++ b/unit/test-dhcp.c
> @@ -33,7 +33,7 @@
>   #include <ell/ell.h>
>   #include "ell/dhcp-private.h"
>   =

> -static bool verbose =3D false;
> +static bool verbose =3D true;
>   static uint8_t client_packet[1024];
>   static size_t client_packet_len;
>   =


I squashed this part and applied.

Regards,
-Denis
--===============8873503734451369470==--

