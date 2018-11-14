Content-Type: multipart/mixed; boundary="===============8885271289541260117=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 07/12] tls: Add support for PRFs other than P_SHA256
Date: Wed, 14 Nov 2018 15:11:55 -0600
Message-ID: <959bbb3c-960f-5b97-75b6-2ae3366612ea@gmail.com>
In-Reply-To: <20181114131902.1695-7-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8885271289541260117==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/14/2018 07:18 AM, Andrew Zaborowski wrote:
> Add the ability for the cipher suite to define a PRF hash other than
> SHA256 but without allowing PRFs other than the RFC5246 TLS PRF (called
> P_hash) for now.  All our cipher suites until recently were specified in
> RFC5256 and so all used P_SHA256.  Other RFCs define cipher suites that
> use different hash algorithms for the TLS PRF but I haven't seen a
> definition of a completely different PRF so far.  We already have unit
> tests for P_SHA256, P_SHA238 and P_SHA512.
> =

> l_tls_prf_get_bytes and tls_prf_get_bytes don't take the hash type
> parameter anymore, this is backwards incompatible and TLS-based EAP method
> implementations need to be updated.

Are you sending patches for these?

> ---
>   ell/tls-private.h |  8 ++---
>   ell/tls.c         | 89 ++++++++++++++++++++++++++++-------------------
>   ell/tls.h         |  4 +--
>   3 files changed, 58 insertions(+), 43 deletions(-)
> =

> diff --git a/ell/tls-private.h b/ell/tls-private.h
> index a562846..4f98cfe 100644
> --- a/ell/tls-private.h
> +++ b/ell/tls-private.h
> @@ -91,6 +91,7 @@ struct tls_cipher_suite {
>   	struct tls_bulk_encryption_algorithm *encryption;
>   	struct tls_key_exchange_algorithm *key_xchg;
>   	struct tls_mac_algorithm *mac;
> +	enum l_checksum_type prf_hmac;
>   };
>   =

>   struct tls_compression_method {
> @@ -123,8 +124,8 @@ enum tls_content_type {
>    * Finished message.  If we're sent a hash of a different type (in TLS =
1.2+)
>    * and need to verify we'll give up.
>    * SHA1 and MD5 are explicitly required by versions < 1.2 and 1.2 requi=
res
> - * that the Finished hash is the same as used for the PRF, which in all
> - * our supported cipher suites is defined to be SHA256.
> + * that the Finished hash is the same as used for the PRF so we need to
> + * keep at least the hashes our supported cipher suites specify for the =
PRF.
>    */
>   enum handshake_hash_type {
>   	HANDSHAKE_HASH_SHA256,
> @@ -134,8 +135,6 @@ enum handshake_hash_type {
>   };
>   #define HANDSHAKE_HASH_MAX_SIZE	32
>   =

> -#define HANDSHAKE_HASH_TLS12 HANDSHAKE_HASH_SHA256
> -
>   struct l_tls {
>   	bool server;
>   =

> @@ -178,6 +177,7 @@ struct l_tls {
>   	struct l_key *peer_pubkey;
>   	size_t peer_pubkey_size;
>   	enum handshake_hash_type signature_hash;
> +	const struct tls_hash_algorithm *prf_hmac;
>   =

>   	/* SecurityParameters current and pending */
>   =

> diff --git a/ell/tls.c b/ell/tls.c
> index fab4ce6..93a3bd5 100644
> --- a/ell/tls.c
> +++ b/ell/tls.c
> @@ -114,39 +114,35 @@ void tls12_prf(enum l_checksum_type type, size_t ha=
sh_len,
>   }
>   =

>   void tls_prf_get_bytes(struct l_tls *tls,
> -				enum l_checksum_type type, size_t hash_len,
>   				const void *secret, size_t secret_len,
>   				const char *label,
>   				const void *seed, size_t seed_len,
>   				uint8_t *buf, size_t len)
>   {
>   	if (tls->negotiated_version >=3D TLS_V12)
> -		tls12_prf(type, hash_len, secret, secret_len, label,
> +		tls12_prf(tls->prf_hmac->l_id, tls->prf_hmac->length,
> +				secret, secret_len, label,
>   				seed, seed_len, buf, len);
>   	else
>   		tls10_prf(secret, secret_len, label, seed, seed_len, buf, len);
>   }
>   =

> -LIB_EXPORT bool l_tls_prf_get_bytes(struct l_tls *tls,
> -				enum l_checksum_type type,
> -				size_t hash_len, bool use_master_secret,
> +LIB_EXPORT bool l_tls_prf_get_bytes(struct l_tls *tls, bool use_master_s=
ecret,
>   				const char *label, uint8_t *buf, size_t len)
>   {
>   	uint8_t seed[64];
>   =

> -	if (unlikely(!tls))
> +	if (unlikely(!tls || !tls->prf_hmac))
>   		return false;
>   =

>   	memcpy(seed +  0, tls->pending.client_random, 32);
>   	memcpy(seed + 32, tls->pending.server_random, 32);
>   =

>   	if (use_master_secret)
> -		tls_prf_get_bytes(tls, type, hash_len,
> -						tls->pending.master_secret, 48,
> -						label, seed, 64, buf, len);
> +		tls_prf_get_bytes(tls, tls->pending.master_secret, 48,
> +					label, seed, 64, buf, len);
>   	else
> -		tls_prf_get_bytes(tls, type, hash_len, "", 0,
> -						label, seed, 64, buf, len);
> +		tls_prf_get_bytes(tls, "", 0, label, seed, 64, buf, len);
>   =

>   	memset(seed, 0, 64);
>   =

> @@ -568,6 +564,21 @@ err:
>   	return false;
>   }
>   =

> +static void tls_set_prf_hmac(struct l_tls *tls)
> +{
> +	enum handshake_hash_type hash;
> +
> +	if (tls->pending.cipher_suite->prf_hmac =3D=3D L_CHECKSUM_NONE) {
> +		tls->prf_hmac =3D &tls_handshake_hash_data[HANDSHAKE_HASH_SHA256];
> +		return;
> +	}
> +
> +	for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
> +		if (tls_handshake_hash_data[hash].l_id =3D=3D
> +				tls->pending.cipher_suite->prf_hmac)
> +			tls->prf_hmac =3D &tls_handshake_hash_data[hash];

No break?

And also no return value?  If this is guaranteed to succeed, then a =

comment might be needed.

> +}
> +
>   enum tls_handshake_type {
>   	TLS_HELLO_REQUEST	=3D 0,
>   	TLS_CLIENT_HELLO	=3D 1,
> @@ -972,8 +983,7 @@ static void tls_generate_master_secret(struct l_tls *=
tls,
>   	memcpy(seed +  0, tls->pending.client_random, 32);
>   	memcpy(seed + 32, tls->pending.server_random, 32);
>   =

> -	tls_prf_get_bytes(tls, L_CHECKSUM_SHA256, 32,
> -				pre_master_secret, pre_master_secret_len,
> +	tls_prf_get_bytes(tls, pre_master_secret, pre_master_secret_len,
>   				"master secret", seed, 64,
>   				tls->pending.master_secret, 48);
>   =

> @@ -1003,8 +1013,7 @@ static void tls_generate_master_secret(struct l_tls=
 *tls,
>   	memcpy(seed +  0, tls->pending.server_random, 32);
>   	memcpy(seed + 32, tls->pending.client_random, 32);
>   =

> -	tls_prf_get_bytes(tls, L_CHECKSUM_SHA256, 32,
> -				tls->pending.master_secret, 48,
> +	tls_prf_get_bytes(tls, tls->pending.master_secret, 48,
>   				"key expansion", seed, 64,
>   				tls->pending.key_block, key_block_size);
>   =

> @@ -1267,10 +1276,10 @@ static bool tls_send_certificate_verify(struct l_=
tls *tls)
>   	if (sign_len < 0)
>   		return false;
>   =

> -	/* Stop maintaining handshake message hashes other than SHA256. */
> +	/* Stop maintaining handshake message hashes other than the PRF hash */
>   	if (tls->negotiated_version >=3D TLS_V12)
>   		for (i =3D 0; i < __HANDSHAKE_HASH_COUNT; i++)
> -			if (i !=3D HANDSHAKE_HASH_SHA256)
> +			if (&tls_handshake_hash_data[i] !=3D tls->prf_hmac)
>   				tls_drop_handshake_hash(tls, i);
>   =

>   	tls_tx_handshake(tls, TLS_CERTIFICATE_VERIFY, buf,
> @@ -1294,23 +1303,22 @@ static void tls_send_finished(struct l_tls *tls)
>   	size_t seed_len;
>   =

>   	if (tls->negotiated_version >=3D TLS_V12) {
> -		/*
> -		 * Same hash type as that used for the PRF, i.e. SHA256
> -		 * unless an exotic cipher suite was negotiated that
> -		 * dictates a different hash for the PRF and for the
> -		 * Finished hash.  We don't support any such ciphers so
> -		 * it's always SHA256.
> -		 */
> -		tls_get_handshake_hash(tls, HANDSHAKE_HASH_TLS12, seed);
> -		seed_len =3D tls_handshake_hash_data[HANDSHAKE_HASH_TLS12].length;
> +		/* Same hash type as that used for the PRF (usually SHA256) */
> +		enum handshake_hash_type hash;
> +
> +		for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
> +			if (&tls_handshake_hash_data[hash] =3D=3D tls->prf_hmac)
> +				break;
> +
> +		tls_get_handshake_hash(tls, hash, seed);
> +		seed_len =3D tls_handshake_hash_data[hash].length;
>   	} else {
>   		tls_get_handshake_hash(tls, HANDSHAKE_HASH_MD5, seed + 0);
>   		tls_get_handshake_hash(tls, HANDSHAKE_HASH_SHA1, seed + 16);
>   		seed_len =3D 36;
>   	}
>   =

> -	tls_prf_get_bytes(tls, L_CHECKSUM_SHA256, 32,
> -				tls->pending.master_secret, 48,
> +	tls_prf_get_bytes(tls, tls->pending.master_secret, 48,
>   				tls->server ? "server finished" :
>   				"client finished",
>   				seed, seed_len,
> @@ -1336,8 +1344,14 @@ static bool tls_verify_finished(struct l_tls *tls,=
 const uint8_t *received,
>   	}
>   =

>   	if (tls->negotiated_version >=3D TLS_V12) {
> -		seed =3D tls->prev_digest[HANDSHAKE_HASH_TLS12];
> -		seed_len =3D tls_handshake_hash_data[HANDSHAKE_HASH_TLS12].length;
> +		enum handshake_hash_type hash;
> +
> +		for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
> +			if (&tls_handshake_hash_data[hash] =3D=3D tls->prf_hmac)
> +				break;
> +
> +		seed =3D tls->prev_digest[hash];
> +		seed_len =3D tls_handshake_hash_data[hash].length;
>   	} else {
>   		seed =3D alloca(36);
>   		memcpy(seed + 0, tls->prev_digest[HANDSHAKE_HASH_MD5], 16);
> @@ -1345,8 +1359,7 @@ static bool tls_verify_finished(struct l_tls *tls, =
const uint8_t *received,
>   		seed_len =3D 36;
>   	}
>   =

> -	tls_prf_get_bytes(tls, L_CHECKSUM_SHA256, 32,
> -				tls->pending.master_secret, 48,
> +	tls_prf_get_bytes(tls, tls->pending.master_secret, 48,
>   				tls->server ? "client finished" :
>   				"server finished",
>   				seed, seed_len,
> @@ -1488,6 +1501,8 @@ static void tls_handle_client_hello(struct l_tls *t=
ls,
>   		return;
>   	}
>   =

> +	tls_set_prf_hmac(tls);
> +
>   	TLS_DEBUG("Negotiated %s", tls->pending.cipher_suite->name);
>   =

>   	/* Select a compression method */
> @@ -1598,6 +1613,8 @@ static void tls_handle_server_hello(struct l_tls *t=
ls,
>   		return;
>   	}
>   =

> +	tls_set_prf_hmac(tls);
> +
>   	TLS_DEBUG("Negotiated %s", tls->pending.cipher_suite->name);
>   =

>   	tls->pending.compression_method =3D
> @@ -1839,11 +1856,11 @@ static void tls_handle_certificate_request(struct=
 l_tls *tls,
>   =

>   		/*
>   		 * We can now safely stop maintaining handshake message
> -		 * hashes other than SHA256 and the one selected for
> +		 * hashes other than the PRF hash and the one selected for
>   		 * signing.
>   		 */
>   		for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
> -			if (hash !=3D HANDSHAKE_HASH_SHA256 &&
> +			if (&tls_handshake_hash_data[hash] !=3D tls->prf_hmac &&
>   					hash !=3D tls->signature_hash)
>   				tls_drop_handshake_hash(tls, hash);
>   	}
> @@ -1991,10 +2008,10 @@ static void tls_handle_certificate_verify(struct =
l_tls *tls,
>   						tls_get_prev_digest_by_id))
>   		return;
>   =

> -	/* Stop maintaining handshake message hashes other than SHA256. */
> +	/* Stop maintaining handshake message hashes other than the PRF hash */
>   	if (tls->negotiated_version >=3D TLS_V12)
>   		for (i =3D 0; i < __HANDSHAKE_HASH_COUNT; i++)
> -			if (i !=3D HANDSHAKE_HASH_SHA256)
> +			if (&tls_handshake_hash_data[i] !=3D tls->prf_hmac)
>   				tls_drop_handshake_hash(tls, i);
>   =

>   	/*
> diff --git a/ell/tls.h b/ell/tls.h
> index 893fd63..e1a5a21 100644
> --- a/ell/tls.h
> +++ b/ell/tls.h
> @@ -108,9 +108,7 @@ const char *l_tls_alert_to_str(enum l_tls_alert_desc =
desc);
>   =

>   enum l_checksum_type;
>   =

> -bool l_tls_prf_get_bytes(struct l_tls *tls,
> -				enum l_checksum_type type,
> -				size_t hash_len, bool use_master_secret,
> +bool l_tls_prf_get_bytes(struct l_tls *tls, bool use_master_secret,
>   				const char *label, uint8_t *buf, size_t len);
>   =

>   bool l_tls_set_debug(struct l_tls *tls, l_tls_debug_cb_t function,
> =


Regards,
-Denis

--===============8885271289541260117==--

