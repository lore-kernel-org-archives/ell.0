Content-Type: multipart/mixed; boundary="===============4138038013278008814=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 4/9] tls: Implement l_tls_set_version_range
Date: Fri, 14 Dec 2018 09:55:28 -0600
Message-ID: <189e32a3-5f24-7c80-86a8-13c074279d01@gmail.com>
In-Reply-To: <20181213195746.32144-4-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4138038013278008814==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 12/13/2018 01:57 PM, Andrew Zaborowski wrote:
> Allow user to set custom min and max TLS version limits, this can be
> used to ensure we comply with a specific security profile.
> ---
>   ell/ell.sym       |  1 +
>   ell/tls-private.h | 10 ++---
>   ell/tls-record.c  | 14 +++----
>   ell/tls.c         | 99 +++++++++++++++++++++++++++++++++--------------
>   ell/tls.h         |  8 +++-
>   5 files changed, 87 insertions(+), 45 deletions(-)
> =

> diff --git a/ell/ell.sym b/ell/ell.sym
> index 7d7a5e4..2ff7d30 100644
> --- a/ell/ell.sym
> +++ b/ell/ell.sym
> @@ -417,6 +417,7 @@ global:
>   	l_tls_close;
>   	l_tls_set_cacert;
>   	l_tls_set_auth_data;
> +	l_tls_set_version_range;
>   	l_tls_alert_to_str;
>   	l_tls_set_debug;
>   	/* uintset */
> diff --git a/ell/tls-private.h b/ell/tls-private.h
> index 8e6c277..e2ec014 100644
> --- a/ell/tls-private.h
> +++ b/ell/tls-private.h
> @@ -20,13 +20,8 @@
>    *
>    */
>   =

> -/* Only TLS 1.2 supported */
> -#define TLS_V12		((3 << 8) | 3)
> -#define TLS_V11		((3 << 8) | 2)
> -#define TLS_V10		((3 << 8) | 1)
> -
> -#define TLS_VERSION	TLS_V12
> -#define TLS_MIN_VERSION	TLS_V10
> +#define TLS_MAX_VERSION	L_TLS_V12
> +#define TLS_MIN_VERSION	L_TLS_V10
>   =

>   enum tls_cipher_type {
>   	TLS_CIPHER_STREAM,
> @@ -145,6 +140,7 @@ struct l_tls {
>   	l_tls_debug_cb_t debug_handler;
>   	l_tls_destroy_cb_t debug_destroy;
>   	void *debug_data;
> +	uint16_t min_version, max_version;
>   =


So why isn't this an enum?

>   	struct l_queue *ca_certs;
>   	struct l_certchain *cert;

<snip>

> diff --git a/ell/tls.h b/ell/tls.h
> index fb33404..5b2f398 100644
> --- a/ell/tls.h
> +++ b/ell/tls.h
> @@ -25,6 +25,10 @@
>   extern "C" {
>   #endif
>   =

> +#define L_TLS_V12	((3 << 8) | 3)
> +#define L_TLS_V11	((3 << 8) | 2)
> +#define L_TLS_V10	((3 << 8) | 1)
> +

This can easily be an enum, no?

>   struct l_tls;
>   =

>   enum l_tls_alert_desc {
> @@ -63,7 +67,6 @@ typedef void (*l_tls_disconnect_cb_t)(enum l_tls_alert_=
desc reason,
>   typedef void (*l_tls_debug_cb_t)(const char *str, void *user_data);
>   typedef void (*l_tls_destroy_cb_t)(void *user_data);
>   =

> -
>   /*
>    * app_data_handler gets called with newly received decrypted data.
>    * tx_handler gets called to send TLS payloads off to remote end.
> @@ -107,6 +110,9 @@ bool l_tls_set_auth_data(struct l_tls *tls, const cha=
r *cert_path,
>   				const char *priv_key_path,
>   				const char *priv_key_passphrase);
>   =

> +void l_tls_set_version_range(struct l_tls *tls,
> +				uint16_t min_version, uint16_t max_version);
> +

Same here?

>   const char *l_tls_alert_to_str(enum l_tls_alert_desc desc);
>   =

>   enum l_checksum_type;
> =


Regards,
-Denis

--===============4138038013278008814==--

