Content-Type: multipart/mixed; boundary="===============1437790037602407174=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v5 12/12] dhcp: Add support for setting address
Date: Mon, 19 Oct 2020 19:59:25 -0500
Message-ID: <cb0ffff4-2876-4a48-5f1c-4475ce5cfba8@gmail.com>
In-Reply-To: <20201019232814.1541221-12-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1437790037602407174==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/19/20 6:28 PM, James Prestwood wrote:
> Add optional support for the dhcp client to set the DHCP
> address automatically. This is done by providing an RTNL
> object with l_dhcp_client_set_rtnl.
> ---
>   ell/dhcp.c | 82 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/dhcp.h |  4 +++
>   2 files changed, 86 insertions(+)
> =

> v5:
>   * Made netmask/broadcast auto-free
> =


Applied, thanks.

Regards,
-Denis

--===============1437790037602407174==--

