Content-Type: multipart/mixed; boundary="===============7614650024333750416=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] gvariant: Exclude container's offsets from child iterator
 len.
Date: Mon, 21 Mar 2016 12:57:17 -0500
Message-ID: <56F035FD.2050301@gmail.com>
In-Reply-To: <1458367247-14607-5-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7614650024333750416==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/19/2016 01:00 AM, Andrew Zaborowski wrote:
> ---
>   ell/gvariant-util.c | 10 +++++++++-
>   1 file changed, 9 insertions(+), 1 deletion(-)
>
> diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
> index 1aaddc3..61e5b52 100644
> --- a/ell/gvariant-util.c
> +++ b/ell/gvariant-util.c
> @@ -497,6 +497,7 @@ static const void *next_item(struct l_dbus_message_it=
er *iter,
>   	bool last_member;
>   	unsigned int sig_len;
>   	unsigned int offset_len;
> +	unsigned int len =3D iter->len;

Looks like this belongs in the if block below.

>
>   	memcpy(sig, iter->sig_start + iter->sig_pos,
>   			iter->sig_len - iter->sig_pos);
> @@ -529,7 +530,14 @@ static const void *next_item(struct l_dbus_message_i=
ter *iter,
>   	}
>
>   	if (iter->container_type !=3D DBUS_CONTAINER_TYPE_ARRAY && last_member=
) {
> -		*out_item_size =3D iter->len - iter->pos;
> +		offset_len =3D offset_length(iter->len, 0);
> +		len =3D iter->len;
> +
> +		if (iter->offsets && iter->offsets + offset_len <
> +				iter->data + len)
> +			len =3D iter->offsets + offset_len - iter->data;
> +
> +		*out_item_size =3D len - iter->pos;

This looks fine to me.  I'm guessing the location of the child =

iterator's offsets was being messed up?  Hence variable length field =

sizes were incorrect.  Right?

>   		goto done;
>   	}
>
>

Regards,
-Denis

--===============7614650024333750416==--

