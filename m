Content-Type: multipart/mixed; boundary="===============7985559947070648470=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 7/7] unit: Test loading encrypted private key PEM files
Date: Wed, 16 Aug 2017 22:39:13 -0500
Message-ID: <2911f3fc-6821-685c-ac83-cb5d86f941f9@gmail.com>
In-Reply-To: <alpine.OSX.2.21.1708161508090.23612@mjmartin-mac01.sea.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7985559947070648470==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

>> I was thinking we simply generate the pem files for maintainer builds.  =
>> I would assume that introducing an openssl dependency for such builds
>> shouldn't be an issue.  Then have 'make dist' package the generated =

>> files into the tarball so that official 'released' versions build =

>> without openssl.
> =

> One catch with that approach: test-key has reference ciphertext and a =

> reference signature that were generated with one of those certs.
> =


So every X months we'd need to regenerate all the pem files, recommit =

them to the tree and fix up some unit test?  That sounds awful :)

> Some options:
> =

> * Keep one cert around for this test (which seems to defeat the whole =

> purpose) >
> * Dynamically generate the ciphertext & signature along with the certs
> =


We could just generate a .h file with the above and include it into the =

unit test.  That really sounds like a winner to me.

Regards,
-Denis

--===============7985559947070648470==--

