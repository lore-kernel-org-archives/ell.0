Content-Type: multipart/mixed; boundary="===============0893403695941327257=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] util: Add L_AUTO_FREE_OBJ and l_steal_ptr macros
Date: Mon, 08 Mar 2021 14:02:44 -0600
Message-ID: <69e55da7-008a-0fb5-6d9d-026aeab79e7f@gmail.com>
In-Reply-To: <CAOq732LPcHBhqXb+TQv4Af2p+m5b3J1UHbe+__v17jYjDZgAYA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0893403695941327257==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>> Given the above and the fact that L_AUTO_CLEANUP_VAR was never really us=
ed (it
>> is used in ell once), my vote would be to simply hijack that macro.  The=
n we can
>> write things like:
>>
>> L_AUTO_CLEANUP_VAR(struct l_settings *, settings, l_settings_free);
> =

> Re-using L_AUTO_CLEANUP_VAR makes sense but I think the name and
> parameters are too long for it to be attractive to use.  It would

Yes.  Ideally we could do _cleanup() instead.

> mainly make sense if the individual classes' headers use it to define
> their own macros.  On the other hand in that scenario the headers can
> define global cleanup functions without using the nested function
> magic.

I find this less desirable actually.  The nice thing about the nested funct=
ion =

approach is that you can easily use it for custom classes without needing t=
o use =

any extra macros.

> =

> I see one of the following forms as most usable:
> =

> l_settings_auto_ptr settings;
> l_settings_auto_ptr *settings;
> l_auto_ptr(l_settings) settings;
> l_auto_ptr(l_settings) *settings;

auto_ptr is some C++-ism though, so that might not be the best candidate.

> =

> The l_auto_ptr() macro would rely on settings.h defining a cleanup
> function whose name can be derived by preppending and/or appending
> something to "l_settings".

And this is another down side.

How about something like:
#define __CLEANUP(var, func)                           \
         void cleanup_ ## var(void *ptr)                \
         { func(*(void **) ptr); }                      \
         __attribute((cleanup(cleanup_ ## var)))

#define _CLEANUP(var, func)                            \
         __CLEANUP(var, func)

#define _cleanup(func)                                 \
         _CLEANUP(__COUNTER__, func)

void foo()
{
	_cleanup(destructor) struct something *s =3D
					constructor();
}

Regards,
-Denis
--===============0893403695941327257==--

