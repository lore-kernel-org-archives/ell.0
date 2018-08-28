Content-Type: multipart/mixed; boundary="===============1601048338846956836=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] examples: dhcp_client: fix compile error
Date: Tue, 28 Aug 2018 10:15:21 -0500
Message-ID: <185923ab-0356-7b69-9cd3-4fb0516f67f3@gmail.com>
In-Reply-To: <1535128628-18528-1-git-send-email-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1601048338846956836==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 08/24/2018 11:37 AM, James Prestwood wrote:
> When building dhcp_client, it appears that including linux/if_arp.h
> requires sys/socket.h for the sockaddr definition (at least on my
> system). I fixed the same issue with ell/net.c but never build
> dhcp_client. Below is one of the errors I saw when building:
> =

> In file included from /usr/include/linux/netdevice.h:28,
>                   from /usr/include/linux/if_arp.h:26,
>                   from examples/dhcp-client.c:31:
> /usr/include/linux/if.h:234:19: error: field =E2=80=98ifru_addr=E2=80=99 =
has incomplete type
>     struct sockaddr ifru_addr;
> ---
>   examples/dhcp-client.c | 1 +
>   1 file changed, 1 insertion(+)
> =


Applied, thanks.

Regards,
-Denis

--===============1601048338846956836==--

