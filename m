Content-Type: multipart/mixed; boundary="===============4934631281293764495=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 08/11] cipher: Update for current kernel akcipher interface
Date: Wed, 08 Jun 2016 00:43:23 +0200
Message-ID: <CAOq732+QO4GvCDz67ZAPgnuSmYHM67iKTOpt8j6J_Pecugry6g@mail.gmail.com>
In-Reply-To: <5757497E.8060409@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4934631281293764495==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 8 June 2016 at 00:23, Denis Kenzior <denkenz@gmail.com> wrote:
> Hi Andrew,
>>
>>
>> I believe the "rsa" cipher does not include padding and
>> "pkcs1pad(rsa)" does and now there's also a "pkcs1pad(rsa, <hash
>> type>)" that could save as a little more work in the TLS code if we
>> only supported TLS 1.2 but can't be used for < 1.2.
>
>
> I wonder if keyctl can expose the hash for us as well.  Either way, we
> should take advantage of this if possible.

Since it would only work for TLS 1.2 I think it's easier to not use it
so we can share more code between 1.2 and pre 1.2.

>
>>
>>>
>>
>>>> @@ -943,19 +943,9 @@ static bool tls_rsa_sign(struct l_tls *tls, uint8=
_t
>>>> **out,
>>>>                  return false;
>>>>          }
>>>>
>>>> -       privkey_short =3D extract_rsakey(privkey, key_size, &short_siz=
e);
>>>> -       tls_free_key(privkey, key_size);
>>>> -
>>>> -       if (!privkey_short) {
>>>> -               tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
>>>> -                               TLS_ALERT_BAD_CERT);
>>>> -
>>>> -               return false;
>>>> -       }
>>>> -
>>>>          rsa_privkey =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_V1=
_5,
>>>> -                                               privkey_short,
>>>> short_size);
>>>> -       tls_free_key(privkey_short, short_size);
>>>> +                                               privkey, key_size);
>>>> +       tls_free_key(privkey, key_size);
>>>>
>>>>          if (!rsa_privkey) {
>>>>                  tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
>>>
>>>
>>>
>>> Should we be reporting BAD_CERT here?
>>
>>
>> I'm not sure if you mean BAD_CERT as the second or third parameter but
>
>
> Third parameter.  Mat took out the code that returned BAD_CERT if
> extract_rsakey failed.  So now if the asymmetric cipher creation fails, we
> have to assume that the certificate is bad (or a configuration issue).

Oh, right.  So l_asymmetric_cipher_new will fail if either the kernel
doesn't support the API we want or the if the key format is bad.

>
>> I don't think we should do either.  Passing BAD_CERT to the remote end
>> implies it that it has supplied a bad certificate and the disconnect
>> is their fault.  Passing BAD_CERT to our higher layer will imply that
>> our certificate is wrong.  In reality the problem here is most likely
>> kernel configuration.
>
>
> Or that the remote has given us a bad certificate :)

The disconnect callback receives a flag that will tell it it's a local erro=
r.

Best regards

--===============4934631281293764495==--

