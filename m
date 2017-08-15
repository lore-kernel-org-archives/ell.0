Content-Type: multipart/mixed; boundary="===============5742970274548198716=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 7/7] unit: Test loading encrypted private key PEM files
Date: Tue, 15 Aug 2017 12:48:41 -0500
Message-ID: <d54c25f3-c9a7-132e-61f9-221a7e185b3c@gmail.com>
In-Reply-To: <alpine.OSX.2.21.1708141656310.2825@gzuniga-mobl2.amr.corp.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5742970274548198716==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

>> bash: unit/gencerts.sh: /usr/bin/sh: bad interpreter: No such file or =

>> directory
> =

> Whoops. /bin/sh would be more likely to work everywhere.

yep

> =

>> Should we drop the .pem files from the tree and simply use gencerts.sh =

>> when running configure?
> =

> That would add openssl to our build time dependencies for unit tests. =

> How about regenerating the .pem files before tagging a release?
> =


I was thinking we simply generate the pem files for maintainer builds. =

I would assume that introducing an openssl dependency for such builds =

shouldn't be an issue.  Then have 'make dist' package the generated =

files into the tarball so that official 'released' versions build =

without openssl.

Regards,
-Denis

--===============5742970274548198716==--

