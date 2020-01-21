Content-Type: multipart/mixed; boundary="===============6748809431438903184=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: [PATCH] ringbuf: Add l_ringbuf_append function
Date: Tue, 21 Jan 2020 10:04:33 -0800
Message-ID: <CAPyD+=DFELkYyFS6bbe1zXWg0NpihyeZ76CnNGtWJ-HSvPDKhA@mail.gmail.com>
In-Reply-To: <20200121081506.19626-1-przemyslaw.fierek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6748809431438903184==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 21, 2020 at 12:15 AM Przemys=C5=82aw Fierek
<przemyslaw.fierek@silvair.com> wrote:
> +ssize_t l_ringbuf_append(struct l_ringbuf *ringbuf, void *data, ssize_t =
len)
> +{
> +       size_t avail, offset, end, left;
> +
> +       if (!ringbuf || data =3D=3D NULL)
> +               return -1;

"len" can be less than zero since ssize_t is signed.  I believe you
should also return -1 in that case as well.

Assuming your want to make this function part of the public l_ringbuf
API, shouldn't you also add l_ringbuf_append to the symbol table in
ell.sym?

-Ossama



-Ossama

> +
> +       /* Determine how much can actually be appended */
> +       avail =3D ringbuf->size - ringbuf->in + ringbuf->out;
> +
> +       if (!avail)
> +               return -1;
> +
> +       /* Determine how much to append before wrapping */
> +       offset =3D ringbuf->in & (ringbuf->size - 1);
> +       end =3D minsize((size_t) len, ringbuf->size - offset);
> +       memcpy(ringbuf->buffer + offset, data, end);
> +
> +       if (ringbuf->in_tracing)
> +               ringbuf->in_tracing(ringbuf->buffer + offset, end,
> +                                               ringbuf->in_data);
> +
> +       left =3D minsize(avail - end, len - end);
> +
> +       if (left > 0) {
> +               memcpy(ringbuf->buffer, data + end, left);
> +
> +               if (ringbuf->in_tracing)
> +                       ringbuf->in_tracing(ringbuf->buffer, left,
> +                                               ringbuf->in_data);
> +       }
> +
> +       ringbuf->in +=3D end + left;
> +
> +       return (end + left);
> +}
> diff --git a/ell/ringbuf.h b/ell/ringbuf.h
> index 846f7a5..05a37d2 100644
> --- a/ell/ringbuf.h
> +++ b/ell/ringbuf.h
> @@ -58,6 +58,8 @@ int l_ringbuf_vprintf(struct l_ringbuf *ringbuf, const =
char *format,
>                                         va_list ap);
>  ssize_t l_ringbuf_read(struct l_ringbuf *ringbuf, int fd);
>
> +ssize_t l_ringbuf_append(struct l_ringbuf *ringbuf, void *data, ssize_t =
len);
> +
>  #ifdef __cplusplus
>  }
>  #endif
> --
> 2.17.1
> _______________________________________________
> ell mailing list -- ell(a)lists.01.org
> To unsubscribe send an email to ell-leave(a)lists.01.org
--===============6748809431438903184==--

