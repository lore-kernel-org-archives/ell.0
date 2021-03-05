Content-Type: multipart/mixed; boundary="===============0433904143316664428=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] util: Add L_AUTO_FREE_OBJ and l_steal_ptr macros
Date: Fri, 05 Mar 2021 15:02:11 -0600
Message-ID: <eb8f0f31-a7c5-3e35-b3f4-c26ad2a18ba6@gmail.com>
In-Reply-To: <20210304215358.838251-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0433904143316664428==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 3/4/21 3:53 PM, Andrew Zaborowski wrote:
> L_AUTO_FREE_OBJ can be used for ell object types that define a
> destructor named l_<type>_free such as l_settings_free().  The "FREE" in
> the name hopefully is enough to communicate this.
> =

> Some of our classes use l_<type>_destroy and similar names and some of
> those functions, like l_queue_destroy, take additional parameters so for
> those classes if a similar "AUTO" macros is wanted, it may be better
> defined directly in that class's header.
> =


I'd rather have the caller provide the destructor method itself rather than=
 the =

class.  That becomes a bit more generic as well.

> l_steal_ptr is similar to g_steal_pointer except for being a macro.
> Both macros can be used like in this example:
> =


No objections from me

> struct l_settings *load_settings(const char *path)
> {
> 	L_AUTO_FREE_OBJ(l_settings, s) =3D l_settings_new();
> =

> 	if (!l_settings_load_from_file(s, path))
> 		return NULL;
> =

> 	return l_steal_ptr(s);
> }
> ---
> This is an RFC.  L_AUTO_FREE_OBJ is based on James's idea.
> =

>   ell/util.h | 8 ++++++++
>   1 file changed, 8 insertions(+)
> =

> diff --git a/ell/util.h b/ell/util.h
> index b112878..94a4178 100644
> --- a/ell/util.h
> +++ b/ell/util.h
> @@ -235,6 +235,11 @@ static inline void l_put_be64(uint64_t val, void *pt=
r)
>   #define L_AUTO_FREE_VAR(vartype,varname) \
>   	vartype varname __attribute__((cleanup(auto_free)))
>   =

> +#define L_AUTO_FREE_OBJ(l_type,varname) \
> +	void varname ## _auto_free(void *_ptr)		\
> +		{ l_type ## _free(*(void **) _ptr); }	\
> +	L_AUTO_CLEANUP_VAR(struct l_type *, varname, varname ## _auto_free)
> +

Nested functions... Very clever!

I ran a few experiments by changing out the L_AUTO_FREE_VAR macro to use th=
e =

above pattern.  Something like:

#define L_AUTO_FREE_VAR(vartype,varname) \
void varname ## _auto_free(void *_ptr) \
{ l_free(*(void **) _ptr); } \
vartype varname __attribute__((cleanup(varname ## _auto_free)))

The resulting iwd code was the same size as the original, which seems to =

indicate that the nested function is always inlined.

I also made some (somewhat primitive) experiments with writing several vers=
ions =

of a simple function, both using this cleanup pattern and code without any =
GCC =

extensions.  Both seemed to produce the same code after disassembly.

Curious to see whether you or anyone else has different findings?

Given the above and the fact that L_AUTO_CLEANUP_VAR was never really used =
(it =

is used in ell once), my vote would be to simply hijack that macro.  Then w=
e can =

write things like:

L_AUTO_CLEANUP_VAR(struct l_settings *, settings, l_settings_free);

Or perhaps something like:

_cleanup(l_settings_free) struct l_settings *settings;

if we can use a UNIQUE_NAME type macro magic inside.

>   #define L_ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
>   =

>   void *l_malloc(size_t size) __attribute__ ((warn_unused_result, malloc)=
);

Regards,
-Denis
--===============0433904143316664428==--

