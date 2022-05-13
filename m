Content-Type: multipart/mixed; boundary="===============0224172005113890415=="
MIME-Version: 1.0
From: Michael Johnson <mjohnson459 at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] dhcp: Use bound_time for retransmission timers
Date: Fri, 13 May 2022 18:10:52 +0100
Message-ID: <CACsRnHU8uhpdyZwQXJrWo=EsKK-CmvO4OHoTBt_RnoDaBtRUhg@mail.gmail.com>
In-Reply-To: 8b5ce99b-55ad-53cf-fe82-4930735b420c@gmail.com

--===============0224172005113890415==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Great, thank you!

I'll run this patch on master over the weekend and see if I can get
more data for the other issue.

Regards,
Michael

On Fri, 13 May 2022 at 17:23, Denis Kenzior <denkenz(a)gmail.com> wrote:
>
> Hi Michael,
>
> On 5/13/22 10:40, Michael Johnson wrote:
> > Sorry, I put the log for the t2 retry. Putting it in the right place
> > gives us our problem though
> >
> > ```
> > May 13 15:38:34 r2-19006 iwd[39610]: [DHCPv4] dhcp_client_t1_expired:630
> > May 13 15:38:34 r2-19006 iwd[39610]: [DHCPv4]
> > dhcp_client_t1_expired:632 Entering state: DHCP_STATE_RENEWING
> > May 13 15:38:34 r2-19006 iwd[39610]: [DHCPv4] dhcp_client_send_request:=
397
> > May 13 15:38:34 r2-19006 iwd[39610]: [DHCPv4]
> > dhcp_client_t1_expired:642 next_timeout t2: 225
> > May 13 15:38:34 r2-19006 iwd[39610]: [DHCPv4]
> > dhcp_client_t1_expired:651 next_timeout t1 retry: 896458022
>
> Ugh, looks like commit:
> c78ad1bb6d7e ("dhcp: Set lease expiry based on frame reception times")
>
> broke this.  It is mixing up SO_TIMESTAMP which is from CLOCK_REALTIME an=
d our
> bound_time which is supposed to be in CLOCK_BOOTTIME.
>
> No wonder the timeout way too long :)
>
> Let me send another fixup patch.
>
> Regards,
> -Denis
--===============0224172005113890415==--

