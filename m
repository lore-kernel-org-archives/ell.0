Content-Type: multipart/mixed; boundary="===============0501647777312770530=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] rtnl: add 'power_up' flag to l_rtnl_set_mac
Date: Thu, 12 Mar 2020 10:43:51 -0500
Message-ID: <7bbe08bb-79db-cc7f-b96c-a275b3fa652e@gmail.com>
In-Reply-To: <20200311225154.1322714-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0501647777312770530==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 3/11/20 5:51 PM, James Prestwood wrote:
> The use of l_rtnl_set_mac in IWD is always followed by powering up the
> device. Bringing the device back up requires calling l_rtnl_set_powered
> which makes another async call into the kernel. In order to reduce
> complexity we can include the IFF_UP flag to the MAC change message which
> will both change the MAC and bring the interface up all in one go.
> =

> The existing behavior is maintained by passing false to 'power_up'.
> ---
>   ell/rtnl.c | 5 +++++
>   ell/rtnl.h | 1 +
>   2 files changed, 6 insertions(+)
> =


Applied, thanks.

Regards,
-Denis

--===============0501647777312770530==--

