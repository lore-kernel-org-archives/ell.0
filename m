Content-Type: multipart/mixed; boundary="===============2866739124516246367=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 06/12] tls: Move cipher suite definitions to tls-suites.c
Date: Fri, 04 Jan 2019 15:35:30 -0600
Message-ID: <0e235de5-3ae3-994e-8aad-3ecd1c8df3ef@gmail.com>
In-Reply-To: <20190104012640.4022-6-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2866739124516246367==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/03/2019 07:26 PM, Andrew Zaborowski wrote:
> Move the cipher suite-specific code to new file ell/tls-suites.c.
> Unfortunately this requires a few functions and arrays to be exported
> from tls.c.
> ---
>   Makefile.am       |   1 +
>   ell/tls-private.h |  25 +++
>   ell/tls-suites.c  | 450 ++++++++++++++++++++++++++++++++++++++++++++
>   ell/tls.c         | 465 ++--------------------------------------------
>   4 files changed, 490 insertions(+), 451 deletions(-)
>   create mode 100644 ell/tls-suites.c
> =


<snip>

> @@ -903,8 +734,7 @@ static ssize_t tls_append_hello_extensions(struct l_t=
ls *tls,
>   =

>   static bool tls_send_client_hello(struct l_tls *tls)
>   {
> -	uint8_t buf[1024 + L_ARRAY_SIZE(tls_compression_pref) +
> -			2 * L_ARRAY_SIZE(tls_cipher_suite_pref)];
> +	uint8_t buf[1024 + L_ARRAY_SIZE(tls_compression_pref)];
>   	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
>   	uint8_t *len_ptr;
>   	unsigned int i;

Was this chunk intended?

Anyway, I went ahead and applied this patch.  Send me a fix if needed.

Regards,
-Denis

--===============2866739124516246367==--

