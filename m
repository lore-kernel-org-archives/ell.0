Content-Type: multipart/mixed; boundary="===============5266373671741846020=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] cipher: RFC on an API for a cipher utility infrastructure
Date: Wed, 28 Jan 2015 12:19:16 -0600
Message-ID: <54C92824.2000708@gmail.com>
In-Reply-To: <2897E19E-8F39-4008-AFF7-E5E60DA39486@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5266373671741846020==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

 >>
>> Right now I wouldn't worry about this.  If we encounter a situation wher=
e we actually benefit from this, then lets revisit then.  Right now we are =
going to be encrypting/decrypting data on the order of a few hundred bytes.=
  EAPoL-Key Data is capped at about 32K, so even in the absolute worst case=
 I don't think we need to worry about this.
>
> Actually we might want to do this directly inside iwd instead of ELL. Tha=
t background is pretty much that we need to run a basic selftest on availab=
le ciphers and algs anyway first. Not all kernels have the required ciphers=
 (or even hash algorithm) that we need. So the advantage doing it in iwd di=
rect without a framework in ELL is that we can quickly test the kernel and =
then just abort.
>

I tend to disagree.  We might as well make ell into a proper API.  If we =

need to enumerate supported AF_ALGs and add that functionality to ell, =

then that's what we have to do.

In the end, the fastest way to implement hashing and crypto is natively. =

  So if we decide to add that to ell at a later date, then we =

automatically make iwd faster without re-writing any code.

> It would also be an easier place to figure out what we really need in the=
 end and what performance impact we are accepting by using the kernel crypt=
o subsystem and AF_ALG.
>
> The checksum stuff has been added to ELL since we had that in GLib. Howev=
er the HMAC part has never been added to ELL. That has been kept in iwd. An=
d I am actually considering doing native AF_ALG for the checksum and HMAC w=
ithout involving ELL. Reason is that we can be more efficient with the file=
 descriptors and system calls if we target specific parts.
>

Yes, I thought that was pretty strange, but fixing it wasn't my priority =

right now.  In the end our target use case does not warrant any sort of =

'efficiency' tricks / optimizations, so I don't see the point. =

Especially given that the code is essentially the same in src/aes.c and =

ell/checksum.c

Regards,
-Denis

--===============5266373671741846020==--

