Content-Type: multipart/mixed; boundary="===============3265570502811129211=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH v4 3/6] cipher: Return result length from asymmetric cipher
Date: Fri, 17 Jun 2016 03:30:40 +0200
Message-ID: <CAOq732JQCsT0kADU3b7tPW5TAoMiXteKrtVvKbMCm81y3QXB+A@mail.gmail.com>
In-Reply-To: <alpine.OSX.2.20.1606161650380.26845@rabdelkh-mobl.amr.corp.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3265570502811129211==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

On 17 June 2016 at 02:17, Mat Martineau
<mathew.j.martineau@linux.intel.com> wrote:
> On Thu, 16 Jun 2016, Denis Kenzior wrote:
>> On 06/15/2016 12:18 PM, Mat Martineau wrote:
>>> @@ -1790,9 +1813,12 @@ static void tls_handle_rsa_client_key_xchg(struct
>>> l_tls *tls,
>>>                 return;
>>>         }
>>>
>>> -       result =3D l_asymmetric_cipher_decrypt(rsa_server_privkey, buf =
+ 2,
>>> -                                               pre_master_secret,
>>> -                                               key_size, 48);
>>> +       pre_master_secret =3D l_malloc(key_size);
>>> +
>>> +       bytes_decrypted =3D l_asymmetric_cipher_decrypt(rsa_server_priv=
key,
>>> +                                                       buf + 2,
>>> +
>>> pre_master_secret,
>>> +                                                       key_size,
>>> key_size);
>>
>>
>> So what's the verdict, I thought we decided to accept short reads?
>
>
> Short reads work with software RSA in the kernel, but we're still sorting
> out expectations for crypto hardware drivers. For now, long reads are sti=
ll
> the way to ensure compatibility.

I guess it depends on what kernel you're aiming for but your test tree
has only the software pkcs1pad driver.  Upstream can in theory add a
new driver at any time but AF_ALG is still under review there.

By the way I wouldn't call these short reads as we're reading all the
data that the socket has to read ;)  In the commit message I think Mat
may be referring to the other short reads.

I don't think these kernel api changes should spill into tls.c though.

Best regards

--===============3265570502811129211==--

