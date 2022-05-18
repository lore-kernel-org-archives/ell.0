Content-Type: multipart/mixed; boundary="===============3748876485744749530=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH] dhcp, dhcp6, icmp6,
 time: Convert timestamps to CLOCK_BOOTTIME
Date: Wed, 18 May 2022 02:22:41 +0200
Message-ID: <CAOq732LjeGeVDQv_Zb21PeubdU-ZcJ0mDovbi8BmfLYUWigt8A@mail.gmail.com>
In-Reply-To: CAOq732KHoZrEbf47m8NSa8suJ-EVV5yFAWWE8f22DFkVyTV-Qw@mail.gmail.com

--===============3748876485744749530==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Wed, 18 May 2022 at 01:29, Andrew Zaborowski
<andrew.zaborowski(a)intel.com> wrote:
> On Tue, 17 May 2022 at 16:37, Denis Kenzior <denkenz(a)gmail.com> wrote:
> > So I would avoid signed integers for these calculations.  We already ha=
ve
> > l_time_before/l_time_after.  And l_time_offset takes care of overflows.=
  Lets
> > use those to implement this.  You also need to consider potential under=
flow,
> > though it is probably astronomically unlikely.
>
> Either int64_t or uin64_t should have worked for overflows and
> underflows as long as we operate on 64-bit numbers throughout.

Sorry, I didn't get which kind of overflow/underflow you meant.  You
could indeed have CLOCK_REALTIME-based timestamps that can't be
represented in CLOCK_BOOTTIME without an overflow or an underflow.

The resulting wrapped value would still work for calculating intervals
between frames, less so for expiry times if they still end up being
negative.

Best regards
--===============3748876485744749530==--

