Content-Type: multipart/mixed; boundary="===============7936774273888773467=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/2] unit: Add l_uintset_intersect tests
Date: Thu, 07 Mar 2019 10:13:53 -0600
Message-ID: <501fdbcd-7492-4878-2eac-c981389a7d55@gmail.com>
In-Reply-To: <20190307001707.22395-2-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7936774273888773467==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

On 03/06/2019 06:17 PM, Tim Kourt wrote:
> ---
>   unit/test-uintset.c | 91 ++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   1 file changed, 91 insertions(+)
> =

> diff --git a/unit/test-uintset.c b/unit/test-uintset.c
> index 4488cd9..9bd455c 100644
> --- a/unit/test-uintset.c
> +++ b/unit/test-uintset.c
> @@ -262,6 +262,91 @@ static void test_uintset_foreach(const void *data)
>   	l_uintset_free(check);
>   }
>   =

> +static void test_uintset_intersect_1(const void *data)

Can this be a bit more descriptive, e.g. intersect_invalid, =

intersect_sanity, etc

> +{
> +	struct l_uintset *set_a;
> +	struct l_uintset *set_b;
> +
> +	assert(!l_uintset_intersect(NULL, NULL));
> +
> +	set_a =3D l_uintset_new_from_range(0, 5);
> +	assert(!l_uintset_intersect(NULL, set_a));
> +	assert(!l_uintset_intersect(set_a, NULL));
> +
> +	set_b =3D l_uintset_new_from_range(4, 10);
> +	assert(!l_uintset_intersect(set_a, set_b));
> +
> +	l_uintset_free(set_a);
> +	l_uintset_free(set_b);
> +}
> +
> +struct uintset_data {
> +	uint32_t min;
> +	uint32_t max;
> +	uint32_t *vals;
> +	uint32_t size;
> +};
> +
> +struct uintset_intersect_data {
> +	const struct uintset_data set_a;
> +	const struct uintset_data set_b;
> +	const struct uintset_data set_r;
> +};
> +
> +uint32_t vals1[] =3D { 1, 2, 3 };
> +uint32_t vals2[] =3D { 3, 4};
> +uint32_t vals3[] =3D { 3 };

These should be static const

> +
> +static const struct uintset_intersect_data intersect_data_1 =3D {
> +	.set_a =3D { 0, 4, vals1, L_ARRAY_SIZE(vals1) },
> +	.set_b =3D { 0, 4, vals2, L_ARRAY_SIZE(vals2) },
> +	.set_r =3D { 0, 4, vals3, L_ARRAY_SIZE(vals3) },
> +};
> +
> +uint32_t vals4[] =3D { 0, 1, 64, 127 };
> +uint32_t vals5[] =3D { 1, 25, 64, 66, 127, 135 };
> +uint32_t vals6[] =3D { 1, 64, 127 };
> +

And these

> +static const struct uintset_intersect_data intersect_data_2 =3D {
> +	.set_a =3D { 0, 191, vals4, L_ARRAY_SIZE(vals4) },
> +	.set_b =3D { 0, 191, vals5, L_ARRAY_SIZE(vals5) },
> +	.set_r =3D { 0, 191, vals6, L_ARRAY_SIZE(vals6) },
> +};
> +
> +static void test_uintset_intersect_2(const void *user_data)
> +{
> +	const struct uintset_intersect_data *data =3D user_data;
> +	struct l_uintset *set_a;
> +	struct l_uintset *set_b;
> +	struct l_uintset *set_r;
> +	size_t i;
> +
> +	set_a =3D l_uintset_new_from_range(data->set_a.min, data->set_a.max);
> +
> +	for (i =3D 0; i < data->set_a.size; i++)
> +		l_uintset_put(set_a, data->set_a.vals[i]);
> +
> +	set_b =3D l_uintset_new_from_range(data->set_b.min, data->set_b.max);
> +
> +	for (i =3D 0; i < data->set_b.size; i++)
> +		l_uintset_put(set_b, data->set_b.vals[i]);
> +
> +	set_r =3D l_uintset_intersect(set_a, set_b);
> +
> +	assert(set_r);
> +
> +	for (i =3D 0; i < data->set_r.size; i++) {
> +		assert(l_uintset_contains(set_r, data->set_r.vals[i]));
> +		assert(l_uintset_take(set_r, data->set_r.vals[i]));
> +	}
> +
> +	assert(l_uintset_find_max(set_r) =3D=3D l_uintset_get_max(set_r) + 1);
> +
> +	l_uintset_free(set_a);
> +	l_uintset_free(set_b);
> +	l_uintset_free(set_r);
> +}
> +
>   int main(int argc, char *argv[])
>   {
>   	l_test_init(&argc, &argv);
> @@ -273,6 +358,12 @@ int main(int argc, char *argv[])
>   	l_test_add("l_uintset for each tests", test_uintset_foreach, NULL);
>   	l_test_add("l_uintset find unused tests", test_uintset_find_unused,
>   							NULL);
> +	l_test_add("l_uintset intersect sanity check", test_uintset_intersect_1,
> +									NULL);
> +	l_test_add("l_uintset intersect test 1", test_uintset_intersect_2,
> +							&intersect_data_1);
> +	l_test_add("l_uintset intersect test2", test_uintset_intersect_2,
> +							&intersect_data_2);

Nitpick, but you have 'test 1' and then 'test2'.  Be consistent :)

>   =

>   	return l_test_run();
>   }
> =


Regards,
-Denis

--===============7936774273888773467==--

