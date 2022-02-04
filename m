Content-Type: multipart/mixed; boundary="===============8228226549791321534=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/5] settings: add l_settings_clone
Date: Fri, 04 Feb 2022 11:31:34 -0600
Message-ID: <87287ae4-faa2-7276-6dbe-ed2bd7f147ed@gmail.com>
In-Reply-To: 20220204170603.216439-1-prestwoj@gmail.com

--===============8228226549791321534==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 2/4/22 11:05, James Prestwood wrote:
> Returns identical copy of settings
> ---
>   ell/ell.sym    |  1 +
>   ell/settings.c | 62 ++++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/settings.h |  2 ++
>   3 files changed, 65 insertions(+)
> =


<snip>

> +
> +static void copy_embedded_foreach(void *data, void *user_data)
> +{
> +	struct embedded_group_data *embedded =3D data;
> +	struct l_queue *groups =3D user_data;
> +	struct embedded_group_data *copy;
> +
> +	copy =3D l_malloc(sizeof(struct embedded_group_data) +
> +					embedded->len + 1);
> +	copy->name =3D l_strdup(embedded->name);
> +
> +	memcpy(copy->type, embedded->type, sizeof(embedded->type));
> +	copy->len =3D embedded->len;
> +	memcpy(copy->data, embedded->data, embedded->len);
> +	copy->data[embedded->len] =3D '\0';

Any reason not to just memcpy the entire structure and fix up copy->name to =

invoke l_strdup later?

> +
> +	l_queue_push_tail(groups, copy);
> +}

Regards,
-Denis
--===============8228226549791321534==--

