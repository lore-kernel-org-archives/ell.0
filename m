Content-Type: multipart/mixed; boundary="===============2200003442013239816=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] unit: Generate encrypted keys in gencerts.sh
Date: Wed, 16 Aug 2017 20:09:59 +0200
Message-ID: <CAOq732+_yE+=Ck=iWQij4MpRP9zxGFHKCy-VgkYAQDu0-QM7sg@mail.gmail.com>
In-Reply-To: <alpine.OSX.2.21.1708161016010.21613@mjmartin-mac01.sea.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2200003442013239816==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 16 August 2017 at 19:21, Mat Martineau
<mathew.j.martineau@linux.intel.com> wrote:
> On Wed, 16 Aug 2017, Andrew Zaborowski wrote:
>
>> ---
>> unit/gencerts.sh | 5 +++++
>> 1 file changed, 5 insertions(+)
>>
>> diff --git a/unit/gencerts.sh b/unit/gencerts.sh
>> index 790c715..419afa8 100755
>> --- a/unit/gencerts.sh
>> +++ b/unit/gencerts.sh
>> @@ -17,6 +17,11 @@ openssl pkcs8 -topk8 -nocrypt -in cert-client-key.pem
>> -out cert-client-key-pkcs8
>> openssl req -new -extensions cert_ext -config ./gencerts.cnf -subj '/O=
=3DBar
>> Example Organization/CN=3DBar Example
>> Organization/emailAddress=3Dbar(a)mail.example' -key cert-client-key.pem=
 -out
>> cert-client.csr
>> openssl x509 -req -extensions cert_ext -extfile ./gencerts.cnf -in
>> cert-client.csr -CA cert-ca.pem -CAkey cert-ca-key.pem -CAcreateserial
>> -sha256 -days 10000 -out cert-client.pem
>> openssl verify -CAfile cert-ca.pem cert-client.pem
>> +openssl pkcs8 -in cert-client-key-pkcs8.pem -out
>> cert-client-key-md5-des.pem -topk8 -passout pass:abc
>> +openssl pkcs8 -in cert-client-key-pkcs8.pem -out
>> cert-client-key-v2-des.pem -topk8 -v2 des-cbc -passout pass:abc
>> +openssl pkcs8 -in cert-client-key-pkcs8.pem -out
>> cert-client-key-v2-des-ede3.pem -topk8 -v2 des-ede3-cbc -passout pass:abc
>> +openssl pkcs8 -in cert-client-key-pkcs8.pem -out
>> cert-client-key-v2-aes128.pem -topk8 -v2 aes128 -passout pass:abc
>> +openssl pkcs8 -in cert-client-key-pkcs8.pem -out
>> cert-client-key-v2-aes256.pem -topk8 -v2 aes256 -passout pass:abc
>>
>
> I was looking at cert generation yesterday, and found that the above
> commands did not work with openssl 1.1. I believe these work with both 1.0
> and 1.1:
>
> openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-md5-des.=
pem
> -topk8 -v1 PBE-MD5-DES -passout pass:abc
> openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-des.p=
em
> -topk8 -v2 des-cbc -v2prf hmacWithSHA1 -passout pass:abc
> openssl pkcs8 -in cert-client-key-pkcs8.pem -out
> cert-client-key-v2-des-ede3.pem -topk8 -v2 des-ede3-cbc -v2prf hmacWithSH=
A1
> -passout pass:abc
> openssl pkcs8 -in cert-client-key-pkcs8.pem -out
> cert-client-key-v2-aes128.pem -topk8 -v2 aes128 -v2prf hmacWithSHA1 -pass=
out
> pass:abc
> openssl pkcs8 -in cert-client-key-pkcs8.pem -out
> cert-client-key-v2-aes256.pem -topk8 -v2 aes256 -v2prf hmacWithSHA1 -pass=
out
> pass:abc

Thanks for checking, I'll use those then.  They do work on my standard
ubuntu install.

>
> I had to add "-v2prf hmacWithSHA1" to get the unit tests to pass when the
> certs are created with openssl 1.1. The default changed from hmacWithSHA1=
 in
> 1.0 to hmacWithSHA256 in 1.1. Would you expect the tests to pass either w=
ay?

Yep, both should work, I'm going to try debug this.

Best regards

--===============2200003442013239816==--

