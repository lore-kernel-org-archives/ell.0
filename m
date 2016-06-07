Content-Type: multipart/mixed; boundary="===============7326844147873978322=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 08/11] cipher: Update for current kernel akcipher interface
Date: Tue, 07 Jun 2016 23:47:08 +0200
Message-ID: <CAOq732K5dAJJg3Z9n61tzNUJWbsqpwPFeqoec7BVgn8p93KX9A@mail.gmail.com>
In-Reply-To: <575709BC.5000003@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7326844147873978322==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis and Mat,

On 7 June 2016 at 19:51, Denis Kenzior <denkenz@gmail.com> wrote:
> On 06/06/2016 03:54 PM, Mat Martineau wrote:
>> @@ -508,151 +451,52 @@ LIB_EXPORT int l_asymmetric_cipher_get_key_size(
>>         return cipher->key_size;
>>   }
>>
>> -static void getrandom_nonzero(uint8_t *buf, int len)
>> -{
>> -       while (len--) {
>> -               l_getrandom(buf, 1);
>> -               while (buf[0] =3D=3D 0)
>> -                       l_getrandom(buf, 1);
>> -
>> -               buf++;
>> -       }
>> -}
>> -
>> -LIB_EXPORT bool l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher
>> *cipher,
>> +LIB_EXPORT bool l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher
>> *acipher,
>>                                         const void *in, void *out,
>>                                         size_t len_in, size_t len_out)
>>   {
>> -       if (cipher->cipher.type =3D=3D L_CIPHER_RSA_PKCS1_V1_5) {
>> -               /* PKCS#1 v1.5 RSA padding according to RFC3447 */
>> -               uint8_t buf[cipher->key_size];
>> -               int ps_len =3D cipher->key_size - len_in - 3;
>> -
>> -               if (len_in > (size_t) cipher->key_size - 11)
>> -                       return false;
>> -               if (len_out !=3D (size_t) cipher->key_size)
>> -                       return false;
>> -
>> -               buf[0] =3D 0x00;
>> -               buf[1] =3D 0x02;
>> -               getrandom_nonzero(buf + 2, ps_len);
>> -               buf[ps_len + 2] =3D 0x00;
>> -               memcpy(buf + ps_len + 3, in, len_in);
>> -
>> -               if (!l_cipher_encrypt(&cipher->cipher, buf, out,
>> -                                       cipher->key_size))
>> -                       return false;
>> -       }
>> +       if (unlikely(!acipher))
>> +               return false;
>>
>> -       return true;
>> +       if (unlikely(!in) || unlikely(!out))
>> +               return false;
>> +
>> +       return operate_cipher(acipher->cipher.encrypt_sk, ALG_OP_ENCRYPT,
>> +                               in, out, len_in, len_out);
>>   }
>>
>> -LIB_EXPORT bool l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher
>> *cipher,
>> +LIB_EXPORT bool l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher
>> *acipher,
>>                                         const void *in, void *out,
>>                                         size_t len_in, size_t len_out)
>>   {
>> -       if (cipher->cipher.type =3D=3D L_CIPHER_RSA_PKCS1_V1_5) {
>> -               /* PKCS#1 v1.5 RSA padding according to RFC3447 */
>> -               uint8_t buf[cipher->key_size];
>> -               int pos;
>> -
>> -               if (len_in !=3D (size_t) cipher->key_size)
>> -                       return false;
>> -
>> -               if (!l_cipher_decrypt(&cipher->cipher, in, buf,
>> -                                       cipher->key_size))
>> -                       return false;
>> -
>> -               if (buf[0] !=3D 0x00)
>> -                       return false;
>> -               if (buf[1] !=3D 0x02)
>> -                       return false;
>> -
>> -               for (pos =3D 2; pos < cipher->key_size; pos++)
>> -                       if (buf[pos] =3D=3D 0)
>> -                               break;
>> -               if (pos < 10 || pos =3D=3D cipher->key_size)
>> -                       return false;
>> -
>> -               pos++;
>> -               if (len_out !=3D (size_t) cipher->key_size - pos)
>> -                       return false;
>> -
>> -               memcpy(out, buf + pos, cipher->key_size - pos);
>> -       }
>
>
> I'm all for getting rid of the padding stuff, but as mentioned previously,
> I'm not sure the pkcs1pad template is part of the rsa akcipher by default.
> Is it?

I believe the "rsa" cipher does not include padding and
"pkcs1pad(rsa)" does and now there's also a "pkcs1pad(rsa, <hash
type>)" that could save as a little more work in the TLS code if we
only supported TLS 1.2 but can't be used for < 1.2.

>

>> @@ -943,19 +943,9 @@ static bool tls_rsa_sign(struct l_tls *tls, uint8_t
>> **out,
>>                 return false;
>>         }
>>
>> -       privkey_short =3D extract_rsakey(privkey, key_size, &short_size);
>> -       tls_free_key(privkey, key_size);
>> -
>> -       if (!privkey_short) {
>> -               tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
>> -                               TLS_ALERT_BAD_CERT);
>> -
>> -               return false;
>> -       }
>> -
>>         rsa_privkey =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_V1_5,
>> -                                               privkey_short,
>> short_size);
>> -       tls_free_key(privkey_short, short_size);
>> +                                               privkey, key_size);
>> +       tls_free_key(privkey, key_size);
>>
>>         if (!rsa_privkey) {
>>                 tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
>
>
> Should we be reporting BAD_CERT here?

I'm not sure if you mean BAD_CERT as the second or third parameter but
I don't think we should do either.  Passing BAD_CERT to the remote end
implies it that it has supplied a bad certificate and the disconnect
is their fault.  Passing BAD_CERT to our higher layer will imply that
our certificate is wrong.  In reality the problem here is most likely
kernel configuration.

>
>> @@ -1078,11 +1068,14 @@ static bool tls_rsa_verify(struct l_tls *tls,
>> const uint8_t *in, size_t len,
>>                  */
>>         }
>>
>> -       digest_info =3D alloca(expected_len);
>> +       if (expected_len > key_size)
>> +               goto err_free_rsa;
>> +
>> +       digest_info =3D alloca(key_size);
>
>
> This looks like a separate fix and belongs in a separate patch.
>
>>
>>         result =3D l_asymmetric_cipher_verify(rsa_client_pubkey, in + 4,
>>                                                 digest_info,
>> -                                               key_size, expected_len);
>> +                                               key_size, key_size);
>
>
> Same here?

expected_len and key_size are almost certainly not equal.  Why are we
expecing a digest_info of the same size as the key?  if the kernel now
always returns data padded to key_size perhaps our cipher layer should
remove that padding.  Also if the kernel is not checking the output
length anymore then perhaps we need to check it's correct.

>
>
>>
>>         l_asymmetric_cipher_free(rsa_client_pubkey);
>>
>> @@ -1741,8 +1734,8 @@ static void tls_handle_rsa_client_key_xchg(struct
>> l_tls *tls,
>>   {
>>         uint8_t pre_master_secret[48], random_secret[46];
>>         struct l_asymmetric_cipher *rsa_server_privkey;
>> -       uint8_t *privkey, *privkey_short;
>> -       size_t key_size, short_size;
>> +       uint8_t *privkey;
>> +       size_t key_size;
>>         bool result;
>>
>>         if (!tls->priv_key_path) {
>> @@ -1762,19 +1755,9 @@ static void tls_handle_rsa_client_key_xchg(struct
>> l_tls *tls,
>>                 return;
>>         }
>>
>> -       privkey_short =3D extract_rsakey(privkey, key_size, &short_size);
>> -       tls_free_key(privkey, key_size);
>> -
>> -       if (!privkey_short) {
>> -               tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
>> -                               TLS_ALERT_BAD_CERT);
>> -
>> -               return;
>> -       }
>> -
>>         rsa_server_privkey =3D
>> l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_V1_5,
>> -                                               privkey_short,
>> short_size);
>> -       tls_free_key(privkey_short, short_size);
>> +                                                       privkey,
>> key_size);
>> +       tls_free_key(privkey, key_size);
>>
>>         if (!rsa_server_privkey) {
>>                 tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
>>
>
> Regards,
> -Denis
>
> _______________________________________________
> ell mailing list
> ell(a)lists.01.org
> https://lists.01.org/mailman/listinfo/ell

--===============7326844147873978322==--

