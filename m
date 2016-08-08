Content-Type: multipart/mixed; boundary="===============7987914947612079928=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 4/6] unit: Generate and use PKCS8 version of server key
 for TLS tests
Date: Mon, 08 Aug 2016 18:30:48 -0500
Message-ID: <57A91628.7030401@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1608081408210.4540@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7987914947612079928==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

 >
> RSA private keys are a pending addition to the kernel key subsystem in
> the keys-next branch. Only a PKCS#8 private key parser was added to the
> asymmetric key type. Additional parsers can be added, it will try each
> registered parser until one succeeds.
>
> The PKCS#1 key data is stored as an octet string inside the PKCS#8 format.
>
> My impression is that the kernel uses the PKCS#8 format because it only
> accepts DER-encoded keys. PKCS#8 retains both a crypto algorithm
> identifier and a key encryption identifier when private key data is
> converted from PEM to DER (binary), so it the kernel can deduce the
> correct crypto algorithm and decrypt the key. With the OpenSSL-style
> PKCS#1 keys we used before, all the kernel can do is assume that an
> ASN.1 sequence of 9 integers is, in fact, an RSA private key.
>
> Since it's trivial to convert private key files to PKCS#8 with openssl,
> I think it makes sense to stick to PKCS#8 in the ELL key API.

The problem is that the WPA-Enterprise certificate is usually generated =

by the sysadmin or network admin.  So we can't really control what we =

get.  My impression is that PKCS1 format is much more common than #8, =

and converting on the fly isn't really an option.

>
> Do you want me to change the filenames so that cert-client-key.pem and
> cert-server-key.pem are PKCS#8 format? That way there aren't two copies
> of the private key around. I think that would be transparent to the iwd
> unit tests.

No, don't do that.

Regards,
-Denis


--===============7987914947612079928==--

