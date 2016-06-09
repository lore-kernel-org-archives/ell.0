Content-Type: multipart/mixed; boundary="===============9045091860366824064=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 08/11] cipher: Update for current kernel akcipher interface
Date: Thu, 09 Jun 2016 13:20:18 -0700
Message-ID: <alpine.OSX.2.20.1606091301550.21471@mjmartin-mac01.local>
In-Reply-To: <alpine.OSX.2.20.1606071552160.9891@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9045091860366824064==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Tue, 7 Jun 2016, Mat Martineau wrote:

> On Tue, 7 Jun 2016, Denis Kenzior wrote:
>>>>> @@ -1078,11 +1068,14 @@ static bool tls_rsa_verify(struct l_tls *tls,
>>>>> const uint8_t *in, size_t len,
>>>>>            */
>>>>>       }
>>>>> =

>>>>> -    digest_info =3D alloca(expected_len);
>>>>> +    if (expected_len > key_size)
>>>>> +        goto err_free_rsa;
>>>>> +
>>>>> +    digest_info =3D alloca(key_size);
>>>> =

>>>> This looks like a separate fix and belongs in a separate patch.
>>>> =

>>> =

>>> What happened here is that the kernel no longer lets you read only the
>>> amount of data you're expecting - you need to read the maximum size you
>>> might get. And if I'm telling the kernel to read a potentially larger
>>> number of bytes, there needs to be a big enough buffer for it.
>>> =

>> =

>> This still feels wrong to me.  Are you sure its not related to the PKCS1=
.5 =

>> padding ?
>
> Yes. akcipher_recvmsg() does this check before invoking any crypto ops:
>
>        /* ensure output buffer is sufficiently large */
>        if (usedpages < akcipher_calcsize(ctx)) {
>                err =3D -EMSGSIZE;
>                goto unlock;
>        }
>
> (where akcipher_calcsize() returns the key size in bytes when using RSA)
>
> I'm not sure why, since the length of the destination buffer gets propaga=
ted =

> to the crypto algorithm and it could decide what to do. I'll ask Stephan.

I convinced the author to drop this extra length check. This means we can =

do short reads when using RSA software crypto. However, I see that =

hardware drivers can require the full length output buffer anyway =

(probably because of how the hardware handles DMA access) - so we =

sacrifice compatibility if we use a smaller read buffer.

--
Mat Martineau
Intel OTC

--===============9045091860366824064==--

