Content-Type: multipart/mixed; boundary="===============2037350685394593591=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] uintset: Add l_uintset_intersect
Date: Tue, 05 Mar 2019 15:47:15 -0600
Message-ID: <845b54c4-a10b-89bf-ea1e-9c2e2fe07d11@gmail.com>
In-Reply-To: <20190305203543.1492-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2037350685394593591==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

On 03/05/2019 02:35 PM, Tim Kourt wrote:
> l_uintset_intersect computes the intersection of two sets.
> In addition, it introduces find_next_bit(=E2=80=A6) that is used to
> efficiently loop through the set bits in the set and may have
> multiple implication in the future.

implications or applications?  If it is the first, that sounds ominous...

> ---
>   ell/uintset.c | 96 ++++++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   ell/uintset.h |  3 ++
>   2 files changed, 99 insertions(+)
> =


<snip>

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
> +						const struct l_uintset *set_b)
> +{
> +	struct l_uintset *intersection;
> +	uint32_t min;
> +	uint32_t max;
> +	unsigned int bit_a;
> +	unsigned int bit_b;
> +
> +	if (unlikely(!set_a) || unlikely(!set_b))
> +		return NULL;
> +
> +	if (set_a->max < set_b->min || set_b->max < set_a->min)
> +		return NULL;

So honestly I would implement a fast version which works for sets where =

min and max are the same.  This is really what you want anyway for the =

scan_freq_set stuff, right?  That should be a very simple bitwise and =

operation...

I'm not completely sure of the utility of this more generalized =

intersect operation that you have implemented here.  Do you foresee a =

need for something like this?

Regards,
-Denis

--===============2037350685394593591==--

