Content-Type: multipart/mixed; boundary="===============0055956176282277295=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH] settings: Overwrite values before freeing memory
Date: Mon, 30 Apr 2018 08:49:59 -0700
Message-ID: <alpine.OSX.2.21.1804300840341.4562@seskerx-mobl.amr.corp.intel.com>
In-Reply-To: <20180428022542.4289-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0055956176282277295==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Sat, 28 Apr 2018, Andrew Zaborowski wrote:

> Since there may be sensitive data in the setting values, wipe the
> value memory before freeing.
> ---
> ell/settings.c | 1 +
> 1 file changed, 1 insertion(+)
>
> diff --git a/ell/settings.c b/ell/settings.c
> index a556144..8e67fa3 100644
> --- a/ell/settings.c
> +++ b/ell/settings.c
> @@ -61,6 +61,7 @@ static void setting_destroy(void *data)
> 	struct setting_data *pair =3D data;
>
> 	l_free(pair->key);
> +	memset(pair->value, 0, strlen(pair->value));

l_free can handle pair->value =3D=3D NULL, but strlen and memset can't. Is =
it =

worth checking for that?

> 	l_free(pair->value);
> 	l_free(pair);
> }
> -- =

> 2.14.1
>
> _______________________________________________
> ell mailing list
> ell(a)lists.01.org
> https://lists.01.org/mailman/listinfo/ell
>

--
Mat Martineau
Intel OTC

--===============0055956176282277295==--

