Content-Type: multipart/mixed; boundary="===============5963944135220305282=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 06/13] pkcs5: Add the PKCS#12 KDF
Date: Thu, 10 Dec 2020 22:51:13 +0000
Message-ID: <183e3ea3-5ed1-4b15-3030-89a53d3eb4d5@gmail.com>
In-Reply-To: <20201210193202.526451-6-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5963944135220305282==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 12/10/20 1:31 PM, Andrew Zaborowski wrote:
> Add the key derivation algorithm used with PKCS#12 to pkcs5.c so that it
> can be found together with the two PKCS#5 KDFs, and so that it can also
> be used when parsing of the PKCS#12 AlgorithmIdentifiers in the next
> commit.  This KDF is not recommended for new uses.
> ---
>   ell/pkcs5-private.h |  12 ++++
>   ell/pkcs5.c         | 146 ++++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 158 insertions(+)
> =


<snip>

> +static bool utf8_to_bmpstring(const char *utf, uint8_t *out_buf,
> +				unsigned int *out_len)
> +{
> +	unsigned int n;
> +	int utflen;
> +	wchar_t cp;
> +	uint16_t *ptr =3D (uint16_t *) out_buf;
> +
> +	for (n =3D strlen(utf); n; n -=3D utflen, utf +=3D utflen) {
> +		if ((utflen =3D l_utf8_get_codepoint(utf, n, &cp)) <=3D 0 ||
> +				cp > 0xffff)
> +			return false;

So is this just a UCS2BE conversion?  If so, then using l_utf8_to_ucs2be mi=
ght =

be clearer.

> +
> +		*ptr++ =3D L_CPU_TO_BE16(cp);
> +	}
> +
> +	*ptr++ =3D 0;
> +	*out_len =3D (uint8_t *) ptr - out_buf;
> +	return true;
> +}
> +

Regards,
-Denis
--===============5963944135220305282==--

