Content-Type: multipart/mixed; boundary="===============6465377837841377710=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 6/9] cert: Rename l_certchain_foreach functions
Date: Tue, 27 Nov 2018 21:50:56 -0600
Message-ID: <809aced3-6ff0-ad21-a678-3a506a82c0ba@gmail.com>
In-Reply-To: <20181128023835.2081-6-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6465377837841377710==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/27/2018 08:38 PM, Andrew Zaborowski wrote:
> Change the "foreach" to "walk" in l_certchain_foreach_from_leaf/_ca
> and in l_cert_foreach_cb_t to not imply that the whole chain is always
> traversed because we let the callbacks interrupt the iteration by
> returning true.  This can be used for searches or trust verification, or
> can be ignored if the whole chain is to be walked over.  Add comments
> for the two functions affected.
> ---
>   ell/cert.c  | 18 ++++++++++++++----
>   ell/cert.h  | 12 +++++-------
>   ell/ell.sym |  4 ++--
>   ell/tls.c   |  4 ++--
>   4 files changed, 23 insertions(+), 15 deletions(-)
> =

> diff --git a/ell/cert.c b/ell/cert.c
> index 66433c2..0ecdfbb 100644
> --- a/ell/cert.c
> +++ b/ell/cert.c
> @@ -253,8 +253,13 @@ LIB_EXPORT struct l_cert *l_certchain_get_leaf(struc=
t l_certchain *chain)
>   	return chain->leaf;
>   }
>   =

> -LIB_EXPORT bool l_certchain_foreach_from_leaf(struct l_certchain *chain,
> -						l_cert_foreach_cb_t cb,
> +/*
> + * Call @cb for each certificate in the chain starting from the leaf
> + * certificate.  If a call returns @true, stop and return @true to
> + * the user, otherwise return @false.
> + */
> +LIB_EXPORT bool l_certchain_walk_from_leaf(struct l_certchain *chain,
> +						l_cert_walk_cb_t cb,

I still don't understand what use the return value could be to the =

caller.  You don't even use the return value, so that reinforces my view =

that it is of dubious value.  Can we just make this return void?

Regards,
-Denis

--===============6465377837841377710==--

