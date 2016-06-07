Content-Type: multipart/mixed; boundary="===============6880932240863769162=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: cipher, tls, and keys
Date: Tue, 07 Jun 2016 14:40:10 -0500
Message-ID: <5757231A.5020002@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1606071211150.9891@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6880932240863769162==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 06/07/2016 02:30 PM, Mat Martineau wrote:
> On Mon, 6 Jun 2016, Denis Kenzior wrote:
>
>> Hi Mat,
>>
>> On 06/06/2016 06:19 PM, Mat Martineau wrote:
>>>
>>> So far I've updated the asymmetric cipher code to work with the current
>>> version of the AF_ALG akcipher interface. This leaves the asymmetric
>>> cipher & tls disconnected from the new key/keyring code, which doesn't
>>> take advantage of the kernel's capabilities with akcipher and the
>>> keyring.
>>>
>>> We have three options:
>>>
>>> 1. The current code works, so leave it as-is. I took this approach first
>>> to minimize changes while I got it working.
>>>
>>> 2. Make use of the keyctl() crypto API that's under review. This has the
>>> clearest upstream path because it was implemented by the keyring
>>> maintainer. Would simplify l_asymmetric_cipher code and involve fewer
>>> syscalls.
>>
>> I agree that keyctl is the one to use.  I would keep the asymmetric
>> cipher classes the way they are, but remove the sign/verify
>> operations.  Mmake tls depend on keyctl/keyring directly for sign/verify.
>
> keyctl/keyring can do encrypt/decrypt too, I'd like to pick one way or
> the other. Consistency in key handlng between sign/verify and
> encrypt/decrypt would make for a clearer ELL interface. Looks like we'll
> need to load the keys in to the keyring for encrypt/decrypt anyway (to
> get the key size), so might as well leverage the simpler interface for
> encrypt/decrypt too.

TLS can use keyctl throughout.  This wasn't what my comment was about. =

I just meant that we should still make/keep a sane asymmetric cipher API =

in ell.

>
>>
>>>
>>> 3. Continue with AF_ALG but make use of ALG_SET_KEY_ID and
>>> ALG_SET_PUB_KEY_ID to use keys already in a keyring. Would not be a big
>>> change, but the kernel patch set is a work in progress and much more
>>> uncertainty about upstream prospects / timing.
>>
>> Lets follow these patches, and if they ever get upstreamed, then we
>> can update the asymmetric_cipher API to support these operations, just
>> for completeness sake.
>
> If we build a good asymmetric API (sign/verify/encrypt/decrypt) around
> keyctl I don't see a big benefit to supporting both AF_ALG-akcipher and
> keyctl. If an l_asymmetric_cipher instance had a long lifetime and was
> reused frequently, there would be some savings (less re-parsing of the
> keys inside the kernel), but tls doesn't use the asymmetric cipher API
> that way.

akcipher is more flexible, since you can use it with or without =

templates (such as pkcs1pad).  So while low priority, I'd still keep an =

akcipher abstraction around.

Regards,
-Denis

--===============6880932240863769162==--

