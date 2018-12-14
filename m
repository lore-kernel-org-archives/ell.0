Content-Type: multipart/mixed; boundary="===============1666793832310796002=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 8/9] tls: Allow user to set custom list of cipher suites
Date: Fri, 14 Dec 2018 10:33:27 -0600
Message-ID: <d5908538-31fc-d089-d343-c7812a54442b@gmail.com>
In-Reply-To: <20181213195746.32144-8-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1666793832310796002==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 12/13/2018 01:57 PM, Andrew Zaborowski wrote:
> TLS "security profiles" define which minimum cipher suites and other
> parameter values are allowed in a specific usage scenario for TLS, for
> example WPA3 in theory requires a specific security profile for its
> TLS-based EAP method.  This will also allow the unit tests to test
> individual cipher suites.

Do we want to expose this fine level of granularity in a public API =

though?  It would seem at least at WPA2 vs WPA3 level that a single =

SuiteB selector is all that is needed?

Unless you have a usecase in mind where one would really want to twiddle =

the preference order?

> ---
>   ell/ell.sym       |   1 +
>   ell/tls-private.h |   2 +
>   ell/tls.c         | 101 ++++++++++++++++++++++++++++++++++++++++++----
>   ell/tls.h         |   3 ++
>   4 files changed, 99 insertions(+), 8 deletions(-)
> =


<snip>

<snip>

> @@ -2790,6 +2836,45 @@ LIB_EXPORT void l_tls_set_version_range(struct l_t=
ls *tls,
>   		max_version : TLS_MAX_VERSION;
>   }
>   =

> +LIB_EXPORT void l_tls_set_cipher_suites(struct l_tls *tls,
> +					const char **suite_list)

void?  Don't we want to fail if nothing valid was passed?

And wouldn't / shouldn't l_tls_start() also fail in this case?

> +{
> +	unsigned int i, len;
> +	struct tls_cipher_suite **suite;
> +
> +	l_free(tls->cipher_suite_pref_list);
> +
> +	if (suite_list)
> +		len =3D l_strv_length((char **) suite_list);

I hate C and its char ** / const char ** thing.  Oh well :)

> +	else
> +		len =3D L_ARRAY_SIZE(tls_cipher_suite_pref);

You take note of len here, but then...

> +
> +	tls->cipher_suite_pref_list =3D l_new(struct tls_cipher_suite *, len + =
1);
> +
> +	if (!suite_list) {
> +		/* Use our default cipher suite preference list */
> +		for (i =3D 0; i < L_ARRAY_SIZE(tls_cipher_suite_pref); i++)

use array_size here again.  Maybe a nitpick, but using len would be =

shorter anyway.

Another question is whether storing a bool default_cipher_pref : 1 =

instead of doing all this magic dancing would be easier.

> +			tls->cipher_suite_pref_list[i] =3D
> +				&tls_cipher_suite_pref[i];
> +
> +		return;
> +	}
> +
> +	suite =3D tls->cipher_suite_pref_list;
> +
> +	for (; *suite_list; suite_list++) {
> +		for (i =3D 0; i < L_ARRAY_SIZE(tls_cipher_suite_pref); i++)
> +			if (!strcmp(tls_cipher_suite_pref[i].name, *suite_list))
> +				break;
> +
> +		if (i < L_ARRAY_SIZE(tls_cipher_suite_pref))
> +			*suite++ =3D &tls_cipher_suite_pref[i];
> +		else
> +			TLS_DEBUG("Cipher suite %s is not supported",
> +					*suite_list);
> +	}
> +}
> +
>   LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls_alert_desc desc)
>   {
>   	switch (desc) {

Regards,
-Denis

--===============1666793832310796002==--

