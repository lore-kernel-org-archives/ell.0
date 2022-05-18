Content-Type: multipart/mixed; boundary="===============4618834304473539786=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] dhcp,dhcp6,icmp6,time: Convert timestamps to
 CLOCK_BOOTTIME
Date: Wed, 18 May 2022 09:22:12 -0500
Message-ID: <199d1841-ae36-3c42-02ac-825f8a98a3a8@gmail.com>
In-Reply-To: CAOq732KHoZrEbf47m8NSa8suJ-EVV5yFAWWE8f22DFkVyTV-Qw@mail.gmail.com

--===============4618834304473539786==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>> By the way, given that you're using struct timespec below, do you want t=
o use
>> SO_TIMESTAMPNS?
> =

> It doesn't seem that this would simplify the arithmetics in this case.
> I wonder if we should bother to use the _NEW variant, which makes sure
> the timestamp is year 2038-proof on 32-bit systems.
> =


Probably might as well.

<snip>

>>> +     return ((int64_t) realtime.tv_sec - boottime.tv_sec) * 1000000 +
>>> +             ((int64_t) realtime.tv_nsec - boottime.tv_nsec) / 1000;
>>
>> Lets use the L_USEC_* defines when possible.
> =

> Ok.  (IIRC this was done for consistency with l_time_now)
> =


Ah, I need to fix that.  The problem is that this function was added before=
 the =

#defines existed.

I have now added commit:
bd5a2dc26441 ("time: Add converters from struct {timespec|timeval}")

Please review.

Regards,
-Denis
--===============4618834304473539786==--

