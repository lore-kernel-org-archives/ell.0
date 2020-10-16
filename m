Content-Type: multipart/mixed; boundary="===============7161410833864954912=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 01/14] dhcp-transport: rework 'broadcast' op to allow
 unicast
Date: Fri, 16 Oct 2020 13:58:46 -0500
Message-ID: <a11bbbf5-7616-2ae6-9ed4-f9e380f8fc41@gmail.com>
In-Reply-To: <20201016173914.804408-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7161410833864954912==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/16/20 12:39 PM, James Prestwood wrote:
> Functionally this was being used as a broadcast only because the
> destination address was a broadcast address. But providing a
> MAC address would effectively turn this into a unicast over l2
> which DHCP server requires.
> =

> To support server a destination MAC address was added to the
> arguments and if NULL the destination will be set to a broadcast
> address. The name of the op was changed to 'l2_send' to better
> describe the new behavior. All client code will remain nearly the
> same (just name changes) except having to set the destination MAC
> to NULL indicating it is a broadcast.
> ---
>   ell/dhcp-private.h   |  3 ++-
>   ell/dhcp-transport.c | 10 +++++++---
>   ell/dhcp.c           |  7 ++++---
>   3 files changed, 13 insertions(+), 7 deletions(-)
> =

> v3:
>   * Reworded commit description to be more clear that the original op
>     was a broadcast only operation and was modified to work with
>     both broadcast and unicast on l2
> =


Patches 1-3 applied, thanks.

Regards,
-Denis

--===============7161410833864954912==--

