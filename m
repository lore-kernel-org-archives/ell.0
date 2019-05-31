Content-Type: multipart/mixed; boundary="===============3284796002545046298=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] netlink: Relax sequence check for the group notifications
Date: Fri, 31 May 2019 14:50:05 -0500
Message-ID: <bccf9ef4-17f1-ce0b-d5f8-0d399c093dfd@gmail.com>
In-Reply-To: <20190530202048.23766-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3284796002545046298==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

On 05/30/2019 03:20 PM, Tim Kourt wrote:
> Some of the RTNL groups such as RTNLGRP_IPV4_IFADDR set the
> sequence number in the header of the broadcasted messages.
> In order to be able to receive the such messages, we relax the
> check and allow the broadcasted messages with non-zero sequence
> numbers.
> ---
>   ell/netlink.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis


--===============3284796002545046298==--

