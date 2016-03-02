Content-Type: multipart/mixed; boundary="===============4149217885869967046=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 1/2] key: Add basic keystore support
Date: Wed, 02 Mar 2016 10:28:05 -0800
Message-ID: <alpine.OSX.2.20.1603020914380.2527@tjha-mobl.amr.corp.intel.com>
In-Reply-To: <56D71A0F.4040601@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4149217885869967046==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


Denis,

On Wed, 2 Mar 2016, Denis Kenzior wrote:

> Hi Mat,
>
> On 03/01/2016 06:23 PM, Mat Martineau wrote:
>> ---
>>   Makefile.am |   6 ++-
>>   ell/ell.h   |   1 +
>>   ell/key.c   | 155 =

>> ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>   ell/key.h   |  58 +++++++++++++++++++++++
>>   4 files changed, 218 insertions(+), 2 deletions(-)
>>   create mode 100644 ell/key.c
>>   create mode 100644 ell/key.h
>> =

>
> <snip>
>
>> diff --git a/ell/key.c b/ell/key.c
>> new file mode 100644
>> index 0000000..b6a1303
>> --- /dev/null
>> +++ b/ell/key.c
>> @@ -0,0 +1,155 @@
>> +/*
>> + *
>> + *  Embedded Linux library
>> + *
>> + *  Copyright (C) 2016  Intel Corporation. All rights reserved.
>> + *
>> + *  This library is free software; you can redistribute it and/or
>> + *  modify it under the terms of the GNU Lesser General Public
>> + *  License as published by the Free Software Foundation; either
>> + *  version 2.1 of the License, or (at your option) any later version.
>> + *
>> + *  This library is distributed in the hope that it will be useful,
>> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
>> + *  Lesser General Public License for more details.
>> + *
>> + *  You should have received a copy of the GNU Lesser General Public
>> + *  License along with this library; if not, write to the Free Software
>> + *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-13=
01 =

>> USA
>> + *
>> + */
>> +
>> +#ifdef HAVE_CONFIG_H
>> +#include <config.h>
>> +#endif
>> +
>> +#define _GNU_SOURCE
>> +#include <unistd.h>
>> +#include <sys/syscall.h>
>> +#include <linux/keyctl.h>
>> +
>> +#include "private.h"
>> +#include "util.h"
>> +#include "key.h"
>> +
>> +//DEBUG
>> +#include <stdio.h>
>
> Still needed?

No, I meant to remove that.

>> +
>> +#define is_valid_type(type) ((type) <=3D L_KEY_DH_PRIVATE)
>> +
>> +static int keyring_base;
>> +
>> +struct l_key {
>> +	int type;
>> +	long serial;
>> +};
>> +
>> +static long kernel_add_key(char *type, char *description,
>> +				const void *payload, size_t len, long =

>> keyring)
>> +{
>> +	return syscall(__NR_add_key, type, description, payload, len, =

>> keyring);
>> +}
>> +
>> +static long kernel_read_key(long serial, const void *payload, size_t le=
n)
>> +{
>> +	return syscall(__NR_keyctl, KEYCTL_READ, serial, payload, len);
>> +}
>> +
>> +static long kernel_update_key(long serial, const void *payload, size_t =

>> len)
>> +{
>> +	return syscall(__NR_keyctl, KEYCTL_UPDATE, serial, payload, len);
>> +}
>> +
>> +static long kernel_revoke_key(long serial)
>> +{
>> +	return syscall(__NR_keyctl, KEYCTL_REVOKE, serial);
>> +}
>> +
>> +static bool setup_keyring_base(void)
>> +{
>> +	keyring_base =3D kernel_add_key("keyring", "ell", 0, 0,
>> +					KEY_SPEC_THREAD_KEYRING);
>> +
>
> This is fine for now, but I think we might want to expose the concept of =

> keyrings in the future.
>

Yes, I'm planning on that.

>> +	if (keyring_base <=3D 0) {
>> +		keyring_base =3D 0;
>> +		return false;
>> +	}
>> +
>> +	return true;
>> +}
>> +
>> +LIB_EXPORT struct l_key *l_key_new(enum l_key_type type, const void =

>> *payload,
>> +					size_t payload_length)
>> +{
>> +	struct l_key *key;
>> +
>> +	if (unlikely(!payload))
>> +		return NULL;
>> +
>> +	if (unlikely(!is_valid_type(type)))
>> +		return NULL;
>> +
>> +	if (!keyring_base && !setup_keyring_base()) {
>> +		return NULL;
>> +	}
>> +
>> +	key =3D l_new(struct l_key, 1);
>> +	key->type =3D type;
>> +	key->serial =3D kernel_add_key("user", "testing", payload, =

>> payload_length,
>> +					keyring_base);
>> +
>> +	if (key->serial < 0) {
>> +		l_free(key);
>> +		key =3D NULL;
>> +	}
>> +
>> +	return key;
>> +}
>> +
>> +LIB_EXPORT void l_key_free(struct l_key *key)
>> +{
>> +	if (unlikely(!key))
>> +		return;
>> +
>> +	kernel_revoke_key(key->serial);
>> +
>> +	l_free(key);
>> +}
>> +
>> +LIB_EXPORT bool l_key_set_payload(struct l_key *key, void *payload, siz=
e_t =

>> len)
>
> I'm not sure I like the name.  Perhaps l_key_update?

Ok. That also aligns with the syscall terminology.

>> +{
>> +	long error;
>> +
>> +	if (unlikely(!key))
>> +		return false;
>> +
>> +	error =3D kernel_update_key(key->serial, payload, len);
>> +
>> +	return error =3D=3D 0;
>> +}
>> +
>> +LIB_EXPORT bool l_key_get_payload(struct l_key *key, void *payload, siz=
e_t =

>> *len)
>
> Maybe l_key_extract, l_key_extract_raw_bytes, l_key_get_raw_bytes?
>

I like l_key_extract

>> +{
>> +	long copied;
>> +
>> +	if (unlikely(!key))
>> +		return false;
>> +
>> +	copied =3D kernel_read_key(key->serial, payload, *len);
>> +
>> +	if (copied < 0 || (size_t)copied > *len)
>> +		return false;
>
> So what is the behavior of the kernel syscall here?  How can copied ever =
be =

> greater than len?
>

The syscall return value is the total length of the key, which may be =

larger than the buffer passed to the kernel. I will change "copied" to =

"keylen".

> Another issue is whether userspace has any way of obtaining information o=
n =

> how large the payload is.  E.g. what size len to pass in.  Should we trac=
k =

> the key size or extract it out somehow?
>

The KEYCTL_READ syscall lets us get the length without copying anything if =

a zero-length buffer is passed in. I think it's best to expose that =

(l_key_get_size()), since there may be keys that we ask the kernel to =

generate for us.

>> +
>> +	*len =3D copied;
>> +	return true;
>> +}
>> +
>> +LIB_EXPORT bool l_key_get_type(struct l_key *key, enum l_key_type *type)
>
> We avoided having to deal with this type of situation where an enum needs=
 to =

> be extracted back out of an instance.  Some may like doing something like:
>
> enum l_key_type l_key_get_type(struct l_key *key) better.  However, doing=
 it =

> this way would require us to introduce an _INVALID enum value.  Not sure =

> which one is better/worse.
>

We think very much alike here! I considered both options but I didn't see =

other examples of the _INVALID approach, so I went with the bool return to =

handle the error case and figured we could discuss the alternatives.

Using an _INVALID enum would be less awkward in the common case, where the =

caller would check to see if the type matched an expected value. Returning =

a bool means the caller has to check both the boolean return value and (if =

that is 'true') the retrieved type.

The use case I envisioned is that l_keys will be passed to other APIs, =

like cipher. The specific cipher implementation would check the expected =

key type before trying to use it. If we instead opt to skip that kind of =

check and let the cipher operation fail if they key isn't applicable, then =

we can remove l_key_type altogether.

> I'm okay with the approach taken in the patch, but maybe others have thou=
ghts =

> on this?  We'd need to standardize on something.
>
>> +{
>> +	if (unlikely(!key))
>> +		return false;
>> +
>> +	*type =3D key->type;
>> +	return true;
>> +}
>
> <snip>

--
Mat Martineau
Intel OTC



--===============4149217885869967046==--

