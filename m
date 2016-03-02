Content-Type: multipart/mixed; boundary="===============1921860174890742510=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] key: Add basic keystore support
Date: Wed, 02 Mar 2016 10:51:27 -0600
Message-ID: <56D71A0F.4040601@gmail.com>
In-Reply-To: <1456878210-17519-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1921860174890742510==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 03/01/2016 06:23 PM, Mat Martineau wrote:
> ---
>   Makefile.am |   6 ++-
>   ell/ell.h   |   1 +
>   ell/key.c   | 155 +++++++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   ell/key.h   |  58 +++++++++++++++++++++++
>   4 files changed, 218 insertions(+), 2 deletions(-)
>   create mode 100644 ell/key.c
>   create mode 100644 ell/key.h
>

<snip>

> diff --git a/ell/key.c b/ell/key.c
> new file mode 100644
> index 0000000..b6a1303
> --- /dev/null
> +++ b/ell/key.c
> @@ -0,0 +1,155 @@
> +/*
> + *
> + *  Embedded Linux library
> + *
> + *  Copyright (C) 2016  Intel Corporation. All rights reserved.
> + *
> + *  This library is free software; you can redistribute it and/or
> + *  modify it under the terms of the GNU Lesser General Public
> + *  License as published by the Free Software Foundation; either
> + *  version 2.1 of the License, or (at your option) any later version.
> + *
> + *  This library is distributed in the hope that it will be useful,
> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + *  Lesser General Public License for more details.
> + *
> + *  You should have received a copy of the GNU Lesser General Public
> + *  License along with this library; if not, write to the Free Software
> + *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-130=
1  USA
> + *
> + */
> +
> +#ifdef HAVE_CONFIG_H
> +#include <config.h>
> +#endif
> +
> +#define _GNU_SOURCE
> +#include <unistd.h>
> +#include <sys/syscall.h>
> +#include <linux/keyctl.h>
> +
> +#include "private.h"
> +#include "util.h"
> +#include "key.h"
> +
> +//DEBUG
> +#include <stdio.h>

Still needed?

> +
> +#define is_valid_type(type) ((type) <=3D L_KEY_DH_PRIVATE)
> +
> +static int keyring_base;
> +
> +struct l_key {
> +	int type;
> +	long serial;
> +};
> +
> +static long kernel_add_key(char *type, char *description,
> +				const void *payload, size_t len, long keyring)
> +{
> +	return syscall(__NR_add_key, type, description, payload, len, keyring);
> +}
> +
> +static long kernel_read_key(long serial, const void *payload, size_t len)
> +{
> +	return syscall(__NR_keyctl, KEYCTL_READ, serial, payload, len);
> +}
> +
> +static long kernel_update_key(long serial, const void *payload, size_t l=
en)
> +{
> +	return syscall(__NR_keyctl, KEYCTL_UPDATE, serial, payload, len);
> +}
> +
> +static long kernel_revoke_key(long serial)
> +{
> +	return syscall(__NR_keyctl, KEYCTL_REVOKE, serial);
> +}
> +
> +static bool setup_keyring_base(void)
> +{
> +	keyring_base =3D kernel_add_key("keyring", "ell", 0, 0,
> +					KEY_SPEC_THREAD_KEYRING);
> +

This is fine for now, but I think we might want to expose the concept of =

keyrings in the future.

> +	if (keyring_base <=3D 0) {
> +		keyring_base =3D 0;
> +		return false;
> +	}
> +
> +	return true;
> +}
> +
> +LIB_EXPORT struct l_key *l_key_new(enum l_key_type type, const void *pay=
load,
> +					size_t payload_length)
> +{
> +	struct l_key *key;
> +
> +	if (unlikely(!payload))
> +		return NULL;
> +
> +	if (unlikely(!is_valid_type(type)))
> +		return NULL;
> +
> +	if (!keyring_base && !setup_keyring_base()) {
> +		return NULL;
> +	}
> +
> +	key =3D l_new(struct l_key, 1);
> +	key->type =3D type;
> +	key->serial =3D kernel_add_key("user", "testing", payload, payload_leng=
th,
> +					keyring_base);
> +
> +	if (key->serial < 0) {
> +		l_free(key);
> +		key =3D NULL;
> +	}
> +
> +	return key;
> +}
> +
> +LIB_EXPORT void l_key_free(struct l_key *key)
> +{
> +	if (unlikely(!key))
> +		return;
> +
> +	kernel_revoke_key(key->serial);
> +
> +	l_free(key);
> +}
> +
> +LIB_EXPORT bool l_key_set_payload(struct l_key *key, void *payload, size=
_t len)

I'm not sure I like the name.  Perhaps l_key_update?

> +{
> +	long error;
> +
> +	if (unlikely(!key))
> +		return false;
> +
> +	error =3D kernel_update_key(key->serial, payload, len);
> +
> +	return error =3D=3D 0;
> +}
> +
> +LIB_EXPORT bool l_key_get_payload(struct l_key *key, void *payload, size=
_t *len)

Maybe l_key_extract, l_key_extract_raw_bytes, l_key_get_raw_bytes?

> +{
> +	long copied;
> +
> +	if (unlikely(!key))
> +		return false;
> +
> +	copied =3D kernel_read_key(key->serial, payload, *len);
> +
> +	if (copied < 0 || (size_t)copied > *len)
> +		return false;

So what is the behavior of the kernel syscall here?  How can copied ever =

be greater than len?

Another issue is whether userspace has any way of obtaining information =

on how large the payload is.  E.g. what size len to pass in.  Should we =

track the key size or extract it out somehow?

> +
> +	*len =3D copied;
> +	return true;
> +}
> +
> +LIB_EXPORT bool l_key_get_type(struct l_key *key, enum l_key_type *type)

We avoided having to deal with this type of situation where an enum =

needs to be extracted back out of an instance.  Some may like doing =

something like:

enum l_key_type l_key_get_type(struct l_key *key) better.  However, =

doing it this way would require us to introduce an _INVALID enum value. =

  Not sure which one is better/worse.

I'm okay with the approach taken in the patch, but maybe others have =

thoughts on this?  We'd need to standardize on something.

> +{
> +	if (unlikely(!key))
> +		return false;
> +
> +	*type =3D key->type;
> +	return true;
> +}

<snip>

Regards,
-Denis


--===============1921860174890742510==--

