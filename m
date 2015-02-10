Content-Type: multipart/mixed; boundary="===============8057609829135712492=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/9] hashmap: Call user supplied value free function in
 insert
Date: Tue, 10 Feb 2015 13:18:36 -0600
Message-ID: <54DA598C.6030402@gmail.com>
In-Reply-To: <1423579344-10933-4-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8057609829135712492==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/10/2015 08:42 AM, Jukka Rissanen wrote:
> If user has supplied a value free function, then that will be
> called for each replaced entry.
> ---
>   ell/hashmap.c | 27 ++++++++++++++++++++++++++-
>   1 file changed, 26 insertions(+), 1 deletion(-)
>
> diff --git a/ell/hashmap.c b/ell/hashmap.c
> index c51abfd..a204726 100644
> --- a/ell/hashmap.c
> +++ b/ell/hashmap.c
> @@ -393,7 +393,11 @@ LIB_EXPORT void l_hashmap_destroy(struct l_hashmap *=
hashmap,
>    * @key: key pointer
>    * @value: value pointer
>    *
> - * Insert new @value entry with @key.
> + * Insert new @value entry with @key. If there is already an same key
> + * in the hash, the new value will replace the old one. If user has set
> + * the value free function by l_hashmap_set_value_free_function() then
> + * the user specified free function will be called in order to free the
> + * value.
>    *
>    * Returns: #true when value has been added and #false in case of failu=
re
>    **/
> @@ -419,6 +423,27 @@ LIB_EXPORT bool l_hashmap_insert(struct l_hashmap *h=
ashmap,
>   		goto done;
>   	}
>

So the current implementation allows duplicates to be added.  However, =

it is implementation dependent what happens if you lookup a duplicate =

key.  With the current implementation, the item inserted first is =

returned.  I don't think enforcement of unique keys is required at the =

hashmap_insert level.  The user should not be always made to pay the =

cost of duplicate detection (e.g. if he knows no duplicates will ever be =

present).

If duplicates are an issue, the way to handle this in the client code =

would be to
	- Call l_hashmap_remove first
	- Insert the new element

Alternatively, you could add an l_hashmap_replace() method call, e.g.:

bool l_hashmap_replace(struct l_hashmap *hashmap,
                         const void *key, void *value,
			l_hashmap_destroy_func_t destroy);

> +	/* If the key is already in the hash, we just replace the value */
> +	for (entry =3D head;; entry =3D entry->next) {
> +		if (entry->hash =3D=3D hash &&
> +				!hashmap->compare_func(key, entry->key)) {
> +			if (entry->key !=3D key_new) {
> +				free_key(hashmap, entry->key);
> +				entry->key =3D key_new;
> +			}

So this part doesn't really match the comment above.  You're also =

freeing the key, which is an unnecessary step.  If the keys are the =

same, just reuse them.

> +
> +			if (entry->value !=3D value) {
> +				free_value(hashmap, entry->value);
> +				entry->value =3D value;
> +			}
> +
> +			return true;
> +		}
> +
> +		if (entry->next =3D=3D head)
> +			break;
> +	}
> +
>   	entry =3D l_new(struct entry, 1);
>   	entry->key =3D key_new;
>   	entry->value =3D value;
>

Regards,
-Denis

--===============8057609829135712492==--

