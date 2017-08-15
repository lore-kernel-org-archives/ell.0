Content-Type: multipart/mixed; boundary="===============7800968136671964148=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 7/7] unit: Test loading encrypted private key PEM files
Date: Mon, 14 Aug 2017 17:10:57 -0700
Message-ID: <alpine.OSX.2.21.1708141656310.2825@gzuniga-mobl2.amr.corp.intel.com>
In-Reply-To: <2686b309-ffe2-9f06-fefc-a234fcebb1ea@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7800968136671964148==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Mon, 14 Aug 2017, Denis Kenzior wrote:

> Hi Andrew/Mat,
>
> On 08/14/2017 11:44 AM, Mat Martineau wrote:
>> =

>> Andrew,
>> =

>> On Mon, 14 Aug 2017, Andrew Zaborowski wrote:
>> =

>>> New test cert files are encrytped versions of cert-client-key-pkcs8.pem
>>> generated with:
>>> =

>>> openssl pkcs8 -in cert-client-key-pkcs8.pem -out =

>>> cert-client-key-md5-des.pem -topk8
>>> =

>>> openssl pkcs8 -in cert-client-key-pkcs8.pem -out =

>>> cert-client-key-v2-des.pem -topk8 -v2 des-cbc
>>> =

>>> openssl pkcs8 -in cert-client-key-pkcs8.pem -out =

>>> cert-client-key-v2-des-ede3.pem -topk8 -v2 des-ede3-cbc
>>> =

>>> openssl pkcs8 -in cert-client-key-pkcs8.pem -out =

>>> cert-client-key-v2-aes128.pem -topk8 -v2 aes128
>>> =

>>> openssl pkcs8 -in cert-client-key-pkcs8.pem -out =

>>> cert-client-key-v2-aes256.pem -topk8 -v2 aes256
>> =

>> Please update unit/gencerts.sh to create these files too. This makes it =

>> easy to regenerate them when the certs expire and ensures that the comma=
nds =

>> are documented for developers who don't have the git history handy.
>> =

>
> Yes, please do this.  I've applied this patch in the meantime.
>
> By the way, on my Gentoo box I get:
>
> bash: unit/gencerts.sh: /usr/bin/sh: bad interpreter: No such file or =

> directory

Whoops. /bin/sh would be more likely to work everywhere.

> Should we drop the .pem files from the tree and simply use gencerts.sh wh=
en =

> running configure?

That would add openssl to our build time dependencies for unit tests. How =

about regenerating the .pem files before tagging a release?

--
Mat Martineau
Intel OTC

--===============7800968136671964148==--

