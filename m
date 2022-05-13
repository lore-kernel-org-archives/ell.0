Content-Type: multipart/mixed; boundary="===============0389878507793986382=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] dhcp: Use bound_time for retransmission timers
Date: Fri, 13 May 2022 09:30:49 -0500
Message-ID: <75266a95-e0b2-e375-3175-d45e605ed7c6@gmail.com>
In-Reply-To: CACsRnHW6LNDMxhrZB-_7JAH3h3Q54D9vUqf-YJhfEg4FgBC-gA@mail.gmail.com

--===============0389878507793986382==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Michael,

On 5/13/22 08:53, Michael Johnson wrote:
> Hi Denis,
> =

> I've been running this patch for the day and I don't think it's
> actually fixed the retry. I have set a low lease time and then block
> the DHCP server for the ACK and I can see that the retry still doesn't
> happen.

I suspect it does fix one bug, but not another...  I'm not near my test box =

right now, so debugging this is a bit painful.

Could you debug-print the 'next_timeout' we calculate in =

dhcp_client_t1_expired() here:

         next_timeout =3D dhcp_rebind_renew_retry_time(client->start_t,
                                                         client->lease->t2);

And also put in
         L_WARN_ON(!client->timeout_resend);

after the timeout_resend timer is created?

 From your 'other' bug report yesterday, we calculate the t1 timer correctl=
y, =

but the timer still doesn't fire.
It almost feels like the timers are just not being created.  Is there anyth=
ing =

suspicious in the kernel logs?

Regards,
-Denis
--===============0389878507793986382==--

