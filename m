Content-Type: multipart/mixed; boundary="===============1030870386695694873=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] genl: Add utility function no append nested attribute
 into a message
Date: Tue, 03 Mar 2015 11:12:28 -0800
Message-ID: <6F40A411-9857-48C3-A47D-11F1C8D51CFF@holtmann.org>
In-Reply-To: <1424865990-7503-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1030870386695694873==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tomasz,

> It will fill-in a l_genl_attr structure with the necessary information
> where the nested attribute starts. Thus at the end, it will update the
> nested attribute with the final length.
> ---
> ell/genl.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
> ell/genl.h |  3 +++
> 2 files changed, 51 insertions(+)
> =

> diff --git a/ell/genl.c b/ell/genl.c
> index 2ef6a34..b74f3c0 100644
> --- a/ell/genl.c
> +++ b/ell/genl.c
> @@ -707,6 +707,54 @@ bool l_genl_msg_append_attr(struct l_genl_msg *msg, =
uint16_t type,
> 	return true;
> }
> =

> +bool l_genl_msg_append_init_recurse(struct l_genl_msg *msg, uint16_t typ=
e,
> +						struct l_genl_attr *nested)
> +{
> +	struct nlattr *nla;
> +
> +	if (!msg || !nested)
> +		return false;
> +
> +	nla =3D msg->data + msg->len;
> +	nla->nla_len =3D NLA_HDRLEN;
> +	nla->nla_type =3D type;
> +
> +	if (!l_genl_msg_append_attr(msg, type, 0, NULL))
> +		return false;
> +
> +	nested->msg =3D msg;
> +	nested->data =3D nla;
> +	nested->len =3D 0;
> +	nested->next_data =3D NULL;
> +	nested->next_len =3D 0;
> +
> +	return true;
> +}
> +
> +bool l_genl_msg_append_end_recurse(struct l_genl_attr *nested)
> +{
> +	struct l_genl_msg *msg;
> +	struct nlattr *nla;
> +	uint32_t len;
> +
> +	if (!nested || !nested->msg)
> +		return false;
> +
> +	msg =3D nested->msg;
> +	len =3D nested->data - msg->data;
> +	nla =3D msg->data + len;
> +
> +	len =3D msg->len - len;
> +	if (len <=3D NLA_HDRLEN)
> +		return false;
> +
> +	nla->nla_len =3D len;
> +
> +	msg->len =3D NLA_ALIGN(msg->len);
> +
> +	return true;
> +}
> +
> #define NLA_OK(nla,len)         ((len) >=3D (int) sizeof(struct nlattr) &=
& \
> 				(nla)->nla_len >=3D sizeof(struct nlattr) && \
> 				(nla)->nla_len <=3D (len))
> diff --git a/ell/genl.h b/ell/genl.h
> index c628b8c..13fe149 100644
> --- a/ell/genl.h
> +++ b/ell/genl.h
> @@ -71,6 +71,9 @@ int l_genl_msg_get_error(struct l_genl_msg *msg);
> =

> bool l_genl_msg_append_attr(struct l_genl_msg *msg, uint16_t type,
> 					uint16_t len, const void *data);
> +bool l_genl_msg_append_init_recurse(struct l_genl_msg *msg, uint16_t typ=
e,
> +						struct l_genl_attr *nested);
> +bool l_genl_msg_append_end_recurse(struct l_genl_attr *nested);

so actually the l_genl_msg_append_attr was more like a interim solution for=
 getting this going until we have a full "writer" attribute iterator implem=
entation.

What I thinking is that when we want to support full generic netlink messag=
e building we need to actually start with creating a write API with an iter=
ator concept. We actually want to have D-Bus and generic netlink handling s=
imilar in their APIs.

I think l_genl_message_builder might be needed. Have you looked into how we=
 can make D-Bus and generic netlink similar in API. There will be differenc=
e in nuances, but in general, I prefer this is similar.

Regards

Marcel


--===============1030870386695694873==--

