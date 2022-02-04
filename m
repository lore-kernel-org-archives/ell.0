Content-Type: multipart/mixed; boundary="===============4277153327525715945=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 3/5] settings: add l_settings_remove_embedded_groups
Date: Fri, 04 Feb 2022 11:33:04 -0600
Message-ID: <cfaccee8-b4f5-8fa1-a44f-452f5a5a371b@gmail.com>
In-Reply-To: 20220204170603.216439-3-prestwoj@gmail.com

--===============4277153327525715945==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

<snip>

> +LIB_EXPORT bool l_settings_remove_embedded_groups(struct l_settings *set=
tings)
> +{
> +	if (unlikely(!settings))
> +		return false;
> +
> +	l_queue_destroy(settings->embedded_groups, embedded_group_destroy);
> +	settings->embedded_groups =3D l_queue_new();

l_queue_clear() might be cleaner here.

> +
> +	return true;
> +}

Regards,
-Denis
--===============4277153327525715945==--

