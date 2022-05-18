Content-Type: multipart/mixed; boundary="===============4303006036115959268=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] dhcp: Use bound_time for retransmission timers
Date: Wed, 18 May 2022 11:21:45 -0500
Message-ID: <a1c01d0b-5cb9-9ca6-2da4-c7f99cd1c9ff@gmail.com>
In-Reply-To: 20220511172855.25992-1-denkenz@gmail.com

--===============4303006036115959268==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 5/11/22 12:28, Denis Kenzior wrote:
> start_t is used to try and calculate the retransmission timeout value
> when the client enters RENEWING or REBINDING state.  This works fine on
> the first renewal since the client start timestamp and the lease bound
> timestamp are very close.  Also, the RENEW request is sent immediately
> whenever the T1 timer expires and most of the time it succeeds.
> =

> However, if this isn't a first renewal attempt and the RENEW request
> sent when the T1 timer expires is not successful, then the renewal
> timeout value could become too large.  Fix that by using the lease
> bound_time for the retransmission timer calculation (as intended) intead
> of the client start time (start_t).
> ---
>   ell/dhcp.c | 11 ++++++-----
>   1 file changed, 6 insertions(+), 5 deletions(-)
> =


Applied.

--===============4303006036115959268==--

