Content-Type: multipart/mixed; boundary="===============0033614834544583238=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] util: Add L_AUTO_FREE_OBJ and l_steal_ptr macros
Date: Mon, 08 Mar 2021 15:50:34 -0600
Message-ID: <74e5d780-3bdd-c140-7de9-9396d8ee8367@gmail.com>
In-Reply-To: <CAOq732+O766srL=f-u0Nsd-WX+0h6hxxBgcJRgHebaQE_qR3Vw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0033614834544583238==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>> I find this less desirable actually.  The nice thing about the nested fu=
nction
>> approach is that you can easily use it for custom classes without needin=
g to use
>> any extra macros.
> =

> Right, but custom classes are one use case and ell classes are
> another.  We can add both a generic macro and an ell-specific or
> class-specific (e.g. l_settings-only) extra compact syntax.
> =


We can.  But if we can have a single macro that works for everything, I'd =

consider that to be a better approach.

>> How about something like:
>> #define __CLEANUP(var, func)                           \
>>           void cleanup_ ## var(void *ptr)                \
>>           { func(*(void **) ptr); }                      \
>>           __attribute((cleanup(cleanup_ ## var)))
>>
>> #define _CLEANUP(var, func)                            \
>>           __CLEANUP(var, func)
>>
>> #define _cleanup(func)                                 \
>>           _CLEANUP(__COUNTER__, func)
>>
>> void foo()
>> {
>>          _cleanup(destructor) struct something *s =3D
>>                                          constructor();
>> }
> =

> Make sense, one comment though:
> =

> I guess with _cleanup you want to make it shorter by skipping the "l",

Not really.  We can make it l_cleanup or l_auto or whichever...  I'm not =

particular to anything.  This was mostly a proof of concept

> but for the internal macros there's no reason not to make them more
> descriptive (e.g. something that hints on how _CLEANUP and __CLEANUP
> differ from _cleanup and from each other) and perhaps also use the L_
> prefix to tidiness.  All three are pretty short names and not unlikely
> for someone to be using already.

Sure.

Regards,
-Denis
--===============0033614834544583238==--

