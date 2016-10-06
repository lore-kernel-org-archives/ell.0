Content-Type: multipart/mixed; boundary="===============3674019356365937506=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: ELL API changes before stabilizing
Date: Thu, 06 Oct 2016 12:03:37 -0500
Message-ID: <57F683E9.6090200@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1610060858360.28728@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3674019356365937506==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 10/06/2016 11:36 AM, Mat Martineau wrote:
>
> On Wed, 5 Oct 2016, Denis Kenzior wrote:
>
>> Hi Mat,
>>
>> On 10/05/2016 04:45 PM, Mat Martineau wrote:
>>>
>>> We will soon reach a point where breaking changes to the ELL APIs will
>>> get a lot more painful - changes already create a headache for the
>>> handful of projects we know about. Given that, I took a look over the
>>> public headers to see if there were any obvious adjustments to be made,
>>> and only found a few issues that jumped out at me.
>>>
>>>
>>> 1. timeout: extra nanosecond APIs with extremely_long_function_names. We
>>> could scrap the *_with_nanosecond calls and include nanoseconds in
>>> l_timeout_create and l_timeout_modify.
>>
>> So the background on this is that oFono/ConnMan/BlueZ tend to use
>> g_timeout_add_seconds since it was supposedly cheaper than using the
>> g_timeout_add version.  Hence in ell we used the seconds as the
>> 'preferred' version and introduced l_idle class as a g_timeout_add(0,
>> ...) replacement.
>
> Until just now, I thought l_idle callbacks only ran when the event loop
> ran out of things to do (you know, when "idle"). It's good that it works
> the way it does since we don't want idle callbacks to get starved when
> there's lots of I/O, but add "l_idle" naming to my list as a (very)
> minor annoyance.

l_idle is simply invoked the next time the event loop runs.  If we have =

idle objects scheduled, then the event loop will not sleep inside epoll, =

but instead run a tight-loop polling for file descriptor events. =

g_timeout_add(0, ...) is generally used to get out of re-entrancy =

conditions, which are tricky and lead to crashes.

>
> I think there's still a use case for a zero timeout when you want some
> recurring work to be triggered by either an event or the timer. It would

l_idle will call the callback until l_idle_remove is called. =

l_idle_oneshot is somewhat equivalent of g_timeout_add(0, ...)

> be simpler to modify an existing timer with l_timeout_modify(0, ...)
> than it would be to remove the timer, use l_idle, and create an
> l_timeout again later. Right now this can be done by using a
> 1-nanosecond timeout, which isn't pretty. How about allowing 0
> second/nanosecond values in l_timeout_modify but not _create?
>

Do we have an actual usecase ?  I'm failing to see the utility, but I =

may be missing something.

>> It is rare (non-existent in iwd & oFono) that we need timers that
>> contain both seconds and microseconds, it is usually one-or-the-other
>> situation.
>>
>> Do we have any users of the nanosecond version? iwd doesn't use it
>> currently.
>
> Yes, that's why I cc'd Brian.
>
> The nanosecond version has separate parameters for seconds and
> nanoseconds, and they are in use together to specify timeouts greater
> than one second with subsecond accuracy. So my proposal is to get rid of
> the seconds-only version and always include the nanoseconds (which can
> be easily set to 0).
>
> struct l_timeout *l_timeout_create(time_t seconds,
>              long nanoseconds, l_timeout_notify_cb_t callback,
>              void *user_data, l_timeout_destroy_cb_t destroy);
> void l_timeout_modify(struct l_timeout *timeout,
>                                  unsigned int seconds, long nanoseconds);
>

So then everyone pays the price of specifying seconds and nanoseconds =

when in reality 75% of calls will be the second version, 20% will be =

nanosecond version.  And the 5% outlier actually wants to specify both.

Not strictly against this, but just pointing out that ell API is =

supposed to be optimized for our actual usecases.  Perhaps we should just do
l_timeout_create, l_timeout_create_ms (oFono abuses sub-second timers, =

but it has zero need for nanosecond precision) and l_timeout_create_full =

to shorten the name.

Regards,
-Denis

--===============3674019356365937506==--

