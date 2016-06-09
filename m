Content-Type: multipart/mixed; boundary="===============4317374341030947977=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 08/11] cipher: Update for current kernel akcipher interface
Date: Thu, 09 Jun 2016 23:20:03 +0200
Message-ID: <CAOq732KU7itrbwfmKfeknhWTJBq=Gyrf8EFsOXwqOOKkBp_OeQ@mail.gmail.com>
In-Reply-To: <alpine.OSX.2.20.1606091301550.21471@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4317374341030947977==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 9 June 2016 at 22:20, Mat Martineau
<mathew.j.martineau@linux.intel.com> wrote:
> On Tue, 7 Jun 2016, Mat Martineau wrote:
>> On Tue, 7 Jun 2016, Denis Kenzior wrote:
>>>>>>
>>>>>> @@ -1078,11 +1068,14 @@ static bool tls_rsa_verify(struct l_tls *tls,
>>>>>> const uint8_t *in, size_t len,
>>>>>>            */
>>>>>>       }
>>>>>>
>>>>>> -    digest_info =3D alloca(expected_len);
>>>>>> +    if (expected_len > key_size)
>>>>>> +        goto err_free_rsa;
>>>>>> +
>>>>>> +    digest_info =3D alloca(key_size);
>>>>>
>>>>>
>>>>> This looks like a separate fix and belongs in a separate patch.
>>>>>
>>>>
>>>> What happened here is that the kernel no longer lets you read only the
>>>> amount of data you're expecting - you need to read the maximum size you
>>>> might get. And if I'm telling the kernel to read a potentially larger
>>>> number of bytes, there needs to be a big enough buffer for it.
>>>>
>>>
>>> This still feels wrong to me.  Are you sure its not related to the
>>> PKCS1.5 padding ?
>>
>>
>> Yes. akcipher_recvmsg() does this check before invoking any crypto ops:
>>
>>        /* ensure output buffer is sufficiently large */
>>        if (usedpages < akcipher_calcsize(ctx)) {
>>                err =3D -EMSGSIZE;
>>                goto unlock;
>>        }
>>
>> (where akcipher_calcsize() returns the key size in bytes when using RSA)
>>
>> I'm not sure why, since the length of the destination buffer gets
>> propagated to the crypto algorithm and it could decide what to do. I'll =
ask
>> Stephan.
>
>
> I convinced the author to drop this extra length check. This means we can=
 do
> short reads when using RSA software crypto. However, I see that hardware
> drivers can require the full length output buffer anyway (probably because
> of how the hardware handles DMA access) - so we sacrifice compatibility if
> we use a smaller read buffer.

I understand we need to be using the padding transform anyway so this
doesn't affect us. The buffer received by AF_ALG is not the one used
by the rsa transform.  The pkcs1pad code allocates a key-sized buffer
to which rsa will write the result and there will be various checks
and a memcpy from that buffer to the one provided by AF_ALG /
userspace.

That said if the driver doesn't conform to the API, even though it was
created at about the same time as the API then it needs to be fixed.

Also I can't understand why Tadeusz decided to skpi leading zeros from
the RSA input and output numbers, no other API does that and it
doesn't help anybody on the kernel or the userspace sides, I think the
mpi library was modified to do that just for RSA.

Best regards

--===============4317374341030947977==--

