Content-Type: multipart/mixed; boundary="===============3794506853285889225=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 1/2] util: Add suffix check for a string
Date: Mon, 25 Apr 2016 09:16:02 -0700
Message-ID: <alpine.OSX.2.20.1604250914100.1671@mjmartin-mac01.local>
In-Reply-To: <1461362815-57501-1-git-send-email-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3794506853285889225==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


Tim,

On Fri, 22 Apr 2016, Tim Kourt wrote:

> ---
> ell/util.c | 27 +++++++++++++++++++++++++++
> ell/util.h |  1 +
> 2 files changed, 28 insertions(+)
>
> diff --git a/ell/util.c b/ell/util.c
> index f920895..895f95f 100644
> --- a/ell/util.c
> +++ b/ell/util.c
> @@ -444,6 +444,33 @@ LIB_EXPORT bool l_str_has_prefix(const char *str, co=
nst char *prefix)
> }
>
> /**
> + * l_str_has_suffix:
> + * @str: A string to be examined
> + * @suffix: Suffix string
> + *
> + * Determines if the string given by @str ends with the specified @suffi=
x.
> + *
> + * Returns: True if @str ends with the specified @suffix.  False otherwi=
se.
> + */
> +LIB_EXPORT bool l_str_has_suffix(const char *str, const char *suffix)
> +{
> +	int str_len_diff;
> +
> +	if (unlikely(!str))
> +		return false;
> +
> +	if (unlikely(!suffix))
> +		return false;
> +
> +	str_len_diff =3D strlen(str) - strlen(suffix);

strlen returns size_t (unsigned), which is a 64-bit type on 64-bit =

platforms. Hopefully no one is throwing around 4+GB null-terminated =

strings, but you never know. You can make sure the suffix is shorter =

before calculating the difference, avoiding signed integers altogether.

> +
> +	if (str_len_diff < 0)
> +		return false;
> +
> +	return !strcmp(&str[str_len_diff], suffix);
> +}


Regards,

Mat

--===============3794506853285889225==--

