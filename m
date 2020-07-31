Content-Type: multipart/mixed; boundary="===============4223056191723510229=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] Fix side channel leak in l_ecc_scalar_new
Date: Fri, 31 Jul 2020 08:58:47 -0500
Message-ID: <908d7d4e-757b-fb99-2e1a-46fca11a2c12@gmail.com>
In-Reply-To: <20200731101607.2837.70296@ml01.vlan13.01.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4223056191723510229==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Daniel,

>> can we name this l_secure_memcmp?  Also, shouldn't a and b be const void=
 *?
> =

> As long as size is the byte size of the array, a and b can be const void =
*. Our only constraint is to work with aa and bb as uint8 * so yes, this ca=
n be changed.

Right, this is fine.

> =

>> any particular reason to use int8 here?  memcmp returns an int and offer=
s no
>> particular contract on the values that can be returned...
> =

> I guess returning an int would work too, and we don't actually need -1/0/=
1 but negative/0/positive. I set it to uint8_t  "by default", because I mad=
e l_secure_memcmp to work with the util_secure_select (see the patch in iwd=
), which take a uint8 flag of value 0/0xFF.
> I thought returning fixed values made it easier to use afterward (as a ma=
sk for secure selection for instance).

So the reason I'd like to avoid returning an int8 is purely to follow the s=
ame =

signature / semantics as memcmp.  Returning an int8 here just feels strange=
...

It probably doesn't matter much in practice but it is nice to be consistent=
.  It =

also saves us a few extra arithmetic operations at the end.

> =

>> Is this needed if we return an int?  You could change
>> util_secure_fill_with_msb() to use a uint32_t instead of uint8.  Then th=
is
>> re-scaling step is unnecessary, right?
> =

> It seems right to me, util_secure_fill_with_msb could even be used to per=
form the operation inplace on a void *.
> Asking out of curiosity: is there a particular reason to want uint32_t in=
stead of uint8_t when the latter works fine ?

Going to a uint32 is just a side-effect of l_secure_memcmp returning an int=
. =

You need the extra width since the sign bit is now bit 31 instead of 7.  No =

other reason really.

> =

>>> + * representing an integer. Blobs are ordered in little endian. It ret=
urns
>>> + * -1, 0 or 1 if a < b, a =3D=3D b or a > b respectively.
>>> + */
>>> +static inline uint8_t l_secure_memcmp_64(const uint64_t *a, const uint=
64_t *b,
>>
>> This function is only useful for ecc and related parts.  In fact we trie=
d very
>> hard to hide the ecc implementation details (like the uint64_t arrays
>> representing the points) in data structures that are opaque to the outsi=
de
>> world.  So there's really no reason to expose this in util.h.
>>
>> I would move this to ecc.c directly or perhaps ecc-private.h if you fore=
see
>> needing to replace some / all instances of _vli_cmp in ell/ecc-external.=
c with
>> the secure version.
> =

> No problem for moving it in a different file. I would recommend ecc-priva=
te.h since I it should / will probably be needed elsewhere. At this point I=
 don't have enough knowledge of the library to say where, but basically any=
where you compare secret data to anything.
> I don't think all instances of _vli_cmp *should* be replaced, secure comp=
arison comes with a minor overhead, and is not always needed.

Yeah, I'm not sure about those _vli_cmp calls either.  Guess we can just pu=
t =

this in ecc-private and see how it goes.

> =

>> if l_secure_memcmp takes void, the aa_8 and bb_8 variables become unnece=
ssary
>> and you can simply pass &aa_64, &bb_64 directly.
> =

> Indeed, this can be change along with l_secure_memcmp signature.
> =

> Bottom line is: l_secure_memcmp can use const void *, which also makes l_=
secure_memcmp_64 cleaner. We can also make it return an int, without guaran=
tying particular value (only the sign), avoiding the final re-scaling.
> Returning uint8 is easier for future use with secure_select in iwd, but a=
 simple cast to uint8 would solve the problem.
> =


If the impact on the iwd side is trivial, then I'd prefer the int =

l_secure_memcmp(const void *, const void *, size_t) signature.

> I'm waiting for your advice (namely regarding switching the return type f=
rom uint8 to int) before making the changes in this patch and iwd's patch a=
ccordingly.
> By the way, how do I proceed ? Do I post the new version of the patch in =
this thread ?

Just git send-email another version with a [PATCHv2] prefix.  Doesn't need =
to be =

a reply to this thread.

Regards,
-Denis
--===============4223056191723510229==--

