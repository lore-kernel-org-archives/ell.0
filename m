Content-Type: multipart/mixed; boundary="===============8235677303022451005=="
MIME-Version: 1.0
From: daniel.de-almeida-braga@irisa.fr
Subject: Re: [PATCH] Fix side channel leak in l_ecc_scalar_new
Date: Fri, 31 Jul 2020 10:16:07 +0000
Message-ID: <20200731101607.2837.70296@ml01.vlan13.01.org>
In-Reply-To: <2a23cb92-0a31-1b3f-3ee5-715ab86914a0@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8235677303022451005==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,
Thank you for your insightful response!

Of course all typos can be corrected, and I could have swear I changed l_se=
cure_mem_cmp into l_secure_memcmp before committing...
Regarding the technical details, I am not an experienced developer, so I ma=
y miss some details, but here are my thoughts:

> can we name this l_secure_memcmp?  Also, shouldn't a and b be const void =
*?

As long as size is the byte size of the array, a and b can be const void *.=
 Our only constraint is to work with aa and bb as uint8 * so yes, this can =
be changed.

> any particular reason to use int8 here?  memcmp returns an int and offers=
 no =

> particular contract on the values that can be returned...

I guess returning an int would work too, and we don't actually need -1/0/1 =
but negative/0/positive. I set it to uint8_t  "by default", because I made =
l_secure_memcmp to work with the util_secure_select (see the patch in iwd),=
 which take a uint8 flag of value 0/0xFF.
I thought returning fixed values made it easier to use afterward (as a mask=
 for secure selection for instance).

> Is this needed if we return an int?  You could change =

> util_secure_fill_with_msb() to use a uint32_t instead of uint8.  Then thi=
s =

> re-scaling step is unnecessary, right?

It seems right to me, util_secure_fill_with_msb could even be used to perfo=
rm the operation inplace on a void *.
Asking out of curiosity: is there a particular reason to want uint32_t inst=
ead of uint8_t when the latter works fine ?

> > + * representing an integer. Blobs are ordered in little endian. It ret=
urns
> > + * -1, 0 or 1 if a < b, a =3D=3D b or a > b respectively.
> > + */
> > +static inline uint8_t l_secure_memcmp_64(const uint64_t *a, const uint=
64_t *b,
> =

> This function is only useful for ecc and related parts.  In fact we tried=
 very =

> hard to hide the ecc implementation details (like the uint64_t arrays =

> representing the points) in data structures that are opaque to the outsid=
e =

> world.  So there's really no reason to expose this in util.h.
> =

> I would move this to ecc.c directly or perhaps ecc-private.h if you fores=
ee =

> needing to replace some / all instances of _vli_cmp in ell/ecc-external.c=
 with =

> the secure version.

No problem for moving it in a different file. I would recommend ecc-private=
.h since I it should / will probably be needed elsewhere. At this point I d=
on't have enough knowledge of the library to say where, but basically anywh=
ere you compare secret data to anything.
I don't think all instances of _vli_cmp *should* be replaced, secure compar=
ison comes with a minor overhead, and is not always needed.

> if l_secure_memcmp takes void, the aa_8 and bb_8 variables become unneces=
sary =

> and you can simply pass &aa_64, &bb_64 directly.

Indeed, this can be change along with l_secure_memcmp signature.

Bottom line is: l_secure_memcmp can use const void *, which also makes l_se=
cure_memcmp_64 cleaner. We can also make it return an int, without guaranty=
ing particular value (only the sign), avoiding the final re-scaling. =

Returning uint8 is easier for future use with secure_select in iwd, but a s=
imple cast to uint8 would solve the problem.

I'm waiting for your advice (namely regarding switching the return type fro=
m uint8 to int) before making the changes in this patch and iwd's patch acc=
ordingly.
By the way, how do I proceed ? Do I post the new version of the patch in th=
is thread ?

Regards,

Daniel
--===============8235677303022451005==--

