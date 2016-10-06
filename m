Content-Type: multipart/mixed; boundary="===============6485112520615241283=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: ELL API changes before stabilizing
Date: Thu, 06 Oct 2016 09:36:54 -0700
Message-ID: <alpine.OSX.2.20.1610060858360.28728@mjmartin-mac01.local>
In-Reply-To: <57F57FA0.7000509@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6485112520615241283==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Wed, 5 Oct 2016, Denis Kenzior wrote:

> Hi Mat,
>
> On 10/05/2016 04:45 PM, Mat Martineau wrote:
>> =

>> We will soon reach a point where breaking changes to the ELL APIs will
>> get a lot more painful - changes already create a headache for the
>> handful of projects we know about. Given that, I took a look over the
>> public headers to see if there were any obvious adjustments to be made,
>> and only found a few issues that jumped out at me.
>> =

>> =

>> 1. timeout: extra nanosecond APIs with extremely_long_function_names. We
>> could scrap the *_with_nanosecond calls and include nanoseconds in
>> l_timeout_create and l_timeout_modify.
>
> So the background on this is that oFono/ConnMan/BlueZ tend to use =

> g_timeout_add_seconds since it was supposedly cheaper than using the =

> g_timeout_add version.  Hence in ell we used the seconds as the 'preferre=
d' =

> version and introduced l_idle class as a g_timeout_add(0, ...) replacemen=
t.

Until just now, I thought l_idle callbacks only ran when the event loop =

ran out of things to do (you know, when "idle"). It's good that it works =

the way it does since we don't want idle callbacks to get starved when =

there's lots of I/O, but add "l_idle" naming to my list as a (very) minor =

annoyance.

I think there's still a use case for a zero timeout when you want some =

recurring work to be triggered by either an event or the timer. It would =

be simpler to modify an existing timer with l_timeout_modify(0, ...) than =

it would be to remove the timer, use l_idle, and create an l_timeout again =

later. Right now this can be done by using a 1-nanosecond timeout, which =

isn't pretty. How about allowing 0 second/nanosecond values in =

l_timeout_modify but not _create?

> It is rare (non-existent in iwd & oFono) that we need timers that contain =

> both seconds and microseconds, it is usually one-or-the-other situation.
>
> Do we have any users of the nanosecond version? iwd doesn't use it curren=
tly.

Yes, that's why I cc'd Brian.

The nanosecond version has separate parameters for seconds and =

nanoseconds, and they are in use together to specify timeouts greater than =

one second with subsecond accuracy. So my proposal is to get rid of the =

seconds-only version and always include the nanoseconds (which can be =

easily set to 0).

struct l_timeout *l_timeout_create(time_t seconds,
 			long nanoseconds, l_timeout_notify_cb_t callback,
 			void *user_data, l_timeout_destroy_cb_t destroy);
void l_timeout_modify(struct l_timeout *timeout,
                                 unsigned int seconds, long nanoseconds);

>
>> =

>> =

>> 2. timeout: Why not use time_t for seconds? Yeah, 4 billion seconds
>> should be enough for anyone, but the same argument could be made for the
>> underlying struct timespec that's used for the system calls.
>
> What's the advantage besides requiring an extra #include? time_t is a lon=
g in =

> the end.  So on 32-bit you're not buying anything, and on 64-bit you're i=
n =

> overkill territory.

For relative timestamps, it's not a big deal. 136 years is a long time, =

even if it's not always a long int.

>> 3. main: We recently changed l_main_exit() to be a cleanup function. It
>> used to trigger an exit action. It would be more consistent to name the
>> function for what it does rather than when it should be run
>> (l_main_cleanup()?).
>
> We tend to use _init to init modules and _exit to tear them down.  So the =

> naming sort of makes sense.  I also like the symmetry between l_main_init=
 and =

> l_main_exit.
>
>> =

>> =

>> 4. uintset: Why does uintset_new() create a set with min =3D=3D 1? C
>> programmers are more likely to assume it's 0-indexed. Maybe we don't
>> need both l_uintset_new and l_uintset_new_from_range. One function that
>> takes min and max seems sufficient.
>> =

>
> This class was a straight up port from ofono's idmap utility.  It is =

> generally used where 0 is not a valid value.  But I agree that having two =

> constructors is redundant.
>
>> =

>> Anything else you've noticed?
>> =

>
> Thanks for doing this btw, its still on my TODO list.



--
Mat Martineau
Intel OTC

--===============6485112520615241283==--

