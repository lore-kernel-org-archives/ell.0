Content-Type: multipart/mixed; boundary="===============5432869203415265357=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] dhcp: Use bound_time for retransmission timers
Date: Fri, 13 May 2022 11:23:52 -0500
Message-ID: <8b5ce99b-55ad-53cf-fe82-4930735b420c@gmail.com>
In-Reply-To: CACsRnHUuH6+BvLi3bm9F3eY_3t80bosroXYig9Dpg9O2eo+0aw@mail.gmail.com

--===============5432869203415265357==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Michael,

On 5/13/22 10:40, Michael Johnson wrote:
> Sorry, I put the log for the t2 retry. Putting it in the right place
> gives us our problem though
> =

> ```
> May 13 15:38:34 r2-19006 iwd[39610]: [DHCPv4] dhcp_client_t1_expired:630
> May 13 15:38:34 r2-19006 iwd[39610]: [DHCPv4]
> dhcp_client_t1_expired:632 Entering state: DHCP_STATE_RENEWING
> May 13 15:38:34 r2-19006 iwd[39610]: [DHCPv4] dhcp_client_send_request:397
> May 13 15:38:34 r2-19006 iwd[39610]: [DHCPv4]
> dhcp_client_t1_expired:642 next_timeout t2: 225
> May 13 15:38:34 r2-19006 iwd[39610]: [DHCPv4]
> dhcp_client_t1_expired:651 next_timeout t1 retry: 896458022

Ugh, looks like commit:
c78ad1bb6d7e ("dhcp: Set lease expiry based on frame reception times")

broke this.  It is mixing up SO_TIMESTAMP which is from CLOCK_REALTIME and =
our =

bound_time which is supposed to be in CLOCK_BOOTTIME.

No wonder the timeout way too long :)

Let me send another fixup patch.

Regards,
-Denis
--===============5432869203415265357==--

