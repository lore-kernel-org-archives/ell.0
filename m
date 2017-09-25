Content-Type: multipart/mixed; boundary="===============2304259337533965308=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 4/4] genl: Fix termination of name strings
Date: Mon, 25 Sep 2017 10:01:16 -0500
Message-ID: <3f6b2a0a-6a49-5207-2651-9d3146b3f9ef@gmail.com>
In-Reply-To: <20170922221244.12670-5-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2304259337533965308==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 09/22/2017 05:12 PM, Mat Martineau wrote:
> The genl_mcast and l_genl_family structs both have name fields of length
> GENL_NAMSIZ. They are expected to be null terminated strings, but
> strncpy() was being misused and not terminating long names
> correctly. Depending on the context, this would result in an
> unterminated string being passed to strcmp() or a kernel warning.
> ---
>   ell/genl.c | 6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
> =

> diff --git a/ell/genl.c b/ell/genl.c
> index 0ab6c98..b41a174 100644
> --- a/ell/genl.c
> +++ b/ell/genl.c
> @@ -156,7 +156,7 @@ static struct l_genl_family *family_alloc(struct l_ge=
nl *genl,
>   	family =3D l_new(struct l_genl_family, 1);
>   =

>   	family->genl =3D genl;
> -	strncpy(family->name, name, GENL_NAMSIZ);
> +	l_strlcpy(family->name, name, GENL_NAMSIZ);

It would seem that l_genl_family_new should sanitize the name.  There's =

no point in truncating a name silently and trying to use it afterwards =

just to fail spectacularly anyway.

>   =

>   	family->op_list =3D l_queue_new();
>   	family->mcast_list =3D l_queue_new();
> @@ -232,7 +232,7 @@ static void family_add_mcast(struct l_genl_family *fa=
mily, const char *name,
>   =

>   	mcast =3D l_new(struct genl_mcast, 1);
>   =

> -	strncpy(mcast->name, name, GENL_NAMSIZ);
> +	l_strlcpy(mcast->name, name, GENL_NAMSIZ);
>   	mcast->id =3D id;
>   	mcast->users =3D 0;
>   =

> @@ -1047,7 +1047,7 @@ static void get_family_callback(struct l_genl_msg *=
msg, void *user_data)
>   			family->id =3D *((uint16_t *) data);
>   			break;
>   		case CTRL_ATTR_FAMILY_NAME:
> -			strncpy(family->name, data, GENL_NAMSIZ);
> +			l_strlcpy(family->name, data, GENL_NAMSIZ);
>   			break;
>   		case CTRL_ATTR_VERSION:
>   			family->version =3D *((uint32_t *) data);
> =


The other two are not called with user input but get their values from =

the kernel, no?

Regards,
-Denis

--===============2304259337533965308==--

