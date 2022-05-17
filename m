Content-Type: multipart/mixed; boundary="===============7883261128423257117=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH] dhcp, dhcp6, icmp6,
 time: Convert timestamps to CLOCK_BOOTTIME
Date: Wed, 18 May 2022 01:29:42 +0200
Message-ID: <CAOq732KHoZrEbf47m8NSa8suJ-EVV5yFAWWE8f22DFkVyTV-Qw@mail.gmail.com>
In-Reply-To: bc24661a-7fcb-01f7-62de-da38f82b9e34@gmail.com

--===============7883261128423257117==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Tue, 17 May 2022 at 16:37, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 5/16/22 16:31, Andrew Zaborowski wrote:
> >
> > -                     timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->t=
v_usec;
> > +                     /*
> > +                      * Not ideal but this is our best approximation o=
f the
> > +                      * CLOCK_BOOTTIME-based Rx time.
> > +                      */
> > +                     timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->t=
v_usec -
> > +                             _time_get_realtime_boottime_offset();
>
> Can we actually just send the timestamp as a 'struct timeval' to the priv=
ate
> function?  Instead of duplicating the conversion calculation everywhere?

Ok.  (The idea was that having the offset you can convert in either directi=
on)

>
> >               }
> >       }
> >
>
> <snip>
>
> > diff --git a/ell/time.c b/ell/time.c
> > index d02dabe..cda09be 100644
> > --- a/ell/time.c
> > +++ b/ell/time.c
> > @@ -105,3 +105,20 @@ uint64_t _time_fuzz_secs(uint32_t secs, uint32_t m=
ax_offset)
> >
> >       return ms;
> >   }
> > +
> > +/*
> > + * Get approximate difference between CLOCK_REALTIME and CLOCK_BOOTTIM=
E,
> > + * for converting recent timestamps from one to the other.  The value =
can
> > + * change at any time.
> > + */
> > +int64_t _time_get_realtime_boottime_offset(void)
>
> So I would avoid signed integers for these calculations.  We already have
> l_time_before/l_time_after.  And l_time_offset takes care of overflows.  =
Lets
> use those to implement this.  You also need to consider potential underfl=
ow,
> though it is probably astronomically unlikely.

Either int64_t or uin64_t should have worked for overflows and
underflows as long as we operate on 64-bit numbers throughout.

>
> I'd name this something like:
>
> uint64_t _time_realtime_to_boottime(const struct timeval *ts)
>
> By the way, given that you're using struct timespec below, do you want to=
 use
> SO_TIMESTAMPNS?

It doesn't seem that this would simplify the arithmetics in this case.
I wonder if we should bother to use the _NEW variant, which makes sure
the timestamp is year 2038-proof on 32-bit systems.

>
> > +{
> > +     struct timespec boottime;
> > +     struct timespec realtime;
> > +
> > +     clock_gettime(CLOCK_BOOTTIME, &boottime);
> > +     clock_gettime(CLOCK_REALTIME, &realtime);
> > +
>
> Then here do something like:
>
> offset =3D l_time_diff(ts, now_realtime);
>
> /* most likely case, timestamp in the past */
> if (l_time_before(ts, now_realtime)) {
>         if (offset > now_boot)
>                 return 0;
>
>         return now_boot - offset;
> }
>
> return l_time_offset(now_boot, offset);

This is a complicated way to perform two subtractions but ok ;-)

>
> > +     return ((int64_t) realtime.tv_sec - boottime.tv_sec) * 1000000 +
> > +             ((int64_t) realtime.tv_nsec - boottime.tv_nsec) / 1000;
>
> Lets use the L_USEC_* defines when possible.

Ok.  (IIRC this was done for consistency with l_time_now)

Best regards
--===============7883261128423257117==--

