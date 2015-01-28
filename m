Content-Type: multipart/mixed; boundary="===============4775078597887541788=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] cipher: RFC on an API for a cipher utility infrastructure
Date: Wed, 28 Jan 2015 10:20:13 -0800
Message-ID: <2897E19E-8F39-4008-AFF7-E5E60DA39486@holtmann.org>
In-Reply-To: <54C920E0.50109@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4775078597887541788==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tomasz,

>> Here is a quick proposal on the cipher infra for ell. I followed what has
>> been done with checksums in ell, with obvious differences due to the cip=
hers
>> themselves. (2 different actions: encrypt/decrypt and the presence of a =
key)
>> =

>> I have open issues here:
>> =

>> l_cipher_reset() on its own might not be useful, should I add the possib=
ilty
>> to change the key as well? Unless there is no cipher state to reset, and=
 then
>> it's better not having such function. (I am not aware of the kernel ciph=
er
>> internals, related to some state there so if one can enlight the issue h=
ere)
>> =

> =

> I don't think a reset function would be useful.
> =

>> Alos, about encrypt/decrypt. Currently I am proposing to have those as t=
hey
>> will send the data, and we get it back via get_data() (function name it =
not
>> that great btw).
>> So:
>> =

>> - is having only encrypt/decrypt an option? (so send/recv would be done =
in
>> each functions). Though 2 blocking functions at a time... not great.
>> =

> =

> I think that would be preferable.  I don't foresee us processing large ch=
unks of encrypted data, so that should be okay.

yes, this is the most we should do inside ELL. Anything more generic is not=
 a good idea. You better self-code that in your project then. Using AF_ALG =
is always inefficient. Just for small amounts data it is irrelevant and usi=
ng the kernel crypto subsystem keeps our code simpler.

>> - or, what about enabling async access? Unless I miss something about the
>> crypto layer in the kernel, here the socket is blocking. So we could be
>> stalled at some point. checksum does the same, is there any plan to make=
 it
>> async actually? like a function l_cipher_enable_async(), which would cal=
l the
>> right fcntl() and return the socket which we could use in the event loop.
>> =

> =

> Right now I wouldn't worry about this.  If we encounter a situation where=
 we actually benefit from this, then lets revisit then.  Right now we are g=
oing to be encrypting/decrypting data on the order of a few hundred bytes. =
 EAPoL-Key Data is capped at about 32K, so even in the absolute worst case =
I don't think we need to worry about this.

Actually we might want to do this directly inside iwd instead of ELL. That =
background is pretty much that we need to run a basic selftest on available=
 ciphers and algs anyway first. Not all kernels have the required ciphers (=
or even hash algorithm) that we need. So the advantage doing it in iwd dire=
ct without a framework in ELL is that we can quickly test the kernel and th=
en just abort.

It would also be an easier place to figure out what we really need in the e=
nd and what performance impact we are accepting by using the kernel crypto =
subsystem and AF_ALG.

The checksum stuff has been added to ELL since we had that in GLib. However=
 the HMAC part has never been added to ELL. That has been kept in iwd. And =
I am actually considering doing native AF_ALG for the checksum and HMAC wit=
hout involving ELL. Reason is that we can be more efficient with the file d=
escriptors and system calls if we target specific parts.

Regards

Marcel


--===============4775078597887541788==--

