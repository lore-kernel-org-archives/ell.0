Content-Type: multipart/mixed; boundary="===============0184427385142509958=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 3/6] pem: convert l_pem_load_buffer to take void*
Date: Tue, 01 Oct 2019 14:00:46 -0500
Message-ID: <5bd3c71a-c3ee-84ad-17a7-b375ecc22248@gmail.com>
In-Reply-To: <20191001164743.23088-3-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0184427385142509958==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/1/19 11:47 AM, James Prestwood wrote:
> This handles both cases of PEM's being loaded as text data and
> as raw bytes. is_{start,end}_boundary was also converted.
> ---
>   ell/pem.c | 55 ++++++++++++++++++++++++++++++-------------------------
>   ell/pem.h |  4 ++--
>   2 files changed, 32 insertions(+), 27 deletions(-)
> =

> diff --git a/ell/pem.c b/ell/pem.c
> index 721a05b..671f162 100644
> --- a/ell/pem.c
> +++ b/ell/pem.c
> @@ -49,11 +49,12 @@
>   #define PEM_START_BOUNDARY	"-----BEGIN "
>   #define PEM_END_BOUNDARY	"-----END "
>   =

> -static const uint8_t *is_start_boundary(const uint8_t *buf, size_t buf_l=
en,
> +static const void *is_start_boundary(const void *buf, size_t buf_len,
>   					size_t *label_len)

So I made this return const char * for consistency since you use const =

char *label in is_end_boundary()

>   {
>   	const uint8_t *start, *end, *ptr;

And const char * here

>   	int prev_special, special;
> +	const uint8_t *buf_ptr =3D buf;

and here

>   =

>   	if (buf_len < strlen(PEM_START_BOUNDARY))
>   		return NULL;

<snip>

> @@ -102,33 +103,36 @@ static const uint8_t *is_start_boundary(const uint8=
_t *buf, size_t buf_len,
>   	return start;
>   }
>   =

> -static bool is_end_boundary(const uint8_t *buf, size_t buf_len,
> -				const uint8_t *label, size_t label_len)
> +static bool is_end_boundary(const void *buf, size_t buf_len,
> +				const char *label, size_t label_len)
>   {
> +	const uint8_t *buf_ptr =3D buf;

const char * here

Applied, thanks.

Regards,
-Denis
--===============0184427385142509958==--

