Content-Type: multipart/mixed; boundary="===============8425433735189817086=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH v4 3/6] cipher: Return result length from asymmetric cipher
Date: Fri, 17 Jun 2016 09:15:56 -0700
Message-ID: <alpine.OSX.2.20.1606170837260.29616@mjmartin-mac01.local>
In-Reply-To: <57635483.20606@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8425433735189817086==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 16 Jun 2016, Denis Kenzior wrote:

> Hi Andrew,
>
> On 06/16/2016 08:30 PM, Andrzej Zaborowski wrote:
>> Hi,
>> =

>> On 17 June 2016 at 02:17, Mat Martineau
>> <mathew.j.martineau@linux.intel.com> wrote:
>>> On Thu, 16 Jun 2016, Denis Kenzior wrote:
>>>> On 06/15/2016 12:18 PM, Mat Martineau wrote:
>>>>> @@ -1790,9 +1813,12 @@ static void tls_handle_rsa_client_key_xchg(str=
uct
>>>>> l_tls *tls,
>>>>>                  return;
>>>>>          }
>>>>> =

>>>>> -       result =3D l_asymmetric_cipher_decrypt(rsa_server_privkey, bu=
f + =

>>>>> 2,
>>>>> -                                               pre_master_secret,
>>>>> -                                               key_size, 48);
>>>>> +       pre_master_secret =3D l_malloc(key_size);
>>>>> +
>>>>> +       bytes_decrypted =3D =

>>>>> l_asymmetric_cipher_decrypt(rsa_server_privkey,
>>>>> +                                                       buf + 2,
>>>>> +
>>>>> pre_master_secret,
>>>>> +                                                       key_size,
>>>>> key_size);
>>>> =

>>>> =

>>>> So what's the verdict, I thought we decided to accept short reads?
>>> =

>>> =

>>> Short reads work with software RSA in the kernel, but we're still =

>>> sorting out expectations for crypto hardware drivers. For now, long =

>>> reads are still the way to ensure compatibility.
>> =

>> I guess it depends on what kernel you're aiming for but your test tree
>> has only the software pkcs1pad driver.  Upstream can in theory add a
>> new driver at any time but AF_ALG is still under review there.
>> =

>> By the way I wouldn't call these short reads as we're reading all the
>> data that the socket has to read ;)  In the commit message I think Mat
>> may be referring to the other short reads.
>
> I think this is what Mat means.  That the AF_ALG socket is expecting the =

> buffer to recvmsg to be key_size bytes.  E.g. a 'short-read'.

Right, Denis. The full-length key_size buffer was "long", anything shorter =

was "short". That's not the best wording, so I'll clarify the commit =

message.

Andrew is right. Looking back over the pkcs1pad kernel code, the =

(unmerged) fix for AF_ALG that removes the top-level check requiring =

maximum buffer length should allow us to read the expected data length =

when using pkcs1pad, no matter the underlying RSA implementation. I'll go =

back to using the expected length read buffers in ELL and confirm that =

it's working.

I still think it's worthwhile to make the l_asymmetric_crypto ops return =

the actual read length, since the crypto user might not know how much data =

to expect.

>> =

>> I don't think these kernel api changes should spill into tls.c though.
>> =

>
> Anyway, the bottom line is for pkcs1pad we should be able to pass a buffe=
r < =

> key_size for recvmsg.  Nothing else makes sense.  For sendmsg, the output =

> buffer should always be key_size.

Agreed (for decrypt/verify).

> For rsa primitive operation, the recvmsg buffer 'should' be key_size byte=
s.

Yes.

--
Mat Martineau
Intel OTC

--===============8425433735189817086==--

