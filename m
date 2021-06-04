Content-Type: multipart/mixed; boundary="===============0567229809244402070=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] dhcp-server: Fix lease expiry time calculation
Date: Fri, 04 Jun 2021 19:35:35 +0200
Message-ID: <CAOq732+o4mhNgPD0O1Rhri5Bh9T_3zJo9vfEwAVJy_jyG3FNDg@mail.gmail.com>
In-Reply-To: <748fe26e-cc56-ef9c-95cd-480844486f35@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0567229809244402070==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Fri, 4 Jun 2021 at 18:49, Denis Kenzior <denkenz@gmail.com> wrote:
> On 6/1/21 6:53 PM, Andrew Zaborowski wrote:
> > We were comparing the l_time_now() (usecs) to lease->lifetime (secs)
> > and then converting the result from usecs to secs, so the "diff" and the
> > "to_secs" operations need to be switched around.  While there, use the
> > opportunity to replace the "diff" operation so that if lease->lifetime =
is
> > already in the past (e.g. because processing took to long), we schedule
> > the timeout in 1 millisec instead of the absolute value of the differen=
ce.
> >
> > Since we're using uint32_t for the timestamps, use the overflow-safe(r)
> > comparisons in set_next_expire_timer and in is_expired_lease.
> > ---
> >   ell/dhcp-server.c | 12 +++++++-----
> >   1 file changed, 7 insertions(+), 5 deletions(-)
> >
> > diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
> > index ebd4438..38193a2 100644
> > --- a/ell/dhcp-server.c
> > +++ b/ell/dhcp-server.c
> > @@ -104,7 +104,7 @@ struct l_dhcp_server {
> >
> >   static bool is_expired_lease(struct l_dhcp_lease *lease)
> >   {
> > -     if (lease->lifetime < l_time_to_secs(l_time_now()))
> > +     if ((int32_t) (lease->lifetime - l_time_to_secs(l_time_now())) < =
0)
>
> Why not use l_time_before / l_time_after.

l_time_after is basically what we currently have here (a simple "<'),
and the idea was to make the comparison a little safer just in case.

>  And with these changes I'm not sure
> there's any point to store lease->lifetime in seconds.  I suspect this wa=
s done
> originally to use 'second' versions of l_timeout_*.

Right, we could just convert it to the time.h format, uint64_t
microseconds, but it would break the API.

>
> >               return true;
> >
> >       return false;
> > @@ -191,7 +191,8 @@ static void set_next_expire_timer(struct l_dhcp_ser=
ver *server,
> >                                       struct l_dhcp_lease *expired)
> >   {
> >       struct l_dhcp_lease *next;
> > -     unsigned int next_timeout;
> > +     unsigned long next_timeout;
>
> Why unsigned long?  It is different between 32 bit and 64 bit, so if you =
need
> overflow protection, just use uint64_t instead?

"unsigned int" is the type of the l_timeout_modify parameter so I
changed it to the type of the l_timeout_modify_ms parameter since that
will limit the max value even if we pass a larger type.

>
> > +     uint32_t now;
> >
> >       /*
> >        * If this is an expiring lease put it into the expired queue, re=
moving
> > @@ -214,11 +215,12 @@ static void set_next_expire_timer(struct l_dhcp_s=
erver *server,
> >               return;
> >       }
> >
> > -     next_timeout =3D l_time_to_secs(l_time_diff(l_time_now(),
> > -                                                     next->lifetime));
> > +     now =3D l_time_to_secs(l_time_now());
> > +     next_timeout =3D (int32_t) (next->lifetime - now) > 0 ?
> > +             (next->lifetime - now) * 1000L : 1;
>
> Why 1000L?  next_timeout is unsigned?

My logic was to make sure the multiplication is treated as uint32_t *
long rather than uint32_t * int to avoid an overflow (if the result
fits in a long...).  I'm not sure if this is needed but checking with
gdb seems to indicate it is:

(gdb) print sizeof(int)
$1 =3D 4
(gdb) print sizeof(long)
$2 =3D 8
(gdb) print (unsigned int) 0x10000000 * 1000
$3 =3D 3892314112
(gdb) print (unsigned int) 0x10000000 * 1000L
$4 =3D 16777216000

>
> Also, why not use existing l_time_after, l_time_diff and l_time_to_msecs =
utilities?

As for l_time_after, I was trying to improve on the overflow safety a
bit like I mentioned in the commit.

As for l_time_diff, we can use it, I just thought it might be worth
saving that one extra comparison in it.

As for l_time_to_msecs we're converting from secs to msecs, not from
usecs to msecs, but I can use L_MSEC_PER_SEC instead of 1000L.

Best regards
--===============0567229809244402070==--

