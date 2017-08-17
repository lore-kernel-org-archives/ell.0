Content-Type: multipart/mixed; boundary="===============6402024513344001548=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 7/7] unit: Test loading encrypted private key PEM files
Date: Thu, 17 Aug 2017 08:16:49 -0700
Message-ID: <alpine.OSX.2.21.1708170754330.27223@cgguymon-mobl2.amr.corp.intel.com>
In-Reply-To: <2911f3fc-6821-685c-ac83-cb5d86f941f9@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6402024513344001548==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Wed, 16 Aug 2017, Denis Kenzior wrote:

> Hi Mat,
>
>>> I was thinking we simply generate the pem files for maintainer builds. =
 >> =

>>> I would assume that introducing an openssl dependency for such builds
>>> shouldn't be an issue.  Then have 'make dist' package the generated fil=
es =

>>> into the tarball so that official 'released' versions build without =

>>> openssl.
>> =

>> One catch with that approach: test-key has reference ciphertext and a =

>> reference signature that were generated with one of those certs.
>> =

>
> So every X months we'd need to regenerate all the pem files, recommit the=
m to =

> the tree and fix up some unit test?  That sounds awful :)

More like "every X decades". The certs don't expire for 27+ years (10000 =

days).

>> Some options:
>> =

>> * Keep one cert around for this test (which seems to defeat the whole =

>> purpose)
>> * Dynamically generate the ciphertext & signature along with the certs
>> =

>
> We could just generate a .h file with the above and include it into the u=
nit =

> test.  That really sounds like a winner to me.

If you skip the conversion to C array, the unit test could read the binary =

data from a couple of files instead of compiling it in.

--
Mat Martineau
Intel OTC

--===============6402024513344001548==--

