Content-Type: multipart/mixed; boundary="===============2577689596871124714=="
MIME-Version: 1.0
From: Michael Johnson <mjohnson459 at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] dhcp: Use bound_time for retransmission timers
Date: Fri, 13 May 2022 16:31:39 +0100
Message-ID: <CACsRnHU-1HAumFSaz8150rH0Udt44_4dapeemngv_kkdRydXgA@mail.gmail.com>
In-Reply-To: 75266a95-e0b2-e375-3175-d45e605ed7c6@gmail.com

--===============2577689596871124714==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

I added those log lines and got this.

```
May 13 15:20:14 r2-19006 iwd[28716]: [DHCPv4]
dhcp_client_rx_message:949 T1 expiring in 299004 ms
May 13 15:20:14 r2-19006 iwd[28716]: [DHCPv4] l_acd_start:455 Skipping
probes and sending announcements
May 13 15:20:14 r2-19006 iwd[28716]: [DHCPv4]
announce_wait_timeout:166 No conflicts found for 10.101.8.24,
announcing address
May 13 15:20:14 r2-19006 iwd[28716]: [DHCPv4] acd_send_packet:146
sending packet with target IP 10.101.8.24
May 13 15:25:13 r2-19006 iwd[28716]: [DHCPv4] dhcp_client_t1_expired:630
May 13 15:25:13 r2-19006 iwd[28716]: [DHCPv4]
dhcp_client_t1_expired:632 Entering state: DHCP_STATE_RENEWING
May 13 15:25:13 r2-19006 iwd[28716]: [DHCPv4] dhcp_client_send_request:397
May 13 15:25:13 r2-19006 iwd[28716]: [DHCPv4]
dhcp_client_t1_expired:643 next_timeout: 225
May 13 15:28:58 r2-19006 iwd[28716]: [DHCPv4] dhcp_client_t2_expired:609
May 13 15:28:58 r2-19006 iwd[28716]: [DHCPv4]
dhcp_client_t2_expired:616 Entering state: DHCP_STATE_REBINDING
May 13 15:30:12 r2-19006 iwd[28716]: [DHCPv4] dhcp_client_lease_expired:598
```

Regards,
Michael

On Fri, 13 May 2022 at 15:30, Denis Kenzior <denkenz(a)gmail.com> wrote:
>
> Hi Michael,
>
> On 5/13/22 08:53, Michael Johnson wrote:
> > Hi Denis,
> >
> > I've been running this patch for the day and I don't think it's
> > actually fixed the retry. I have set a low lease time and then block
> > the DHCP server for the ACK and I can see that the retry still doesn't
> > happen.
>
> I suspect it does fix one bug, but not another...  I'm not near my test b=
ox
> right now, so debugging this is a bit painful.
>
> Could you debug-print the 'next_timeout' we calculate in
> dhcp_client_t1_expired() here:
>
>          next_timeout =3D dhcp_rebind_renew_retry_time(client->start_t,
>                                                          client->lease->t=
2);
>
> And also put in
>          L_WARN_ON(!client->timeout_resend);
>
> after the timeout_resend timer is created?
>
>  From your 'other' bug report yesterday, we calculate the t1 timer correc=
tly,
> but the timer still doesn't fire.
> It almost feels like the timers are just not being created.  Is there any=
thing
> suspicious in the kernel logs?
>
> Regards,
> -Denis
--===============2577689596871124714==--

