Content-Type: multipart/mixed; boundary="===============8228167507624670243=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp: Fix address endianness in l2_send
Date: Fri, 04 Jun 2021 11:31:54 -0500
Message-ID: <c9dc9430-fbc9-ba24-a653-a1e5a81924fa@gmail.com>
In-Reply-To: <20210604012214.162251-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8228167507624670243==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 6/3/21 8:22 PM, Andrew Zaborowski wrote:
> dhcp_set_ip_udp_headers was unnecessarily trying to convert saddr and
> daddr from host byte order to network order, the addresses are already
> passsed in network byte order by the current 2 callers.  This wasn't
> breaking normal dhcp but could break P2P where the DHCP OFFER and ACK
> source address is used by the client:
> =

> DHCPOFFER of 192.168.1.2 from 1.1.168.192
> ---
>   ell/dhcp-transport.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> =


Funny, guess we brought some ConnMan bugs into ell.  Nice catch.  Applied, =
thanks.

Regards,
-Denis
--===============8228167507624670243==--

