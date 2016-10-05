Content-Type: multipart/mixed; boundary="===============1734915935132563779=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: ELL API changes before stabilizing
Date: Wed, 05 Oct 2016 17:33:04 -0500
Message-ID: <57F57FA0.7000509@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1610051332130.26281@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1734915935132563779==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 10/05/2016 04:45 PM, Mat Martineau wrote:
>
> We will soon reach a point where breaking changes to the ELL APIs will
> get a lot more painful - changes already create a headache for the
> handful of projects we know about. Given that, I took a look over the
> public headers to see if there were any obvious adjustments to be made,
> and only found a few issues that jumped out at me.
>
>
> 1. timeout: extra nanosecond APIs with extremely_long_function_names. We
> could scrap the *_with_nanosecond calls and include nanoseconds in
> l_timeout_create and l_timeout_modify.

So the background on this is that oFono/ConnMan/BlueZ tend to use =

g_timeout_add_seconds since it was supposedly cheaper than using the =

g_timeout_add version.  Hence in ell we used the seconds as the =

'preferred' version and introduced l_idle class as a g_timeout_add(0, =

...) replacement.

It is rare (non-existent in iwd & oFono) that we need timers that =

contain both seconds and microseconds, it is usually one-or-the-other =

situation.

Do we have any users of the nanosecond version? iwd doesn't use it =

currently.

>
>
> 2. timeout: Why not use time_t for seconds? Yeah, 4 billion seconds
> should be enough for anyone, but the same argument could be made for the
> underlying struct timespec that's used for the system calls.

What's the advantage besides requiring an extra #include? time_t is a =

long in the end.  So on 32-bit you're not buying anything, and on 64-bit =

you're in overkill territory.

>
>
> 3. main: We recently changed l_main_exit() to be a cleanup function. It
> used to trigger an exit action. It would be more consistent to name the
> function for what it does rather than when it should be run
> (l_main_cleanup()?).

We tend to use _init to init modules and _exit to tear them down.  So =

the naming sort of makes sense.  I also like the symmetry between =

l_main_init and l_main_exit.

>
>
> 4. uintset: Why does uintset_new() create a set with min =3D=3D 1? C
> programmers are more likely to assume it's 0-indexed. Maybe we don't
> need both l_uintset_new and l_uintset_new_from_range. One function that
> takes min and max seems sufficient.
>

This class was a straight up port from ofono's idmap utility.  It is =

generally used where 0 is not a valid value.  But I agree that having =

two constructors is redundant.

>
> Anything else you've noticed?
>

Thanks for doing this btw, its still on my TODO list.

Regards,
-Denis


--===============1734915935132563779==--

