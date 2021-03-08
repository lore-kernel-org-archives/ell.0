Content-Type: multipart/mixed; boundary="===============1437806317039943012=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] util: Add L_AUTO_FREE_OBJ and l_steal_ptr macros
Date: Mon, 08 Mar 2021 22:20:19 +0100
Message-ID: <CAOq732+O766srL=f-u0Nsd-WX+0h6hxxBgcJRgHebaQE_qR3Vw@mail.gmail.com>
In-Reply-To: <69e55da7-008a-0fb5-6d9d-026aeab79e7f@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1437806317039943012==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Mon, 8 Mar 2021 at 21:02, Denis Kenzior <denkenz@gmail.com> wrote:
>
> > mainly make sense if the individual classes' headers use it to define
> > their own macros.  On the other hand in that scenario the headers can
> > define global cleanup functions without using the nested function
> > magic.
>
> I find this less desirable actually.  The nice thing about the nested fun=
ction
> approach is that you can easily use it for custom classes without needing=
 to use
> any extra macros.

Right, but custom classes are one use case and ell classes are
another.  We can add both a generic macro and an ell-specific or
class-specific (e.g. l_settings-only) extra compact syntax.

>
> >
> > I see one of the following forms as most usable:
> >
> > l_settings_auto_ptr settings;
> > l_settings_auto_ptr *settings;
> > l_auto_ptr(l_settings) settings;
> > l_auto_ptr(l_settings) *settings;
>
> auto_ptr is some C++-ism though, so that might not be the best candidate.

Right, I didn't remember that until Phil mentioned it, I take back
these name ideas.

>
> >
> > The l_auto_ptr() macro would rely on settings.h defining a cleanup
> > function whose name can be derived by preppending and/or appending
> > something to "l_settings".
>
> And this is another down side.
>
> How about something like:
> #define __CLEANUP(var, func)                           \
>          void cleanup_ ## var(void *ptr)                \
>          { func(*(void **) ptr); }                      \
>          __attribute((cleanup(cleanup_ ## var)))
>
> #define _CLEANUP(var, func)                            \
>          __CLEANUP(var, func)
>
> #define _cleanup(func)                                 \
>          _CLEANUP(__COUNTER__, func)
>
> void foo()
> {
>         _cleanup(destructor) struct something *s =3D
>                                         constructor();
> }

Make sense, one comment though:

I guess with _cleanup you want to make it shorter by skipping the "l",
but for the internal macros there's no reason not to make them more
descriptive (e.g. something that hints on how _CLEANUP and __CLEANUP
differ from _cleanup and from each other) and perhaps also use the L_
prefix to tidiness.  All three are pretty short names and not unlikely
for someone to be using already.

Best regards
--===============1437806317039943012==--

