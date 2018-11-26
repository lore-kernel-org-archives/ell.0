Content-Type: multipart/mixed; boundary="===============9017873331581194316=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/5] cert: Add comments about l_certchain_foreach_*
Date: Mon, 26 Nov 2018 14:07:29 -0600
Message-ID: <dd8a28c4-3875-1493-9a4e-7b19e760b8f5@gmail.com>
In-Reply-To: <20181123094429.7190-3-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9017873331581194316==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/23/2018 03:44 AM, Andrew Zaborowski wrote:
> ---
>   ell/cert.c | 10 ++++++++++
>   1 file changed, 10 insertions(+)
> =

> diff --git a/ell/cert.c b/ell/cert.c
> index 66433c2..7f0b694 100644
> --- a/ell/cert.c
> +++ b/ell/cert.c
> @@ -253,6 +253,11 @@ LIB_EXPORT struct l_cert *l_certchain_get_leaf(struc=
t l_certchain *chain)
>   	return chain->leaf;
>   }
>   =

> +/*
> + * Call @cb for each certificate in the chain starting from the leaf
> + * certificate.  If a call returns @true, stop and return @true to
> + * the user, otherwise return @false.
> + */
>   LIB_EXPORT bool l_certchain_foreach_from_leaf(struct l_certchain *chain,

This is weird to me actually.  Generally any time we use 'foreach', it =

means that the operation is performed on each node.  There are no =

termination semantics.

And what does the overall return value mean to the user?  How is it =

useful in the first place?

If you want early termination semantics, I would rewrite this as:

void l_certchain_walk_from_leaf()
and then l_certchain_foreach_cb_t -> l_certchain_walk_cb_t

Alternatively, use void l_certchain_foreach_from_leaf & drop the =

l_certchain_foreach_cb_t return value.

>   						l_cert_foreach_cb_t cb,
>   						void *user_data)
> @@ -269,6 +274,11 @@ LIB_EXPORT bool l_certchain_foreach_from_leaf(struct=
 l_certchain *chain,
>   	return false;
>   }
>   =

> +/*
> + * Call @cb for each certificate in the chain starting from the root
> + * certificate.  If a call returns @true, stop and return @true to
> + * the user, otherwise return @false.
> + */
>   LIB_EXPORT bool l_certchain_foreach_from_ca(struct l_certchain *chain,
>   						l_cert_foreach_cb_t cb,
>   						void *user_data)
> =


Regards,
-Denis

--===============9017873331581194316==--

