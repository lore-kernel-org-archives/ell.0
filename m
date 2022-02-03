Content-Type: multipart/mixed; boundary="===============8960186625651925987=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH v2] dhcp: handle multiple offers from the same server
Date: Thu, 03 Feb 2022 09:54:14 -0600
Message-ID: <3fc625c7-8c8c-ee72-bac3-c182b9ff8e51@gmail.com>
In-Reply-To: 20220131220350.3984579-1-prestwoj@gmail.com

--===============8960186625651925987==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 1/31/22 16:03, James Prestwood wrote:
> It was found that some DHCP servers send multiple offers on occation. Whe=
ther
> this is a bug or not its been seen in products and ELL should handle this
> gracefully.
> =

> The issue comes down to these DHCP servers expecting a request associated=
 with
> the last offer they send. The existing behavior in ELL is to ignore all o=
ffers
> after the initial, and continue resending requests for the original offer=
. When
> this happens the DHCP server never responds with an ACK.
> =

> The spec briefly outlines multiple DHCP offers but in the context of mult=
iple
> DHCP servers rather than multiple offers from the same DHCP server. In any
> case its left up to the DHCP client to choose whatever offer it wants, so=
 this
> is what ELL will do.
> =

> Now only the last offer will be used while in the REQUESTING state. If an=
other
> offer comes in before the ACK, that offer will be used and a new request =
will
> be sent out. Note this is only the case when the offers contain the same
> server ID as the first offer sent (this eliminates the multi DHCP server =
case
> and will maintain existing behavior, where the first offer is selected al=
ways).
> ---
>   ell/dhcp.c | 62 ++++++++++++++++++++++++++++++++++++++++++------------
>   1 file changed, 49 insertions(+), 13 deletions(-)
> =

> v2:
>   - Added a debug print in the multiple offer case
> =


I modified the commit description a bit and applied, thanks.

Regards,
-Denis

--===============8960186625651925987==--

