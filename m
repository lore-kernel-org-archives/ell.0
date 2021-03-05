Content-Type: multipart/mixed; boundary="===============6058266491658011826=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] util: Add L_AUTO_FREE_OBJ and l_steal_ptr macros
Date: Sat, 06 Mar 2021 00:07:49 +0100
Message-ID: <CAOq732LPcHBhqXb+TQv4Af2p+m5b3J1UHbe+__v17jYjDZgAYA@mail.gmail.com>
In-Reply-To: <eb8f0f31-a7c5-3e35-b3f4-c26ad2a18ba6@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6058266491658011826==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Fri, 5 Mar 2021 at 22:02, Denis Kenzior <denkenz@gmail.com> wrote:
> On 3/4/21 3:53 PM, Andrew Zaborowski wrote:
> > L_AUTO_FREE_OBJ can be used for ell object types that define a
> > destructor named l_<type>_free such as l_settings_free().  The "FREE" in
> > the name hopefully is enough to communicate this.
> >
> > Some of our classes use l_<type>_destroy and similar names and some of
> > those functions, like l_queue_destroy, take additional parameters so for
> > those classes if a similar "AUTO" macros is wanted, it may be better
> > defined directly in that class's header.
> >
>
> I'd rather have the caller provide the destructor method itself rather th=
an the
> class.  That becomes a bit more generic as well.
>
> > l_steal_ptr is similar to g_steal_pointer except for being a macro.
> > Both macros can be used like in this example:
> >
>
> No objections from me
>
> > struct l_settings *load_settings(const char *path)
> > {
> >       L_AUTO_FREE_OBJ(l_settings, s) =3D l_settings_new();
> >
> >       if (!l_settings_load_from_file(s, path))
> >               return NULL;
> >
> >       return l_steal_ptr(s);
> > }
> > ---
> > This is an RFC.  L_AUTO_FREE_OBJ is based on James's idea.
> >
> >   ell/util.h | 8 ++++++++
> >   1 file changed, 8 insertions(+)
> >
> > diff --git a/ell/util.h b/ell/util.h
> > index b112878..94a4178 100644
> > --- a/ell/util.h
> > +++ b/ell/util.h
> > @@ -235,6 +235,11 @@ static inline void l_put_be64(uint64_t val, void *=
ptr)
> >   #define L_AUTO_FREE_VAR(vartype,varname) \
> >       vartype varname __attribute__((cleanup(auto_free)))
> >
> > +#define L_AUTO_FREE_OBJ(l_type,varname) \
> > +     void varname ## _auto_free(void *_ptr)          \
> > +             { l_type ## _free(*(void **) _ptr); }   \
> > +     L_AUTO_CLEANUP_VAR(struct l_type *, varname, varname ## _auto_fre=
e)
> > +
>
> Nested functions... Very clever!
>
> I ran a few experiments by changing out the L_AUTO_FREE_VAR macro to use =
the
> above pattern.  Something like:
>
> #define L_AUTO_FREE_VAR(vartype,varname) \
> void varname ## _auto_free(void *_ptr) \
> { l_free(*(void **) _ptr); } \
> vartype varname __attribute__((cleanup(varname ## _auto_free)))
>
> The resulting iwd code was the same size as the original, which seems to
> indicate that the nested function is always inlined.
>
> I also made some (somewhat primitive) experiments with writing several ve=
rsions
> of a simple function, both using this cleanup pattern and code without an=
y GCC
> extensions.  Both seemed to produce the same code after disassembly.
>
> Curious to see whether you or anyone else has different findings?

I haven't looked at the code size honestly.
>
> Given the above and the fact that L_AUTO_CLEANUP_VAR was never really use=
d (it
> is used in ell once), my vote would be to simply hijack that macro.  Then=
 we can
> write things like:
>
> L_AUTO_CLEANUP_VAR(struct l_settings *, settings, l_settings_free);

Re-using L_AUTO_CLEANUP_VAR makes sense but I think the name and
parameters are too long for it to be attractive to use.  It would
mainly make sense if the individual classes' headers use it to define
their own macros.  On the other hand in that scenario the headers can
define global cleanup functions without using the nested function
magic.

I see one of the following forms as most usable:

l_settings_auto_ptr settings;
l_settings_auto_ptr *settings;
l_auto_ptr(l_settings) settings;
l_auto_ptr(l_settings) *settings;

The l_auto_ptr() macro would rely on settings.h defining a cleanup
function whose name can be derived by preppending and/or appending
something to "l_settings".

Best regards
--===============6058266491658011826==--

