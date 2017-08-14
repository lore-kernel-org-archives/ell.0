Content-Type: multipart/mixed; boundary="===============8901926068351214368=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 4/7] pkcs5: Add pkcs5_cipher_from_alg_id
Date: Mon, 14 Aug 2017 15:28:12 -0500
Message-ID: <5bc8d0bb-b4b3-147c-2fc6-16d8ad59b0be@gmail.com>
In-Reply-To: <20170814145750.6683-4-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8901926068351214368==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/14/2017 09:57 AM, Andrew Zaborowski wrote:
> Add a utility to parse all of the PKCS#5 DER-encoded encryption scheme
> information, use the right PBKDF function to calculate the key,
> create the appropriate l_cipher object type (if we support that PKCS#5
> cipher type) with that key and set the IV on the l_cipher object.
> =

> We don't support any of the RC2 or RC5 based encryption schemes or
> those that use MD2, SHA512-224 or SHA512-256 for the hash, because
> there's no kernel support for those algorithms.  OpenSSL can create
> RSA private keys encrypted with some of these algorithms but MD5+DES
> and DES3-EDE are the default and the popular algorithms.  OpenSSL also
> supports camellia ciphers in those scenarios which we could add.
> =

> Note that the caller still needs to add or remove the padding from the
> data encrypted or decrypted with the l_cipher object.
> ---
>   Makefile.am         |   1 +
>   ell/pkcs5-private.h |  25 +++++
>   ell/pkcs5.c         | 311 +++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   3 files changed, 337 insertions(+)
>   create mode 100644 ell/pkcs5-private.h
> =


Applied, thanks.

Regards,
-Denis


--===============8901926068351214368==--

