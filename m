Content-Type: multipart/mixed; boundary="===============2790245947272326229=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 04/20] dhcp-util: move iter APIs to dhcp-util
Date: Fri, 16 Oct 2020 11:24:36 -0500
Message-ID: <e74be869-0d99-406a-8f3c-6f655ac17aca@gmail.com>
In-Reply-To: <20201016153635.660391-4-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2790245947272326229==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 10/16/20 10:36 AM, James Prestwood wrote:
> These were already exposed for use elsewhere but dhcp-util
> is a better home for these APIs.
> ---
>   ell/dhcp-util.c | 160 ++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/dhcp.c      | 160 ------------------------------------------------
>   2 files changed, 160 insertions(+), 160 deletions(-)

I went ahead and applied patches 1, 9, 2, 3, 4 in that order.  Patch 2 depe=
nded =

on some defines which weren't moved until patch 9.

Regards,
-Denis

--===============2790245947272326229==--

