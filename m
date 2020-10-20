Content-Type: multipart/mixed; boundary="===============5432106228018946363=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v6 1/6] dhcp-server: process DISCOVER and send OFFER
Date: Tue, 20 Oct 2020 09:57:19 -0500
Message-ID: <9d0763da-c187-0123-f9ca-1c574b38ec19@gmail.com>
In-Reply-To: <20201020013242.1575694-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5432106228018946363==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/19/20 8:32 PM, James Prestwood wrote:
> Add handling of DISCOVER messages and ability to send offers.
> ---
>   ell/dhcp-server.c | 330 ++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 330 insertions(+)
> =

> v6:
>   * Moved MAC_BCAST_ADDR to the patch where its used
>   * Removed NULL check from l_new
>   * Fixed some uses of htonl vs ntohl for consistency
>   * Converted the IP in find_free_or_expired_ip only
>     once rather than 3 separate times.
> =


Patches 1,2,6 applied thanks.

Regards,
-Denis

--===============5432106228018946363==--

