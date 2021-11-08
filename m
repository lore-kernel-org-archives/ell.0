Content-Type: multipart/mixed; boundary="===============3817168404344149613=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] dhcp6: Switch to BOUND before LEASE_OBTAINED
Date: Mon, 08 Nov 2021 08:42:39 -0600
Message-ID: <3027c204-e320-ce5f-458f-d6fa63ed7644@gmail.com>
In-Reply-To: 20211108112901.372486-1-andrew.zaborowski@intel.com

--===============3817168404344149613==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/8/21 5:29 AM, Andrew Zaborowski wrote:
> Reorder actions so that when we obtain the lease, we first switch to
> DHCP6_STATE_BOUND and configure the address + emit
> L_DHCP6_CLIENT_EVENT_LEASE_OBTAINED after that.  This allows the event
> handler to use l_dhcp6_client_get_lease().  l_dhcp6_client_get_lease is
> hardwired to return NULL in DHCP6_STATE_REQUESTING.
> =

> Issue reported by T=C3=A9rence Clastres.
> ---
>   ell/dhcp6.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis

--===============3817168404344149613==--

