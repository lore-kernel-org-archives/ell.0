Content-Type: multipart/mixed; boundary="===============0286363801897198417=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH v3 1/5] cipher: Update for current kernel akcipher
 interface
Date: Tue, 14 Jun 2016 10:37:12 -0700
Message-ID: <alpine.OSX.2.20.1606141031010.13500@animeshb-mobl.amr.corp.intel.com>
In-Reply-To: <575F390A.8080007@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0286363801897198417==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


Denis,

On Mon, 13 Jun 2016, Denis Kenzior wrote:

> Hi Mat,
>
>>>
>>> Do we still need to know the key size in order to provide a proper
>>> buffer for certain implementations?
>> =

>> We won't have a direct need for it within ELL (keyctl will provide the
>> key length for TLS purposes). If this isn't part of the
>> l_asymmetric_cipher API, the key length information is available from
>> l_key if the key is loaded there. l_asymmetric_cipher users would be no
>> worse off then normal AF_ALG akcipher users in terms of choosing optimal
>> read buffer sizes.
>> =

>> Long term, we could implement a getsockopt call to get the key length -
>> but it seems worthwhile to trim the ASN.1 parser out of ELL in the near
>> term.
>
> My feeling is, lets make asymmetric ciphers work for now, at least until =
the =

> key stuff is ready.  So we can keep the ASN.1 parser to get the key lengt=
h =

> for now, with an eye to migrate it to getsockopt when that feature is add=
ed =

> to the kernel.

Ok

>
>> I'd like to change it to use one socket for asymmetric ciphers, in which
>> case the check would be up to the kernel (unless we keep track of the
>> key type just for this purpose). This significantly streamlines the
>> common case.
>> =

>
> Since the only asymmetric cipher is RSA, we might be getting lucky here. =
 I =

> have no problem moving to a single socket semantic, as long as the kernel =

> guarantees that this will work for all akcipher algorithms.

There is a check in algif_akcipher to make sure there is not input data =

pending for a previous operation.

> I assumed a single socket was fine for skcipher as well, but was proven =

> wrong.  The current semantics in the kernel are weird.  You almost have t=
o =

> know the underlying algorithm implementation in order to do the right thi=
ng.
>
>> =

>> One socket is working ok for akcipher, even having four different
>> operations on that one socket.
>> =

>
> Because there's no 'state'.  In RC4 results of an operation are carried i=
nto =

> the subsequent operation(s).  Highly unlikely that any akciphers will wor=
k =

> this way, but who knows.  The semantics need to be nailed down in the doc=
s.

Having the pending data check is one part of clarifying the semantics, and =

I agree that docs are important for this. I'll check up on the =

documentation side of things (Stephan usually includes docs, but they're =

missing from akcipher).

--
Mat Martineau
Intel OTC

--===============0286363801897198417==--

