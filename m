Content-Type: multipart/mixed; boundary="===============2463934562908612233=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] cipher: add AES-CMAC hashing support
Date: Wed, 29 May 2019 11:14:27 -0500
Message-ID: <0e1f99ae-34ba-a276-6058-ed3cb3f5e364@gmail.com>
In-Reply-To: <20190529105234.d5hn6i2gbx4boswj@scytale>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2463934562908612233==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Micha=C5=82,

> Is this about mesh_crypto_aes_ccm_encrypt and
> mesh_crypto_aes_ccm_decrypt functions in mesh/crypto.c?

No, this is different.  But *yikes*.  BlueZ implements AEAD cipher in =

terms of ecb(aes)?  That is highly inefficient due to syscall overhead.

> =

> If so, they can be implemented with l_aead_cipher_* API, without any
> changes to ELL, see below.

That would be much better, yes.

> =

> There is a slight problem, though - this works only on newer kernels
> (IIRC, 4.9+), and some vendors (particularly Freescale i.MX6) do not
> provide them :(
> =

> What's worse, my experiments show what the kernel does *not* report an
> error while bind()ing the algo socket, but the results are wrong :(

I think there was a bug in AEAD ciphers, the reported length from one of =

the operations was incorrect.  I believe Mat fixed this and ell deals =

with this correctly.  See 08be47564b3c49404e5cb6061c0ede94b0a9e783.

But still, 4.9 is a freaking old kernel.  Worst case have the vendor =

port the fixed aead implementation into their tree.

If this isn't available, you can always hack in a fallback in bluez to =

keep the same ecb(aes) behavior, but that's just painful :)

Regards,
-Denis

--===============2463934562908612233==--

