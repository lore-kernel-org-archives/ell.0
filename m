Content-Type: multipart/mixed; boundary="===============0149065867791392224=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH v2 4/6] unit: Generate and use PKCS8 version of server key
 for TLS tests
Date: Mon, 08 Aug 2016 15:27:39 -0700
Message-ID: <alpine.OSX.2.20.1608081408210.4540@mjmartin-mac01.local>
In-Reply-To: <57A8E476.50307@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0149065867791392224==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Mon, 8 Aug 2016, Denis Kenzior wrote:

> Hi Mat,
>
> On 08/08/2016 12:53 PM, Mat Martineau wrote:
>> On Mon, 8 Aug 2016, Denis Kenzior wrote:
>> =

>>> Hi Mat,
>>> =

>>> On 08/08/2016 12:25 PM, Mat Martineau wrote:
>>>> ---
>>>>   unit/cert-server-key-pkcs8.pem | 28 ++++++++++++++++++++++++++++
>>>>   unit/gencerts.sh               |  1 +
>>>>   unit/test-tls.c                | 16 ++++++++--------
>>>>   3 files changed, 37 insertions(+), 8 deletions(-)
>>>>   create mode 100644 unit/cert-server-key-pkcs8.pem
>>>> =

>>> =

>>> I wonder, what's the reasoning behind this change?
>> =

>> It's the private key format that the keyctl API knows how to parse. The
>> previous private key format doesn't work.
>> =

>
> The previous format was PKCS 1.5 right?  There's no way to support that o=
ne?
>
> Unit tests inside iwd assume PKCS1.5 at the moment.  And I'm worried that =

> most existing certificates won't be PKCS#8.

RSA private keys are a pending addition to the kernel key subsystem in the =

keys-next branch. Only a PKCS#8 private key parser was added to the =

asymmetric key type. Additional parsers can be added, it will try each =

registered parser until one succeeds.

The PKCS#1 key data is stored as an octet string inside the PKCS#8 format.

My impression is that the kernel uses the PKCS#8 format because it only =

accepts DER-encoded keys. PKCS#8 retains both a crypto algorithm =

identifier and a key encryption identifier when private key data is =

converted from PEM to DER (binary), so it the kernel can deduce the =

correct crypto algorithm and decrypt the key. With the OpenSSL-style =

PKCS#1 keys we used before, all the kernel can do is assume that an ASN.1 =

sequence of 9 integers is, in fact, an RSA private key.

Since it's trivial to convert private key files to PKCS#8 with openssl, I =

think it makes sense to stick to PKCS#8 in the ELL key API.

Do you want me to change the filenames so that cert-client-key.pem and =

cert-server-key.pem are PKCS#8 format? That way there aren't two copies of =

the private key around. I think that would be transparent to the iwd unit =

tests.

--
Mat Martineau
Intel OTC

--===============0149065867791392224==--

