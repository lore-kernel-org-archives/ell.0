Content-Type: multipart/mixed; boundary="===============7827773294421015450=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 08/11] cipher: Update for current kernel akcipher interface
Date: Tue, 07 Jun 2016 17:23:58 -0500
Message-ID: <5757497E.8060409@gmail.com>
In-Reply-To: <CAOq732K5dAJJg3Z9n61tzNUJWbsqpwPFeqoec7BVgn8p93KX9A@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7827773294421015450==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,
 >
> I believe the "rsa" cipher does not include padding and
> "pkcs1pad(rsa)" does and now there's also a "pkcs1pad(rsa, <hash
> type>)" that could save as a little more work in the TLS code if we
> only supported TLS 1.2 but can't be used for < 1.2.

I wonder if keyctl can expose the hash for us as well.  Either way, we =

should take advantage of this if possible.

>
>>
>
>>> @@ -943,19 +943,9 @@ static bool tls_rsa_sign(struct l_tls *tls, uint8_t
>>> **out,
>>>                  return false;
>>>          }
>>>
>>> -       privkey_short =3D extract_rsakey(privkey, key_size, &short_size=
);
>>> -       tls_free_key(privkey, key_size);
>>> -
>>> -       if (!privkey_short) {
>>> -               tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
>>> -                               TLS_ALERT_BAD_CERT);
>>> -
>>> -               return false;
>>> -       }
>>> -
>>>          rsa_privkey =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_V1_=
5,
>>> -                                               privkey_short,
>>> short_size);
>>> -       tls_free_key(privkey_short, short_size);
>>> +                                               privkey, key_size);
>>> +       tls_free_key(privkey, key_size);
>>>
>>>          if (!rsa_privkey) {
>>>                  tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
>>
>>
>> Should we be reporting BAD_CERT here?
>
> I'm not sure if you mean BAD_CERT as the second or third parameter but

Third parameter.  Mat took out the code that returned BAD_CERT if =

extract_rsakey failed.  So now if the asymmetric cipher creation fails, =

we have to assume that the certificate is bad (or a configuration issue).

> I don't think we should do either.  Passing BAD_CERT to the remote end
> implies it that it has supplied a bad certificate and the disconnect
> is their fault.  Passing BAD_CERT to our higher layer will imply that
> our certificate is wrong.  In reality the problem here is most likely
> kernel configuration.

Or that the remote has given us a bad certificate :)

Regards,
-Denis

--===============7827773294421015450==--

