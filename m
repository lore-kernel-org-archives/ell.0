Content-Type: multipart/mixed; boundary="===============9058612446331737327=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/4] tls: Make l_tls_free reentrant
Date: Wed, 07 Aug 2019 17:58:03 -0500
Message-ID: <8a5f41f4-7af7-b257-d811-38f89d489175@gmail.com>
In-Reply-To: <20190806134514.6340-3-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9058612446331737327==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 8/6/19 8:45 AM, Andrew Zaborowski wrote:
> Handle l_tls_free being called from inside user callbacks that our code
> may have called.  Use flags because in this case it's not possible to
> move all of the callbacks to the end of our functions.
> ---
>   ell/tls-private.h |  3 +++
>   ell/tls.c         | 19 +++++++++++++++++++
>   2 files changed, 22 insertions(+)
> =


Applied, thanks.

> diff --git a/ell/tls-private.h b/ell/tls-private.h
> index bf9e2ec..c1de257 100644
> --- a/ell/tls-private.h
> +++ b/ell/tls-private.h
> @@ -215,6 +215,9 @@ struct l_tls {
>   =

>   	struct tls_cipher_suite **cipher_suite_pref_list;
>   =

> +	bool in_callback;
> +	bool pending_destroy;
> +
>   	/* Record layer */
>   =

>   	uint8_t *record_buf;

By the way, do you want to make all these bools here a bitfield instead?

Regards,
-Denis

--===============9058612446331737327==--

