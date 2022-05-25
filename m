Content-Type: multipart/mixed; boundary="===============0551399407236989832=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau at linux.intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH] build: Generate test certs using OpenSSL 3 legacy provider
Date: Wed, 25 May 2022 16:20:43 -0700
Message-ID: <13d780a4-a97d-15-6519-f4f281a61c71@linux.intel.com>
In-Reply-To: 20220521001534.1050889-1-mathew.j.martineau@linux.intel.com

--===============0551399407236989832==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 20 May 2022, Mat Martineau wrote:

> OpenSSL 3 moved some legacy algorithms to a separate "legacy" provider,
> so they are not available by default. Add the necessary command line
> parameters for use with OpenSSL 3, which distros are switching to. For
> example, Ubuntu 22.04 and Fedora 36 are the first version of those
> distributions to use OpenSSL 3 or later.
>
> This does break compatibility with older OpenSSL versions and
> configuring the project with "--enable-maintainer-mode". The
> tradeoff is keeping the autoconf/automake checks simpler.
> ---
> Makefile.am | 21 +++++++++++++--------
> 1 file changed, 13 insertions(+), 8 deletions(-)

Marcel, Denis -

Any further thoughts on which approach to openssl3 compatibility you =

prefer for ELL - this patch or "build: Check for openssl legacy provider =

requirement" with reverse compatibility?


Thanks,

Mat

> diff --git a/Makefile.am b/Makefile.am
> index d8ba99c..b8423c4 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -444,7 +444,8 @@ unit/cert-client-key-pkcs1.pem:
> 	$(AM_V_GEN)openssl genrsa -out $@ $($(AM_V_P)_redirect_openssl)
>
> unit/cert-client-key-pkcs1-des.pem: unit/cert-client-key-pkcs1.pem
> -	$(AM_V_GEN)openssl rsa -in $< -out $@ -des -passout pass:abc
> +	$(AM_V_GEN)openssl rsa -in $< -out $@ -des -passout pass:abc \
> +			-provider legacy -provider default
>
> unit/cert-client-key-pkcs1-des3.pem: unit/cert-client-key-pkcs1.pem
> 	$(AM_V_GEN)openssl rsa -in $< -out $@ -des3 -passout pass:abc
> @@ -463,15 +464,18 @@ unit/cert-client-key-pkcs8.pem: unit/cert-client-ke=
y-pkcs1.pem
>
> unit/cert-client-key-pkcs8-md5-des.pem: unit/cert-client-key-pkcs8.pem
> 	$(AM_V_GEN)openssl pkcs8 -in $< -out $@ \
> -			-topk8 -v1 PBE-MD5-DES -passout pass:abc
> +			-topk8 -v1 PBE-MD5-DES -passout pass:abc \
> +			-provider legacy -provider default
>
> unit/cert-client-key-pkcs8-sha1-des.pem: unit/cert-client-key-pkcs8.pem
> 	$(AM_V_GEN)openssl pkcs8 -in $< -out $@ \
> -			-topk8 -v1 PBE-SHA1-DES -passout pass:abc
> +			-topk8 -v1 PBE-SHA1-DES -passout pass:abc \
> +			-provider legacy -provider default
>
> unit/cert-client-key-pkcs8-v2-des.pem: unit/cert-client-key-pkcs8.pem
> 	$(AM_V_GEN)openssl pkcs8 -in $< -out $@ \
> -			-topk8 -v2 des-cbc -v2prf hmacWithSHA1 -passout pass:abc
> +			-topk8 -v2 des-cbc -v2prf hmacWithSHA1 -passout pass:abc \
> +			-provider legacy -provider default
>
> unit/cert-client-key-pkcs8-v2-des-ede3.pem: unit/cert-client-key-pkcs8.pem
> 	$(AM_V_GEN)openssl pkcs8 -in $< -out $@ \
> @@ -575,19 +579,20 @@ unit/cert-entity-pkcs12-nomac.p12: unit/cert-entity=
-int-key.pem unit/cert-entity
> 	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int=
.pem -out $@ -export -passout pass:abc -nomac # defaut ciphers
>
> unit/cert-entity-pkcs12-rc2-sha1.p12: unit/cert-entity-int-key.pem unit/c=
ert-entity-int.pem unit/cert-chain.pem
> -	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-in=
t.pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pa=
ss:abc -certpbe PBE-SHA1-RC2-40 -keypbe PBE-SHA1-RC2-128 -macalg sha1
> +	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-in=
t.pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pa=
ss:abc -certpbe PBE-SHA1-RC2-40 -keypbe PBE-SHA1-RC2-128 -macalg sha1 -prov=
ider legacy -provider default
>
> unit/cert-entity-pkcs12-des-sha256.p12: unit/cert-entity-int-key.pem unit=
/cert-entity-int.pem unit/cert-chain.pem
> 	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int=
.pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pas=
s:abc -certpbe PBE-SHA1-3DES -keypbe PBE-SHA1-2DES -macalg sha256
>
> unit/cert-entity-pkcs12-rc4-sha384.p12: unit/cert-entity-int-key.pem unit=
/cert-entity-int.pem unit/cert-chain.pem
> -	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-in=
t.pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pa=
ss:abc -certpbe PBE-SHA1-RC4-128 -keypbe PBE-SHA1-RC2-40 -macalg sha384
> +	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-in=
t.pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pa=
ss:abc -certpbe PBE-SHA1-RC4-128 -keypbe PBE-SHA1-RC2-40 -macalg sha384 -pr=
ovider legacy -provider default
>
> unit/cert-entity-pkcs12-pkcs5-sha512.p12: unit/cert-entity-int-key.pem un=
it/cert-entity-int.pem unit/cert-chain.pem
> -	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-in=
t.pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pa=
ss:abc -certpbe des-cbc -keypbe des-cbc -macalg sha512
> +	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-in=
t.pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pa=
ss:abc -certpbe des-cbc -keypbe des-cbc -macalg sha512 -provider legacy -pr=
ovider default
>
> unit/cert-entity-combined.pem: unit/cert-entity-pkcs12-rc2-sha1.p12
> -	$(AM_V_GEN)openssl pkcs12 -in $< -out $@ -passin pass:abc -passout pass=
:abc
> +	$(AM_V_GEN)openssl pkcs12 -in $< -out $@ -passin pass:abc -passout pass=
:abc \
> +			 -provider legacy -provider default
>
> unit/key-plaintext.h: unit/plaintext.txt
> 	$(AM_V_GEN)xxd -i < $< > $@
> -- =

> 2.36.1
>
>

--
Mat Martineau
Intel
--===============0551399407236989832==--

