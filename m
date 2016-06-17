Content-Type: multipart/mixed; boundary="===============2523011084591006768=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH v4 3/6] cipher: Return result length from asymmetric cipher
Date: Thu, 16 Jun 2016 17:17:43 -0700
Message-ID: <alpine.OSX.2.20.1606161650380.26845@rabdelkh-mobl.amr.corp.intel.com>
In-Reply-To: <57633356.307@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2523011084591006768==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Thu, 16 Jun 2016, Denis Kenzior wrote:

> Hi Mat,
>
> On 06/15/2016 12:18 PM, Mat Martineau wrote:
>> Short reads from AF_ALG akcipher sockets can return an error rather
>> than a partial buffer so it's important to provide both an output
>> buffer length (which is typically longer than the expected data), and
>> to find out how many bytes were read.
>> ---
>>   ell/cipher.c      | 41 +++++++++++++-------------
>>   ell/cipher.h      | 16 +++++------
>>   ell/tls-private.h |  2 +-
>>   ell/tls.c         | 86 =

>> ++++++++++++++++++++++++++++++++++++-------------------
>>   4 files changed, 86 insertions(+), 59 deletions(-)
>> =

>> diff --git a/ell/cipher.c b/ell/cipher.c
>> index 04ef838..d1b3845 100644
>> --- a/ell/cipher.c
>> +++ b/ell/cipher.c
>> @@ -192,7 +192,7 @@ LIB_EXPORT void l_cipher_free(struct l_cipher *ciphe=
r)
>>   	l_free(cipher);
>>   }
>> =

>> -static bool operate_cipher(int sk, __u32 operation,
>> +static ssize_t operate_cipher(int sk, __u32 operation,
>>   				const void *in, void *out, size_t len_in,
>>   				size_t len_out)
>>   {
>> @@ -200,6 +200,7 @@ static bool operate_cipher(int sk, __u32 operation,
>>   	struct msghdr msg;
>>   	struct cmsghdr *c_msg;
>>   	struct iovec iov;
>> +	ssize_t result;
>>
>>   	memset(&c_msg_buf, 0, sizeof(c_msg_buf));
>>   	memset(&msg, 0, sizeof(msg));
>> @@ -219,13 +220,11 @@ static bool operate_cipher(int sk, __u32 operation,
>>   	msg.msg_iov =3D &iov;
>>   	msg.msg_iovlen =3D 1;
>> =

>> -	if (sendmsg(sk, &msg, 0) < 0)
>> -		return false;
>> -
>> -	if (read(sk, out, len_out) < 0)
>> -		return false;
>> +	result =3D sendmsg(sk, &msg, 0);
>> +	if (result < 0)
>> +		return result;
>> =

>> -	return true;
>> +	return read(sk, out, len_out);
>>   }
>>
>>   LIB_EXPORT bool l_cipher_encrypt(struct l_cipher *cipher,
>> @@ -238,7 +237,7 @@ LIB_EXPORT bool l_cipher_encrypt(struct l_cipher =

>> *cipher,
>>   		return false;
>>
>>   	return operate_cipher(cipher->encrypt_sk, ALG_OP_ENCRYPT, in, out, =

>> len,
>> -				len);
>> +				len) >=3D 0;
>>   }
>>
>>   LIB_EXPORT bool l_cipher_decrypt(struct l_cipher *cipher,
>> @@ -251,7 +250,7 @@ LIB_EXPORT bool l_cipher_decrypt(struct l_cipher =

>> *cipher,
>>   		return false;
>>
>>   	return operate_cipher(cipher->decrypt_sk, ALG_OP_DECRYPT, in, out, =

>> len,
>> -				len);
>> +				len) >=3D 0;
>>   }
>>
>>   LIB_EXPORT bool l_cipher_set_iv(struct l_cipher *cipher, const uint8_t =

>> *iv,
>> @@ -454,9 +453,9 @@ LIB_EXPORT int l_asymmetric_cipher_get_key_size(
>>   	return cipher->key_size;
>>   }
>> =

>> -LIB_EXPORT bool l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher =

>> *cipher,
>> -					const void *in, void *out,
>> -					size_t len_in, size_t len_out)
>> +LIB_EXPORT ssize_t l_asymmetric_cipher_encrypt(struct l_asymmetric_ciph=
er =

>> *cipher,
>> +						const void *in, void *out,
>> +						size_t len_in, size_t =

>> len_out)
>>   {
>>   	if (unlikely(!cipher))
>>   		return false;
>> @@ -468,9 +467,9 @@ LIB_EXPORT bool l_asymmetric_cipher_encrypt(struct =

>> l_asymmetric_cipher *cipher,
>>   				in, out, len_in, len_out);
>>   }
>> =

>> -LIB_EXPORT bool l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher =

>> *cipher,
>> -					const void *in, void *out,
>> -					size_t len_in, size_t len_out)
>> +LIB_EXPORT ssize_t l_asymmetric_cipher_decrypt(struct l_asymmetric_ciph=
er =

>> *cipher,
>> +						const void *in, void *out,
>> +						size_t len_in, size_t =

>> len_out)
>>   {
>>   	if (unlikely(!cipher))
>>   		return false;
>> @@ -482,9 +481,9 @@ LIB_EXPORT bool l_asymmetric_cipher_decrypt(struct =

>> l_asymmetric_cipher *cipher,
>>   				in, out, len_in, len_out);
>>   }
>> =

>> -LIB_EXPORT bool l_asymmetric_cipher_sign(struct l_asymmetric_cipher =

>> *cipher,
>> -					const void *in, void *out,
>> -					size_t len_in, size_t len_out)
>> +LIB_EXPORT ssize_t l_asymmetric_cipher_sign(struct l_asymmetric_cipher =

>> *cipher,
>> +						const void *in, void *out,
>> +						size_t len_in, size_t =

>> len_out)
>>   {
>>   	if (unlikely(!cipher))
>>   		return false;
>> @@ -496,9 +495,9 @@ LIB_EXPORT bool l_asymmetric_cipher_sign(struct =

>> l_asymmetric_cipher *cipher,
>>   				in, out, len_in, len_out);
>>   }
>> =

>> -LIB_EXPORT bool l_asymmetric_cipher_verify(struct l_asymmetric_cipher =

>> *cipher,
>> -					const void *in, void *out,
>> -					size_t len_in, size_t len_out)
>> +LIB_EXPORT ssize_t l_asymmetric_cipher_verify(struct l_asymmetric_ciphe=
r =

>> *cipher,
>> +						const void *in, void *out,
>> +						size_t len_in, size_t =

>> len_out)
>>   {
>>   	if (unlikely(!cipher))
>>   		return false;
>> diff --git a/ell/cipher.h b/ell/cipher.h
>> index b958804..45e51c7 100644
>> --- a/ell/cipher.h
>> +++ b/ell/cipher.h
>> @@ -65,21 +65,21 @@ void l_asymmetric_cipher_free(struct =

>> l_asymmetric_cipher *cipher);
>>
>>   int l_asymmetric_cipher_get_key_size(struct l_asymmetric_cipher *ciphe=
r);
>> =

>> -bool l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher *cipher,
>> +ssize_t l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher *cipher,
>>   					const void *in, void *out,
>>   					size_t len_in, size_t len_out);
>> =

>> -bool l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher *cipher,
>> +ssize_t l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher *cipher,
>>   					const void *in, void *out,
>>   					size_t len_in, size_t len_out);
>> =

>> -bool l_asymmetric_cipher_sign(struct l_asymmetric_cipher *cipher,
>> -				const void *in, void *out,
>> -				size_t len_in, size_t len_out);
>> +ssize_t l_asymmetric_cipher_sign(struct l_asymmetric_cipher *cipher,
>> +					const void *in, void *out,
>> +					size_t len_in, size_t len_out);
>> =

>> -bool l_asymmetric_cipher_verify(struct l_asymmetric_cipher *cipher,
>> -				const void *in, void *out,
>> -				size_t len_in, size_t len_out);
>> +ssize_t l_asymmetric_cipher_verify(struct l_asymmetric_cipher *cipher,
>> +					const void *in, void *out,
>> +					size_t len_in, size_t len_out);
>>
>>   #ifdef __cplusplus
>>   }
>> diff --git a/ell/tls-private.h b/ell/tls-private.h
>> index 184f2ae..9ea1554 100644
>> --- a/ell/tls-private.h
>> +++ b/ell/tls-private.h
>> @@ -65,7 +65,7 @@ struct tls_key_exchange_algorithm {
>>   	void (*handle_client_key_exchange)(struct l_tls *tls,
>>   						const uint8_t *buf, size_t =

>> len);
>> =

>> -	bool (*sign)(struct l_tls *tls, uint8_t **out,
>> +	bool (*sign)(struct l_tls *tls, uint8_t **out, size_t len,
>>   			tls_get_hash_t get_hash);
>>   	bool (*verify)(struct l_tls *tls, const uint8_t *in, size_t len,
>>   			tls_get_hash_t get_hash);
>> diff --git a/ell/tls.c b/ell/tls.c
>> index 0baddf7..e1fa912 100644
>> --- a/ell/tls.c
>> +++ b/ell/tls.c
>> @@ -274,7 +274,7 @@ static bool tls_send_rsa_client_key_xchg(struct l_tl=
s =

>> *tls);
>>   static void tls_handle_rsa_client_key_xchg(struct l_tls *tls,
>>   						const uint8_t *buf, size_t =

>> len);
>> =

>> -static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out,
>> +static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out, size_t len,
>>   				tls_get_hash_t get_hash);
>>   static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_=
t =

>> len,
>>   				tls_get_hash_t get_hash);
>> @@ -858,10 +858,10 @@ static bool tls_send_rsa_client_key_xchg(struct l_=
tls =

>> *tls)
>>   {
>>   	uint8_t buf[1024 + 32];
>>   	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
>> -	uint8_t pre_master_secret[48];
>> +	uint8_t *pre_master_secret;
>>   	struct l_asymmetric_cipher *rsa_server_pubkey;
>>   	int key_size;
>> -	bool result;
>> +	ssize_t bytes_encrypted;
>>
>>   	if (!tls->peer_pubkey) {
>>   		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
>> @@ -869,10 +869,6 @@ static bool tls_send_rsa_client_key_xchg(struct l_t=
ls =

>> *tls)
>>   		return false;
>>   	}
>> =

>> -	pre_master_secret[0] =3D (uint8_t) (TLS_VERSION >> 8);
>> -	pre_master_secret[1] =3D (uint8_t) (TLS_VERSION >> 0);
>> -	l_getrandom(pre_master_secret + 2, 46);
>> -
>>   	/* Fill in the RSA Client Key Exchange body */
>>
>>   	rsa_server_pubkey =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_V1_5,
>> @@ -895,16 +891,23 @@ static bool tls_send_rsa_client_key_xchg(struct l_=
tls =

>> *tls)
>>   		return false;
>>   	}
>> =

>> +	pre_master_secret =3D l_malloc(key_size);
>> +
>
> I'm not quite sure why you need this?
>
>> +	pre_master_secret[0] =3D (uint8_t) (TLS_VERSION >> 8);
>> +	pre_master_secret[1] =3D (uint8_t) (TLS_VERSION >> 0);
>> +	l_getrandom(pre_master_secret + 2, 46);
>> +
>>   	l_put_be16(key_size, ptr);
>> -	result =3D l_asymmetric_cipher_encrypt(rsa_server_pubkey,
>> -						pre_master_secret, ptr + 2,
>> -						48, key_size);
>> +	bytes_encrypted =3D l_asymmetric_cipher_encrypt(rsa_server_pubkey,
>> +							pre_master_secret,
>> +							ptr + 2, 48, =

>> key_size);
>
> The signature of l_asymmetric_cipher_encrypt is:
>
> ssize_t l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher *cipher,
> 					const void *in, void *out,
> 					size_t len_in, size_t len_out)
>
> We are encrypting the master secret, which should be 48 bytes long and =

> storing it into ptr + 2. ptr is inside a buffer 'buf' of 1024 + 32 bytes.
>
> I don't see how l_mallocing pre_master_secret helps anything...

I don't either, will revert that part.

>
>>   	ptr +=3D key_size + 2;
>>
>>   	l_asymmetric_cipher_free(rsa_server_pubkey);
>> =

>> -	if (!result) {
>> +	if (bytes_encrypted !=3D key_size) {
>>   		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
>> +		l_free(pre_master_secret);
>>
>>   		return false;
>>   	}
>> @@ -913,22 +916,30 @@ static bool tls_send_rsa_client_key_xchg(struct l_=
tls =

>> *tls)
>>
>>   	tls_generate_master_secret(tls, pre_master_secret, 48);
>>   	memset(pre_master_secret, 0, 48);
>> +	l_free(pre_master_secret);
>>
>>   	return true;
>>   }
>> =

>> -static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out,
>> +static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out, size_t len,
>>   				tls_get_hash_t get_hash)
>>   {
>>   	struct l_asymmetric_cipher *rsa_privkey;
>>   	uint8_t *privkey;
>>   	size_t key_size;
>>   	bool result;
>> +	ssize_t sign_output_len;
>>   	const struct tls_hash_algorithm *hash_type;
>>   	uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
>>   	uint8_t sign_input[HANDSHAKE_HASH_MAX_SIZE * 2 + 32];
>>   	size_t sign_input_len;
>> =

>> +	if (len < 2) {
>> +		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
>> +
>> +		return false;
>> +	}
>> +
>
> This len manipulation business looks to be fixing something unrelated to =
this =

> commit message.

It's fixing the lack of bounds checking on **out. I'll split that out.

>
>>   	if (!tls->priv_key_path) {
>>   		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
>>   				TLS_ALERT_BAD_CERT);
>> @@ -968,16 +979,25 @@ static bool tls_rsa_sign(struct l_tls *tls, uint8_=
t =

>> **out,
>>
>>   		*(*out)++ =3D hash_type->tls_id;
>>   		*(*out)++ =3D 1;	/* RSA_sign */
>> +		len -=3D 2;
>>   	} else {
>>   		get_hash(tls, 1, sign_input + 0, NULL, NULL);	/* MD5 */
>>   		get_hash(tls, 2, sign_input + 16, NULL, NULL);	/* SHA1 */
>>   		sign_input_len =3D 36;
>>   	}
>> =

>> -	l_put_be16(key_size, *out);
>> -	result =3D l_asymmetric_cipher_sign(rsa_privkey, sign_input, *out + 2,
>> -						sign_input_len, key_size);
>> -	*out +=3D key_size + 2;
>> +	if (len >=3D key_size + 2) {
>> +		l_put_be16(key_size, *out);
>> +		sign_output_len =3D l_asymmetric_cipher_sign(rsa_privkey,
>> +							   sign_input, *out + =

>> 2,
>> +							   sign_input_len,
>> +							   key_size);
>> +		*out +=3D sign_output_len + 2;
>> +		result =3D sign_output_len =3D=3D (ssize_t)key_size;
>> +	} else {
>> +		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
>> +		result =3D false;
>> +	}
>>
>>   	l_asymmetric_cipher_free(rsa_privkey);
>> =

>> @@ -989,7 +1009,7 @@ static bool tls_rsa_verify(struct l_tls *tls, const =

>> uint8_t *in, size_t len,
>>   {
>>   	struct l_asymmetric_cipher *rsa_client_pubkey;
>>   	size_t key_size;
>> -	bool result;
>> +	ssize_t verify_bytes;
>>   	uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
>>   	size_t hash_len;
>>   	enum l_checksum_type hash_type;
>> @@ -1077,13 +1097,14 @@ static bool tls_rsa_verify(struct l_tls *tls, co=
nst =

>> uint8_t *in, size_t len,
>>
>>   	digest_info =3D alloca(key_size);
>> =

>> -	result =3D l_asymmetric_cipher_verify(rsa_client_pubkey, in + 4,
>> -						digest_info,
>> -						key_size, key_size);
>> +	verify_bytes =3D l_asymmetric_cipher_verify(rsa_client_pubkey, in + 4,
>> +							digest_info, =

>> key_size,
>> +							key_size);
>>
>>   	l_asymmetric_cipher_free(rsa_client_pubkey);
>> =

>> -	if (!result || memcmp(digest_info, expected, expected_len)) {
>> +	if (verify_bytes !=3D (ssize_t)expected_len ||
>> +		memcmp(digest_info, expected, expected_len)) {
>>   		tls_disconnect(tls, TLS_ALERT_DECRYPT_ERROR, 0);
>>
>>   		return false;
>> @@ -1143,7 +1164,8 @@ static bool tls_send_certificate_verify(struct l_t=
ls =

>> *tls)
>>   	/* Fill in the Certificate Verify body */
>>
>>   	if (!tls->pending.cipher_suite->key_xchg->sign(tls, &ptr,
>> - =

>> tls_get_handshake_hash_by_id))
>> +					2048 - TLS_HANDSHAKE_HEADER_SIZE,
>> +					tls_get_handshake_hash_by_id))
>>   		return false;
>>
>>   	/* Stop maintaining handshake message hashes other than SHA256. */
>> @@ -1736,11 +1758,12 @@ static void tls_handle_server_hello_done(struct =

>> l_tls *tls,
>>   static void tls_handle_rsa_client_key_xchg(struct l_tls *tls,
>>   						const uint8_t *buf, size_t =

>> len)
>>   {
>> -	uint8_t pre_master_secret[48], random_secret[46];
>> +	uint8_t *pre_master_secret;
>> +	uint8_t random_secret[46];
>>   	struct l_asymmetric_cipher *rsa_server_privkey;
>>   	uint8_t *privkey;
>>   	size_t key_size;
>> -	bool result;
>> +	ssize_t bytes_decrypted;
>>
>>   	if (!tls->priv_key_path) {
>>   		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
>> @@ -1790,9 +1813,12 @@ static void tls_handle_rsa_client_key_xchg(struct =

>> l_tls *tls,
>>   		return;
>>   	}
>> =

>> -	result =3D l_asymmetric_cipher_decrypt(rsa_server_privkey, buf + 2,
>> -						pre_master_secret,
>> -						key_size, 48);
>> +	pre_master_secret =3D l_malloc(key_size);
>> +
>> +	bytes_decrypted =3D l_asymmetric_cipher_decrypt(rsa_server_privkey,
>> +							buf + 2,
>> +							pre_master_secret,
>> +							key_size, key_size);
>
> So what's the verdict, I thought we decided to accept short reads?

Short reads work with software RSA in the kernel, but we're still sorting =

out expectations for crypto hardware drivers. For now, long reads are =

still the way to ensure compatibility.

>
>>   	l_asymmetric_cipher_free(rsa_server_privkey);
>>
>>   	/*
>> @@ -1810,12 +1836,14 @@ static void tls_handle_rsa_client_key_xchg(struc=
t =

>> l_tls *tls,
>>   	pre_master_secret[0] =3D tls->client_version >> 8;
>>   	pre_master_secret[1] =3D tls->client_version >> 0;
>> =

>> -	if (!result)
>> +	if (bytes_decrypted !=3D 48)
>>   		memcpy(pre_master_secret + 2, random_secret, 46);
>>
>>   	tls_generate_master_secret(tls, pre_master_secret, 48);
>> -	memset(pre_master_secret, 0, 48);
>> +	memset(pre_master_secret, 0, key_size);
>>   	memset(random_secret, 0, 46);
>> +
>> +	l_free(pre_master_secret);
>>   }
>>
>>   static bool tls_get_prev_digest_by_id(struct l_tls *tls, uint8_t hash_=
id,
>>

--
Mat Martineau
Intel OTC

--===============2523011084591006768==--

