Content-Type: multipart/mixed; boundary="===============6471049529196922361=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] genl: Introduce new api
Date: Thu, 26 Feb 2015 08:55:19 -0800
Message-ID: <7E440C67-68A8-4BA9-BD69-F5B440787866@holtmann.org>
In-Reply-To: <1424956885-14271-1-git-send-email-ravikumar.veeramally@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6471049529196922361==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ravi,

> Introducing l_genl_family_send_and_unref, l_genl_family_dump_and_unref
> wrapper functions for l_genl_family_send and l_genl_family_dump
> but it unref the message no matter of what the result is.
> ---
> ell/genl.c | 30 ++++++++++++++++++++++++++++++
> ell/genl.h | 10 ++++++++++
> 2 files changed, 40 insertions(+)
> =

> diff --git a/ell/genl.c b/ell/genl.c
> index 2ef6a34..97eac85 100644
> --- a/ell/genl.c
> +++ b/ell/genl.c
> @@ -1091,6 +1091,21 @@ unsigned int l_genl_family_send(struct l_genl_fami=
ly *family,
> 						user_data, destroy);
> }
> =

> +unsigned int l_genl_family_send_and_unref(struct l_genl_family *family,
> +						struct l_genl_msg *msg,
> +						l_genl_msg_func_t callback,
> +						void *user_data,
> +						l_genl_destroy_func_t destroy)
> +{
> +	unsigned int id;
> +
> +	id =3D l_genl_family_send(family, msg, callback, user_data, destroy);
> +	l_genl_msg_unref(msg);
> +	msg =3D NULL;

remove the msg =3D NULL here. That is useless. Once you leave the scope of =
this function, that pointer is no longer valid anyway.

Remember that these pointers are local to its function. You can not change =
the pointer in the caller this way.

> +
> +	return id;
> +}
> +
> unsigned int l_genl_family_dump(struct l_genl_family *family,
> 				struct l_genl_msg *msg, l_genl_msg_func_t callback,
> 				void *user_data, l_genl_destroy_func_t destroy)
> @@ -1099,6 +1114,21 @@ unsigned int l_genl_family_dump(struct l_genl_fami=
ly *family,
> 							user_data, destroy);
> }
> =

> +unsigned int l_genl_family_dump_and_unref(struct l_genl_family *family,
> +						struct l_genl_msg *msg,
> +						l_genl_msg_func_t callback,
> +						void *user_data,
> +						l_genl_destroy_func_t destroy)
> +{
> +	unsigned int id;
> +
> +	id =3D l_genl_family_dump(family, msg, callback, user_data, destroy);
> +	l_genl_msg_unref(msg);
> +	msg =3D NULL;

Same as above.

> +
> +	return id;
> +}
> +
> static bool match_request_id(const void *a, const void *b)
> {
> 	const struct genl_request *request =3D a;
> diff --git a/ell/genl.h b/ell/genl.h
> index c628b8c..1f58a94 100644
> --- a/ell/genl.h
> +++ b/ell/genl.h
> @@ -101,9 +101,19 @@ bool l_genl_family_can_dump(struct l_genl_family *fa=
mily, uint8_t cmd);
> unsigned int l_genl_family_send(struct l_genl_family *family,
> 				struct l_genl_msg *msg, l_genl_msg_func_t callback,
> 				void *user_data, l_genl_destroy_func_t destroy);
> +unsigned int l_genl_family_send_and_unref(struct l_genl_family *family,
> +						struct l_genl_msg *msg,
> +						l_genl_msg_func_t callback,
> +						void *user_data,
> +						l_genl_destroy_func_t destroy);
> unsigned int l_genl_family_dump(struct l_genl_family *family,
> 				struct l_genl_msg *msg, l_genl_msg_func_t callback,
> 				void *user_data, l_genl_destroy_func_t destroy);
> +unsigned int l_genl_family_dump_and_unref(struct l_genl_family *family,
> +						struct l_genl_msg *msg,
> +						l_genl_msg_func_t callback,
> +						void *user_data,
> +						l_genl_destroy_func_t destroy);
> bool l_genl_family_cancel(struct l_genl_family *family, unsigned int id);

Regards

Marcel


--===============6471049529196922361==--

