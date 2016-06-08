Content-Type: multipart/mixed; boundary="===============0108217792226462540=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 08/11] cipher: Update for current kernel akcipher interface
Date: Tue, 07 Jun 2016 17:18:59 -0700
Message-ID: <alpine.OSX.2.20.1606071552160.9891@mjmartin-mac01.local>
In-Reply-To: <57572169.7040605@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0108217792226462540==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Tue, 7 Jun 2016, Denis Kenzior wrote:

> Hi Mat,
>
>>>
>>> I'm a bit unsure that we really want to know this information.  What
>>> is it's use actually?  We should always implicitly know what type of
>>> certificate we are giving to l_asymmetric_cipher_new, so it might just
>>> need to be a parameter.
>> =

>> Two pieces of information are extracted: the key size (used by tls) and
>> whether it's public or private. The public/private bit is a freebie when
>> retrieving the key size. It used to be that the key size could be
>> extracted the same way for both public and private keys.
>> =

>> After digging some more, there is a brand new way to query key
>> information (including the length) from asymmetric keys stored in the
>> kernel. If we switch to using that we wouldn't have to parse certs in
>
> I'd like to see akcipher (and maybe even skcipher) support obtaining of t=
he =

> key size via a getsockopt.  Just seems like a good idea.

It helps that there's an internal API for this: crypto_akcipher_maxsize(). =

AF_ALG doesn't currently have any getsockopt handler, unfortunately. I'll =

see if the AF_ALG akcipher contributors will help push for it too.

>
>> userspace at all, which sounds like a win to me. Still wouldn't need to
>> make the user designate public vs. private in l_asymmetric_new, since
>> the kernel would know already.
>
> Don't we need to know whether the sign/verify operations are available, o=
r =

> just the verify?

Sure, but that doesn't mean the caller of l_asymmetric_new needs to tell =

us whether it's a private key or not. We send the key to the kernel and =

ask the kernel which of encrypt/decrypt/sign/verify are available when =

using that key.

>
>>> I'm all for getting rid of the padding stuff, but as mentioned
>>> previously, I'm not sure the pkcs1pad template is part of the rsa
>>> akcipher by default. Is it?
>> =

>> I thought it was, but now I'm not sure. The kernel seemed to object if
>> the data was padded out to the full length. I'm digging more to confirm
>> what's actually happening, but I probably have to pass in pkcs1pad(rsa)
>> as the alg name.
>> =

>
> That is what I thought.  I think Andrew mentioned that this wasn't yet =

> exposed to user space.
>
>>>> @@ -1078,11 +1068,14 @@ static bool tls_rsa_verify(struct l_tls *tls,
>>>> const uint8_t *in, size_t len,
>>>>            */
>>>>       }
>>>> =

>>>> -    digest_info =3D alloca(expected_len);
>>>> +    if (expected_len > key_size)
>>>> +        goto err_free_rsa;
>>>> +
>>>> +    digest_info =3D alloca(key_size);
>>> =

>>> This looks like a separate fix and belongs in a separate patch.
>>> =

>> =

>> What happened here is that the kernel no longer lets you read only the
>> amount of data you're expecting - you need to read the maximum size you
>> might get. And if I'm telling the kernel to read a potentially larger
>> number of bytes, there needs to be a big enough buffer for it.
>> =

>
> This still feels wrong to me.  Are you sure its not related to the PKCS1.=
5 =

> padding ?

Yes. akcipher_recvmsg() does this check before invoking any crypto ops:

         /* ensure output buffer is sufficiently large */
         if (usedpages < akcipher_calcsize(ctx)) {
                 err =3D -EMSGSIZE;
                 goto unlock;
         }

(where akcipher_calcsize() returns the key size in bytes when using RSA)

I'm not sure why, since the length of the destination buffer gets =

propagated to the crypto algorithm and it could decide what to do. I'll =

ask Stephan.

--
Mat Martineau
Intel OTC

--===============0108217792226462540==--

