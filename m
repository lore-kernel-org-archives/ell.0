Content-Type: multipart/mixed; boundary="===============0740614416811049294=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH v3 1/5] cipher: Update for current kernel akcipher
 interface
Date: Mon, 13 Jun 2016 15:29:56 -0700
Message-ID: <alpine.OSX.2.20.1606131423090.9168@mjmartin-mac01.wa.intel.com>
In-Reply-To: <575F21EC.7000304@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0740614416811049294==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Mon, 13 Jun 2016, Denis Kenzior wrote:

> Hi Mat,
>
>>>
>>> Should we go in the direction of doing something like:
>>> =

>>> acipher =3D l_asymmetric_cipher_new(type);
>>> =

>>> l_asymmetric_cipher_set_pubkey(acipher, key, key_size);
>>> l_asymmetric_cipher_set_privkey(acipher, key, key_size);
>>> =

>>> l_asymmetric_cipher_get_key_size(acipher);
>> =

>> Last week I pushed back on adding a public/private flag to
>> l_asymmetric_cipher_new, but as I keep working on this the flag is
>> becoming the most appealing. If there are separate key setting
>> functions, those key set function end up being thin wrappers around a
>> common internal function anyway, and makes the asym cipher api more
>> complicated to use and implement.
>> =

>> Here's what I'd like to do:
>>
>>   * Add public/private flag to l_asymmetric_cipher_new
>>   * Move TLS to keyctl-based crypto
>>   * Remove l_asymmetric_cipher_get_key_size (TLS is the only user) and
>> the ASN.1 parsing code.
>> =

>
> Do we still need to know the key size in order to provide a proper buffer=
 for =

> certain implementations?

We won't have a direct need for it within ELL (keyctl will provide the key =

length for TLS purposes). If this isn't part of the l_asymmetric_cipher =

API, the key length information is available from l_key if the key is =

loaded there. l_asymmetric_cipher users would be no worse off then normal =

AF_ALG akcipher users in terms of choosing optimal read buffer sizes.

Long term, we could implement a getsockopt call to get the =

key length - but it seems worthwhile to trim the ASN.1 parser out of ELL =

in the near term.

>>>> -    cipher->cipher.decrypt_sk =3D create_alg("akcipher", alg_name,
>>>> -                        key, key_length);
>>>> -    if (cipher->cipher.decrypt_sk < 0)
>>>> -        goto error_close;
>>>> +    if (!cipher->public_key) {
>>>> +        cipher->cipher.decrypt_sk =3D create_alg("akcipher", alg_name,
>>>> +                            key, key_length,
>>>> +                            cipher->public_key);
>>>> +        if (cipher->cipher.decrypt_sk < 0)
>>>> +            goto error_close;
>>>> +    }
>
> By my reading decrypt_sk is only initialized if cipher->public_key is =

> false...

Yes, you're right. I had conflated my "use just one socket for akcipher" =

code and the validity checking question.

>
>>> This should probably check for validity of decrypt_sk
>> =

>> There should never be a struct l_asymmetric_cipher with a bad decrypt_sk
>> - validity is checked in l_asymmetric_cipher_new and it never returns a
>> struct with a bad socket handle. If the socket gets corrupted somehow,
>> operate_cipher will let us know. Is this only important if the set key
>> functions are split out?
>> =

>
> Why bother operating on invalid sockets.  If we were provided a public ke=
y, =

> then we can't decrypt, right?

If we have two sockets and one might not be initialized, you're right that =

it does makes sense to check before calling.

I'd like to change it to use one socket for asymmetric ciphers, in which =

case the check would be up to the kernel (unless we keep track of the key =

type just for this purpose). This significantly streamlines the common =

case.

>
>> Do you know why we have separate encrypt_sk and decrypt_sk sockets? I
>> tried using the same socket for all operations and it works fine.
>> =

>
> This is another weirdness in the userspace API.  I think it is an issue i=
n =

> certain skcipher implementations.  They don't keep a separate encrypt / =

> decrypt state.  So if you don't keep two separate sockets, you get screwy =

> results.  I think ARC4 is our biggest culprit.  Look in the history of =

> cipher.c for details.  git show 632dfc8fc9d53718e5596cad25e0a71c373cf964

One socket is working ok for akcipher, even having four different =

operations on that one socket.

--
Mat Martineau
Intel OTC

--===============0740614416811049294==--

