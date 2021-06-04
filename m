Content-Type: multipart/mixed; boundary="===============6238057577313650597=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] dhcp-server: Fix lease expiry time calculation
Date: Fri, 04 Jun 2021 20:34:26 +0200
Message-ID: <CAOq732L3vCwm-OGKd4gYs+ne1MDcLc3U_qU7hepb_EUc982Sgg@mail.gmail.com>
In-Reply-To: <c39a0d15-9977-7f7c-1f2f-48402c830fa9@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6238057577313650597==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 4 Jun 2021 at 20:00, Denis Kenzior <denkenz@gmail.com> wrote:
> On 6/4/21 12:35 PM, Andrew Zaborowski wrote:
> > On Fri, 4 Jun 2021 at 18:49, Denis Kenzior <denkenz@gmail.com> wrote:
> >> Why not use l_time_before / l_time_after.
> >
> > l_time_after is basically what we currently have here (a simple "<'),
> > and the idea was to make the comparison a little safer just in case.
>
> We avoid the whole Y2038 problem by using uint64_t and l_time* utilities.=
  So
> why make things 'a little' safer, when you can make them fully safe? :)

It's the "commit early, commit often" kind of question, we have a
completely broken lease expiry here so the main goal was to make it
even work and then while I was changing that line... it felt wrong to
not make such a simple improvement, and then edited this line for
consistency with that line but without delving into the reasons this
uses uint32_t.

>
> >
> >>   And with these changes I'm not sure
> >> there's any point to store lease->lifetime in seconds.  I suspect this=
 was done
> >> originally to use 'second' versions of l_timeout_*.
> >
> > Right, we could just convert it to the time.h format, uint64_t
> > microseconds, but it would break the API.
> >
>
> What API?

l_dhcp_lease_get_lifetime, though I guess you could just add a second
getter for the full resolution value.

>
> >>
> >>>                return true;
> >>>
> >>>        return false;
> >>> @@ -191,7 +191,8 @@ static void set_next_expire_timer(struct l_dhcp_s=
erver *server,
> >>>                                        struct l_dhcp_lease *expired)
> >>>    {
> >>>        struct l_dhcp_lease *next;
> >>> -     unsigned int next_timeout;
> >>> +     unsigned long next_timeout;
> >>
> >> Why unsigned long?  It is different between 32 bit and 64 bit, so if y=
ou need
> >> overflow protection, just use uint64_t instead?
> >
> > "unsigned int" is the type of the l_timeout_modify parameter so I
> > changed it to the type of the l_timeout_modify_ms parameter since that
> > will limit the max value even if we pass a larger type.
>
> So just FYI, sizeof(unsigned long) =3D=3D sizeof(unsigned int) on 32 bit.

Sure...

>  So you're
> actually introducing differing behavior depending on the platform.  This =
is the
> point I'm making above...

It's l_timeout_modify_ms that introduced this behaviour really, we
can't get around it by using a different type for the variable.  In
fact it might add to the confusion if we do.

>
> >
> >>
> >>> +     uint32_t now;
> >>>
> >>>        /*
> >>>         * If this is an expiring lease put it into the expired queue,=
 removing
> >>> @@ -214,11 +215,12 @@ static void set_next_expire_timer(struct l_dhcp=
_server *server,
> >>>                return;
> >>>        }
> >>>
> >>> -     next_timeout =3D l_time_to_secs(l_time_diff(l_time_now(),
> >>> -                                                     next->lifetime)=
);
> >>> +     now =3D l_time_to_secs(l_time_now());
> >>> +     next_timeout =3D (int32_t) (next->lifetime - now) > 0 ?
> >>> +             (next->lifetime - now) * 1000L : 1;
> >>
> >> Why 1000L?  next_timeout is unsigned?
> >
> > My logic was to make sure the multiplication is treated as uint32_t *
> > long rather than uint32_t * int to avoid an overflow (if the result
>
> See above.  Also, shouldn't this be 1000UL/ULL?  Probably doesn't matter,=
 but if
> you're going through the trouble, might as well get it perfect...

It gets cast to an unsigned value in the end but why not.

>
> > fits in a long...).  I'm not sure if this is needed but checking with
> > gdb seems to indicate it is:
> >
> > (gdb) print sizeof(int)
> > $1 =3D 4
> > (gdb) print sizeof(long)
> > $2 =3D 8
>
> On 64 bit, sure...

Right, that's why I said *if* the result fits in a long.  If it
doesn't there's nothing you can do.

>
> > (gdb) print (unsigned int) 0x10000000 * 1000
> > $3 =3D 3892314112
> > (gdb) print (unsigned int) 0x10000000 * 1000L
> > $4 =3D 16777216000
> >
> >>
> >> Also, why not use existing l_time_after, l_time_diff and l_time_to_mse=
cs utilities?
> >
> > As for l_time_after, I was trying to improve on the overflow safety a
> > bit like I mentioned in the commit.
>
> I suspect you need a sanity check regardless if the l_time_to_msec conver=
sion
> results in something > UINT_MAX since the result is just truncated and th=
at is
> likely not what you want anyway.

I guess the behaviour (if we want to worry about it) should be that if
the expiry time is too far out into the future then we set the longest
timeout we can with the current API, and then in lease_expired_cb() we
just reschedule the timeout if the lease has not expired, possibly
this is what you mean too.

Best regards
--===============6238057577313650597==--

