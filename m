Content-Type: multipart/mixed; boundary="===============9161192998696369164=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 07/10] cipher: Add l_cipher_from_pkcs5_id
Date: Sat, 12 Aug 2017 02:17:02 +0200
Message-ID: <CAOq732+HP0MSRPUAibeEbdKJBuGFBXdb5OPgku6NjZxJQ5zTLA@mail.gmail.com>
In-Reply-To: <83284742-6c95-af79-80cc-12e3bec8a77f@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9161192998696369164==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 11 August 2017 at 18:55, Denis Kenzior <denkenz@gmail.com> wrote:
> On 08/10/2017 06:10 PM, Andrew Zaborowski wrote:
>> Add a utility to parse all of the PKCS#5 DER-encoded encryption scheme
>> information, use the right PBKDF function to calculate the key,
>> create the appropriate l_cipher object type (if we support that PKCS#5
>> cipher type) with that key and set the IV on the l_cipher object.
>>
>> We don't support any of the RC2 or RC5 based encryption schemes or
>> those that use MD2, SHA512-224 or SHA512-256 for the hash, because
>> there's no kernel support for those algorithms.  OpenSSL can create
>> RSA private keys encrypted with some of these algorithms but MD5+DES
>> and DES3-EDE are the default and the popular algorithms.  OpenSSL also
>> supports camellia ciphers in those scenarios which we could add.
>>
>> Note that the caller still needs to add or remove the padding from the
>> data encrypted or decrypted with the l_cipher object so technically this
>> doesn't implement 100% of PKCS#5 PBES1 or PBES2.
>> Thise code may be better moved to a separate file from cipher.c.  If we
>> do that then it could be wrapped in a separate object that would do the
>> padding after calling the l_cipher operation, too, though the padding
>> is really simple anway, may not be worth the overhead of another wrapper.
>
>
> Another reason to move this is that I don't really want to expose it in
> l_cipher.  The right way for us to enable encrypted certificates is via t=
he
> keyctl API.  Until then, we should stuff this into some private file.  Can
> we put this into asn1-private.[ch]?

If we're going to have pkcs5.c, perhaps let's put it there since all
of this is basically PKCS#5?  We would then also need pkcs5-private.h,
is that too many files?

>
>> ---
>>   ell/cipher.c | 290
>> +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>   ell/cipher.h |   4 +
>>   2 files changed, 294 insertions(+)
>>
>
> <snip>
>
>
>> +static struct l_cipher *cipher_from_pkcs5_pbes2_params(
>> +                                               const uint8_t
>> *pbes2_params,
>> +                                               size_t pbes2_params_len,
>> +                                               const char *password)
>> +{
>> +       uint8_t tag;
>> +       const uint8_t *kdf_sequence, *enc_sequence, *oid, *params,
>> +               *salt, *iter_count_buf, *key_len_buf, *prf_sequence;
>> +       size_t kdf_len, enc_len, params_len, salt_len, key_len, tmp_len;
>> +       unsigned int i, iter_count;
>> +       enum l_checksum_type prf_alg =3D L_CHECKSUM_NONE;
>> +       const struct pkcs5_enc_alg_oid *enc_scheme =3D NULL;
>> +       uint8_t derived_key[64];
>> +       struct l_cipher *cipher;
>> +
>> +       /* RFC8018 section A.4 */
>> +
>> +       kdf_sequence =3D der_find_elem(pbes2_params, pbes2_params_len, 0,
>> +                                       &tag, &kdf_len);
>> +       if (!kdf_sequence || tag !=3D ASN1_ID_SEQUENCE)
>> +               return NULL;
>> +
>> +       enc_sequence =3D der_find_elem(pbes2_params, pbes2_params_len, 1,
>> +                                       &tag, &enc_len);
>> +       if (!enc_sequence || tag !=3D ASN1_ID_SEQUENCE)
>> +               return NULL;
>> +
>> +       if (der_find_elem(pbes2_params, pbes2_params_len, 2, &tag,
>> &tmp_len))
>> +               return NULL;
>> +
>> +       /* RFC8018 section A.2 */
>> +
>> +       oid =3D der_find_elem(kdf_sequence, kdf_len, 0, &tag, &tmp_len);
>> +       if (!oid || tag !=3D ASN1_ID_OID)
>> +               return NULL;
>> +
>> +       if (!asn1_oid_eq(&pkcs5_pbkdf2_oid, tmp_len, oid))
>> +               return NULL;
>> +
>> +       params =3D der_find_elem(kdf_sequence, kdf_len, 1, &tag,
>> &params_len);
>> +       if (!params || tag !=3D ASN1_ID_SEQUENCE)
>> +               return NULL;
>> +
>> +       if (der_find_elem(kdf_sequence, kdf_len, 2, &tag, &tmp_len))
>> +               return NULL;
>> +
>> +       salt =3D der_find_elem(params, params_len, 0, &tag, &salt_len);
>> +       if (!salt || tag !=3D ASN1_ID_OCTET_STRING ||
>> +                       salt_len < 1 || salt_len > 512)
>> +               return NULL;
>> +
>> +       iter_count_buf =3D der_find_elem(params, params_len, 1, &tag,
>> &tmp_len);
>> +       if (!iter_count_buf || tag !=3D ASN1_ID_INTEGER ||
>> +                       tmp_len < 1 || tmp_len > 4)
>> +               return NULL;
>> +
>> +       iter_count =3D 0;
>> +       while (tmp_len--)
>> +               iter_count =3D (iter_count << 8) | *iter_count_buf++;
>> +
>> +       key_len_buf =3D der_find_elem(params, params_len, 2, &tag,
>> &tmp_len);
>> +       if (key_len_buf) {
>> +               if (tag !=3D ASN1_ID_INTEGER || tmp_len !=3D 1)
>> +                       return NULL;
>> +
>> +               key_len =3D 0;
>> +               while (tmp_len--)
>> +                       key_len =3D (key_len << 8) | *key_len_buf++;
>> +       } else
>> +               key_len =3D 0;
>> +
>> +       prf_sequence =3D der_find_elem(params, params_len, 3, &tag,
>> &tmp_len);
>> +       if (prf_sequence) {
>> +               if (tag !=3D ASN1_ID_SEQUENCE)
>> +                       return NULL;
>> +
>> +               oid =3D der_find_elem(prf_sequence, tmp_len, 0, &tag,
>> &tmp_len);
>> +               if (!oid || tag !=3D ASN1_ID_OID)
>> +                       return NULL;
>> +
>> +               for (i =3D 0; i < L_ARRAY_SIZE(pkcs5_digest_alg_oids); i=
++)
>> +                       if (!asn1_oid_eq(&pkcs5_digest_alg_oids[i].oid,
>> +                                               tmp_len, oid))
>> +                               prf_alg =3D pkcs5_digest_alg_oids[i].typ=
e;
>> +               if (prf_alg =3D=3D L_CHECKSUM_NONE)
>> +                       return NULL;
>> +       } else
>> +               prf_alg =3D L_CHECKSUM_SHA1;
>> +
>> +       oid =3D der_find_elem(enc_sequence, enc_len, 0, &tag, &tmp_len);
>> +       if (!oid || tag !=3D ASN1_ID_OID)
>> +               return NULL;
>> +
>> +       for (i =3D 0; i < L_ARRAY_SIZE(pkcs5_enc_alg_oids); i++)
>> +               if (asn1_oid_eq(&pkcs5_enc_alg_oids[i].oid, tmp_len, oid=
))
>> {
>> +                       enc_scheme =3D &pkcs5_enc_alg_oids[i];
>> +                       break;
>> +               }
>
>
> Our preference is to put {} around the enclosing for in this case.
>
> item M1 here as well

Ok.

Best regards

--===============9161192998696369164==--

