Content-Type: multipart/mixed; boundary="===============8494664108960830106=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Przemys=C5=82aw?= Fierek <przemyslaw.fierek@silvair.com>
Subject: Re: [PATCH v2] ringbuf: Add l_ringbuf_append function
Date: Fri, 24 Jan 2020 13:59:43 +0100
Message-ID: <eeb15983-a884-7bff-b028-c87b74121947@silvair.com>
In-Reply-To: <20200122115606.19382-1-przemyslaw.fierek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8494664108960830106==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 22.01.2020 12:56, Przemys=C5=82aw Fierek wrote:
> ---
>   ell/ell.sym   |  1 +
>   ell/ringbuf.c | 69 ++++++++++++++++++++++++++++++++++++---------------
>   ell/ringbuf.h |  2 ++
>   3 files changed, 52 insertions(+), 20 deletions(-)
>
> diff --git a/ell/ell.sym b/ell/ell.sym
> index d759de6..46df1bd 100644
> --- a/ell/ell.sym
> +++ b/ell/ell.sym
> @@ -395,6 +395,7 @@ global:
>   	l_ringbuf_printf;
>   	l_ringbuf_vprintf;
>   	l_ringbuf_read;
> +	l_ringbuf_append;
>   	/* settings */
>   	l_settings_new;
>   	l_settings_free;
> diff --git a/ell/ringbuf.c b/ell/ringbuf.c
> index 49f370c..7c9777c 100644
> --- a/ell/ringbuf.c
> +++ b/ell/ringbuf.c
> @@ -321,7 +321,7 @@ LIB_EXPORT int l_ringbuf_printf(struct l_ringbuf *rin=
gbuf,
>   LIB_EXPORT int l_ringbuf_vprintf(struct l_ringbuf *ringbuf,
>   						const char *format, va_list ap)
>   {
> -	size_t avail, offset, end;
> +	size_t avail;
>   	char *str;
>   	int len;
>   =

> @@ -342,28 +342,10 @@ LIB_EXPORT int l_ringbuf_vprintf(struct l_ringbuf *=
ringbuf,
>   		return -1;
>   	}
>   =

> -	/* Determine possible length of string before wrapping */
> -	offset =3D ringbuf->in & (ringbuf->size - 1);
> -	end =3D minsize((size_t) len, ringbuf->size - offset);
> -	memcpy(ringbuf->buffer + offset, str, end);
> -
> -	if (ringbuf->in_tracing)
> -		ringbuf->in_tracing(ringbuf->buffer + offset, end,
> -							ringbuf->in_data);
> -
> -	if (len - end > 0) {
> -		/* Put the remainder of string at the beginning */
> -		memcpy(ringbuf->buffer, str + end, len - end);
> -
> -		if (ringbuf->in_tracing)
> -			ringbuf->in_tracing(ringbuf->buffer, len - end,
> -							ringbuf->in_data);
> -	}
> +	len =3D l_ringbuf_append(ringbuf, str, (size_t) len);
>   =

>   	l_free(str);
>   =

> -	ringbuf->in +=3D len;
> -
>   	return len;
>   }
>   =

> @@ -420,3 +402,50 @@ LIB_EXPORT ssize_t l_ringbuf_read(struct l_ringbuf *=
ringbuf, int fd)
>   =

>   	return consumed;
>   }
> +
> +/**
> + * l_ringbuf_append:
> + * @ringbuf: Ring Buffer object
> + * @data: data to be appended
> + * @len: data length
> + *
> + * Appends data to the ring buffer.
> + *
> + * Returns: Number of appended bytes or -1 if the append failed.
> + **/
> +ssize_t l_ringbuf_append(struct l_ringbuf *ringbuf, void *data, size_t l=
en)
> +{
> +	size_t avail, offset, end, left;
> +
> +	if (!ringbuf || data =3D=3D NULL)
> +		return -1;
> +
> +	/* Determine how much can actually be appended */
> +	avail =3D ringbuf->size - ringbuf->in + ringbuf->out;
> +
> +	if (!avail)
> +		return -1;
> +
> +	/* Determine how much to append before wrapping */
> +	offset =3D ringbuf->in & (ringbuf->size - 1);
> +	end =3D minsize(len, ringbuf->size - offset);
> +	memcpy(ringbuf->buffer + offset, data, end);
> +
> +	if (ringbuf->in_tracing)
> +		ringbuf->in_tracing(ringbuf->buffer + offset, end,
> +						ringbuf->in_data);
> +
> +	left =3D minsize(avail - end, len - end);
> +
> +	if (left > 0) {
> +		memcpy(ringbuf->buffer, data + end, left);
> +
> +		if (ringbuf->in_tracing)
> +			ringbuf->in_tracing(ringbuf->buffer, left,
> +						ringbuf->in_data);
> +	}
> +
> +	ringbuf->in +=3D end + left;
> +
> +	return (end + left);
> +}
> diff --git a/ell/ringbuf.h b/ell/ringbuf.h
> index 846f7a5..ba41324 100644
> --- a/ell/ringbuf.h
> +++ b/ell/ringbuf.h
> @@ -58,6 +58,8 @@ int l_ringbuf_vprintf(struct l_ringbuf *ringbuf, const =
char *format,
>   					va_list ap);
>   ssize_t l_ringbuf_read(struct l_ringbuf *ringbuf, int fd);
>   =

> +ssize_t l_ringbuf_append(struct l_ringbuf *ringbuf, void *data, size_t l=
en);
> +
>   #ifdef __cplusplus
>   }
>   #endif

Hi,


I would ask about status of this patch. Does it require any extra =

changes or it is ready to merge?


Regards,

Przemek


--===============8494664108960830106==--

