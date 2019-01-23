Content-Type: multipart/mixed; boundary="===============7673045409501027050=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] key: Avoid using C++ keywords as param names.
Date: Wed, 23 Jan 2019 13:10:43 -0600
Message-ID: <abcd04a7-68b0-4338-2c85-48599ad81060@gmail.com>
In-Reply-To: <20190123190610.3787-2-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7673045409501027050==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 01/23/2019 01:06 PM, Ossama Othman wrote:
> Rename the parameter names "public" and "private" to avoid conflicts
> with the similarly named C++ keywords.  Addresses compile-time errors
> in C++ code that includes <ell/key.h>.

Ugh... Are you seriously using ell in a C++ application?  ;)

> ---
>   ell/key.h | 6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
> =

> diff --git a/ell/key.h b/ell/key.h
> index 024afc6..0107b05 100644
> --- a/ell/key.h
> +++ b/ell/key.h
> @@ -70,16 +70,16 @@ ssize_t l_key_get_payload_size(struct l_key *key);
>   =

>   bool l_key_get_info(struct l_key *key, enum l_key_cipher_type cipher,
>   			enum l_checksum_type checksum, size_t *bits,
> -			bool *public);
> +			bool *_public);

out_public please

>   =

>   struct l_key *l_key_generate_dh_private(const void *prime_buf,
>   					size_t prime_len);
>   =

> -bool l_key_compute_dh_public(struct l_key *generator, struct l_key *priv=
ate,
> +bool l_key_compute_dh_public(struct l_key *generator, struct l_key *_pri=
vate,

And just call this private_key or private_secret

>   				struct l_key *prime,
>   				void *payload, size_t *len);
>   =

> -bool l_key_compute_dh_secret(struct l_key *other_public, struct l_key *p=
rivate,
> +bool l_key_compute_dh_secret(struct l_key *other_public, struct l_key *_=
private,
>   				struct l_key *prime,
>   				void *payload, size_t *len);
>   =


As above.

> =


Regards,
-Denis

--===============7673045409501027050==--

