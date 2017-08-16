Content-Type: multipart/mixed; boundary="===============2857572553403732566=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 7/7] unit: Test loading encrypted private key PEM files
Date: Wed, 16 Aug 2017 15:48:01 -0700
Message-ID: <alpine.OSX.2.21.1708161508090.23612@mjmartin-mac01.sea.intel.com>
In-Reply-To: <d54c25f3-c9a7-132e-61f9-221a7e185b3c@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2857572553403732566==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Tue, 15 Aug 2017, Denis Kenzior wrote:

> Hi Mat,
>
>>> bash: unit/gencerts.sh: /usr/bin/sh: bad interpreter: No such file or =

>>> directory
>> =

>> Whoops. /bin/sh would be more likely to work everywhere.
>
> yep

I'll send that trivial patch

>
>> =

>>> Should we drop the .pem files from the tree and simply use gencerts.sh =

>>> when running configure?
>> =

>> That would add openssl to our build time dependencies for unit tests. Ho=
w =

>> about regenerating the .pem files before tagging a release?
>> =

>
> I was thinking we simply generate the pem files for maintainer builds. I =

> would assume that introducing an openssl dependency for such builds shoul=
dn't =

> be an issue.  Then have 'make dist' package the generated files into the =

> tarball so that official 'released' versions build without openssl.

One catch with that approach: test-key has reference ciphertext and a =

reference signature that were generated with one of those certs.

Some options:

* Keep one cert around for this test (which seems to defeat the =

whole purpose)

* Dynamically generate the ciphertext & signature along =

with the certs

* Leave the certs checked in


I favor leaving the .pems in the tree.

--
Mat Martineau
Intel OTC

--===============2857572553403732566==--

