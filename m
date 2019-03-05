Content-Type: multipart/mixed; boundary="===============0510137143955938018=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/2] uintset: Add l_uintset_intersect
Date: Tue, 05 Mar 2019 22:12:39 +0100
Message-ID: <CAOq732KdmAXQxqiz=2nnKhg_Nbtkf1X7z9nEQEjcZn7BivqfoQ@mail.gmail.com>
In-Reply-To: <20190305203543.1492-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0510137143955938018==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

On Tue, 5 Mar 2019 at 21:35, Tim Kourt <tim.a.kourt@linux.intel.com> wrot=
e:
> l_uintset_intersect computes the intersection of two sets.
> In addition, it introduces find_next_bit(=E2=80=A6) that is used to
> efficiently loop through the set bits in the set and may have
> multiple implication in the future.
> ---
>  ell/uintset.c | 96 +++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++++
>  ell/uintset.h |  3 ++
>  2 files changed, 99 insertions(+)
>
> diff --git a/ell/uintset.c b/ell/uintset.c
> index 1d96e68..6b657b8 100644
> --- a/ell/uintset.c
> +++ b/ell/uintset.c
> @@ -122,6 +122,49 @@ static unsigned long find_last_bit(const unsigned lo=
ng *addr, unsigned int size)
>         return size;
>  }
>
> +static unsigned long find_next_bit(const unsigned long *addr,
> +                                                       unsigned long siz=
e,
> +                                                       unsigned long bit)
> +{
> +       unsigned long mask;
> +       unsigned long offset;
> +
> +       if (bit >=3D size)
> +               return size;
> +
> +       addr +=3D bit / BITS_PER_LONG;
> +       offset =3D bit % BITS_PER_LONG;
> +       bit -=3D offset;
> +
> +       if (offset) {
> +               mask =3D *addr & ~(~0UL >> (BITS_PER_LONG - offset));
> +               if (mask)
> +                       return bit + __ffs(mask);
> +
> +               bit +=3D BITS_PER_LONG;
> +               addr++;
> +       }
> +
> +       for (size -=3D bit; size >=3D BITS_PER_LONG;
> +                       size -=3D BITS_PER_LONG, bit +=3D BITS_PER_LONG, =
addr++) {
> +               if (!*addr)
> +                       continue;
> +
> +               return bit + __ffs(*addr);
> +       }
> +
> +       if (!size)
> +               return bit;
> +
> +       mask =3D *addr & (~0UL >> (BITS_PER_LONG - size));
> +       if (mask)
> +               bit +=3D __ffs(mask);
> +       else
> +               bit +=3D size;
> +
> +       return bit;
> +}
> +
>  struct l_uintset {
>         unsigned long *bits;
>         uint16_t size;
> @@ -404,3 +447,56 @@ LIB_EXPORT uint32_t l_uintset_find_min(struct l_uint=
set *set)
>
>         return bit + set->min;
>  }
> +
> +/**
> + * l_uintset_intersect:
> + * @set_a: The set of numbers
> + * @set_b: The set of numbers
> + *
> + * Returns: A newly allocated l_uintset object containing intersection of
> + * @set_a and @set_b. If @set_a and @set_b cannot be intersected returns=
 NULL.
> + * If either @set_a or @set_b is NULL returns NULL.
> + **/
> +LIB_EXPORT struct l_uintset *l_uintset_intersect(const struct l_uintset =
*set_a,
> +                                               const struct l_uintset *s=
et_b)
> +{
> +       struct l_uintset *intersection;
> +       uint32_t min;
> +       uint32_t max;
> +       unsigned int bit_a;
> +       unsigned int bit_b;
> +
> +       if (unlikely(!set_a) || unlikely(!set_b))
> +               return NULL;
> +
> +       if (set_a->max < set_b->min || set_b->max < set_a->min)
> +               return NULL;
> +
> +       min =3D set_a->min <=3D set_b->min ? set_a->min : set_b->min;

So this basically does min =3D MIN(set_a->min, set_b->min) but could
safely do MAX(...).

> +       max =3D set_a->max >=3D set_b->max ? set_a->max : set_b->max;
> +
> +       intersection =3D l_uintset_new_from_range(min, max);
> +
> +       bit_a =3D find_first_bit(set_a->bits, set_a->size);
> +       bit_b =3D find_first_bit(set_b->bits, set_b->size);
> +
> +       while (bit_a < set_a->size && bit_b < set_b->size) {
> +               if (set_a->min + bit_a < set_b->min + bit_b) {
> +                       bit_a =3D find_next_bit(set_a->bits, set_a->size,
> +                                                               bit_a + 1=
);
> +                       continue;
> +               }
> +
> +               if (set_a->min + bit_a > set_b->min + bit_b) {
> +                       bit_b =3D find_next_bit(set_b->bits, set_b->size,
> +                                                               bit_b + 1=
);
> +                       continue;
> +               }
> +
> +               l_uintset_put(intersection, set_a->min + bit_a);
> +               bit_a =3D find_next_bit(set_a->bits, set_a->size, bit_a +=
 1);
> +               bit_b =3D find_next_bit(set_b->bits, set_b->size, bit_b +=
 1);
> +       }

Here you could also assign entire words in intersection->bits (with
some shifting required) and skip to the next non-zero word afterwards
although that wouldn't even be much faster than just assigning 0 by
&ing the words from set_a and set_b.

Best regards

--===============0510137143955938018==--

