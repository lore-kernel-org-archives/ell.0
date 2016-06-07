Content-Type: multipart/mixed; boundary="===============1284089292831933720=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 08/11] cipher: Update for current kernel akcipher interface
Date: Tue, 07 Jun 2016 14:32:57 -0500
Message-ID: <57572169.7040605@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1606071056530.9891@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1284089292831933720==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

 >>
>> I'm a bit unsure that we really want to know this information.  What
>> is it's use actually?  We should always implicitly know what type of
>> certificate we are giving to l_asymmetric_cipher_new, so it might just
>> need to be a parameter.
>
> Two pieces of information are extracted: the key size (used by tls) and
> whether it's public or private. The public/private bit is a freebie when
> retrieving the key size. It used to be that the key size could be
> extracted the same way for both public and private keys.
>
> After digging some more, there is a brand new way to query key
> information (including the length) from asymmetric keys stored in the
> kernel. If we switch to using that we wouldn't have to parse certs in

I'd like to see akcipher (and maybe even skcipher) support obtaining of =

the key size via a getsockopt.  Just seems like a good idea.

> userspace at all, which sounds like a win to me. Still wouldn't need to
> make the user designate public vs. private in l_asymmetric_new, since
> the kernel would know already.

Don't we need to know whether the sign/verify operations are available, =

or just the verify?

>> I'm all for getting rid of the padding stuff, but as mentioned
>> previously, I'm not sure the pkcs1pad template is part of the rsa
>> akcipher by default. Is it?
>
> I thought it was, but now I'm not sure. The kernel seemed to object if
> the data was padded out to the full length. I'm digging more to confirm
> what's actually happening, but I probably have to pass in pkcs1pad(rsa)
> as the alg name.
>

That is what I thought.  I think Andrew mentioned that this wasn't yet =

exposed to user space.

>>> @@ -1078,11 +1068,14 @@ static bool tls_rsa_verify(struct l_tls *tls,
>>> const uint8_t *in, size_t len,
>>>            */
>>>       }
>>>
>>> -    digest_info =3D alloca(expected_len);
>>> +    if (expected_len > key_size)
>>> +        goto err_free_rsa;
>>> +
>>> +    digest_info =3D alloca(key_size);
>>
>> This looks like a separate fix and belongs in a separate patch.
>>
>
> What happened here is that the kernel no longer lets you read only the
> amount of data you're expecting - you need to read the maximum size you
> might get. And if I'm telling the kernel to read a potentially larger
> number of bytes, there needs to be a big enough buffer for it.
>

This still feels wrong to me.  Are you sure its not related to the =

PKCS1.5 padding ?

Regards,
-Denis

--===============1284089292831933720==--

