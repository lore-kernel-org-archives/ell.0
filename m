Content-Type: multipart/mixed; boundary="===============0321732484247500043=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel at holtmann.org>
To: ell at lists.01.org
Subject: Re: [PATCH] build: Check for openssl legacy provider requirement
Date: Fri, 20 May 2022 11:13:55 +0200
Message-ID: <0373E38A-FD24-457D-B4DE-DFB4A9F91DCD@holtmann.org>
In-Reply-To: 20220519224828.91435-1-mathew.j.martineau@linux.intel.com

--===============0321732484247500043==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

> OpenSSL 3 introduced some command line incompatibilities and removed
> some old algorithms from the defaults. This broke some of the unit test
> cert generation commands on distros like Ubuntu 22.04 and Fedora 36.
> =

> Detect support of "providers" by the system openssl command and insert
> the necessary command line parameters to enable legacy algorithms for
> openssl v3, but leave the commands unchanged for older openssl versions.
> ---
> =

> Tested on Ubuntu 22.04, Fedora 36, and Fedora 35.
> =

> ---
> Makefile.am  | 26 ++++++++++++++++++--------
> configure.ac |  3 +++
> 2 files changed, 21 insertions(+), 8 deletions(-)

what would it take to just use OpenSSL 3 since these are just required on t=
he development systems. I need to check my release system since that is his=
torically always behind, but I feel this business of supporting two OpenSSL=
 versions will get out of hand quickly. It is too bad that we can not gener=
ate the certificates with our own tools.

Regards

Marcel

--===============0321732484247500043==--

