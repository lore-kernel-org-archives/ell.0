Content-Type: multipart/mixed; boundary="===============6380123591628671102=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 7/7] unit: Test loading encrypted private key PEM files
Date: Wed, 16 Aug 2017 19:03:16 +0200
Message-ID: <CAOq732LCNiSuK-tx9wb5=kXJT2amPBDQwxi3YOAK_YZMZYRNYQ@mail.gmail.com>
In-Reply-To: <2686b309-ffe2-9f06-fefc-a234fcebb1ea@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6380123591628671102==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

On 14 August 2017 at 22:35, Denis Kenzior <denkenz@gmail.com> wrote:
> On 08/14/2017 11:44 AM, Mat Martineau wrote:
>> On Mon, 14 Aug 2017, Andrew Zaborowski wrote:
>>> New test cert files are encrytped versions of cert-client-key-pkcs8.pem
>>> generated with:
>>>
>>> openssl pkcs8 -in cert-client-key-pkcs8.pem -out
>>> cert-client-key-md5-des.pem -topk8
>>>
>>> openssl pkcs8 -in cert-client-key-pkcs8.pem -out
>>> cert-client-key-v2-des.pem -topk8 -v2 des-cbc
>>>
>>> openssl pkcs8 -in cert-client-key-pkcs8.pem -out
>>> cert-client-key-v2-des-ede3.pem -topk8 -v2 des-ede3-cbc
>>>
>>> openssl pkcs8 -in cert-client-key-pkcs8.pem -out
>>> cert-client-key-v2-aes128.pem -topk8 -v2 aes128
>>>
>>> openssl pkcs8 -in cert-client-key-pkcs8.pem -out
>>> cert-client-key-v2-aes256.pem -topk8 -v2 aes256
>>
>>
>> Please update unit/gencerts.sh to create these files too. This makes it
>> easy to regenerate them when the certs expire and ensures that the comma=
nds
>> are documented for developers who don't have the git history handy.
>>
>
> Yes, please do this.  I've applied this patch in the meantime.

Thanks, good point, I'll send a patch.

>
> By the way, on my Gentoo box I get:
>
> bash: unit/gencerts.sh: /usr/bin/sh: bad interpreter: No such file or
> directory
>
> Should we drop the .pem files from the tree and simply use gencerts.sh wh=
en
> running configure?

Also note that openssl installations differ in compile options,
probably not enough to cause problems with our usage.

Best regards

--===============6380123591628671102==--

