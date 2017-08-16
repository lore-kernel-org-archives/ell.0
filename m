Content-Type: multipart/mixed; boundary="===============1435177950489599261=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH] unit: Generate encrypted keys in gencerts.sh
Date: Wed, 16 Aug 2017 10:21:11 -0700
Message-ID: <alpine.OSX.2.21.1708161016010.21613@mjmartin-mac01.sea.intel.com>
In-Reply-To: <20170816170822.4680-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1435177950489599261==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


Hi Andrew -

On Wed, 16 Aug 2017, Andrew Zaborowski wrote:

> ---
> unit/gencerts.sh | 5 +++++
> 1 file changed, 5 insertions(+)
>
> diff --git a/unit/gencerts.sh b/unit/gencerts.sh
> index 790c715..419afa8 100755
> --- a/unit/gencerts.sh
> +++ b/unit/gencerts.sh
> @@ -17,6 +17,11 @@ openssl pkcs8 -topk8 -nocrypt -in cert-client-key.pem =
-out cert-client-key-pkcs8
> openssl req -new -extensions cert_ext -config ./gencerts.cnf -subj '/O=3D=
Bar Example Organization/CN=3DBar Example Organization/emailAddress=3Dbar(a=
)mail.example' -key cert-client-key.pem -out cert-client.csr
> openssl x509 -req -extensions cert_ext -extfile ./gencerts.cnf -in cert-c=
lient.csr -CA cert-ca.pem -CAkey cert-ca-key.pem -CAcreateserial -sha256 -d=
ays 10000 -out cert-client.pem
> openssl verify -CAfile cert-ca.pem cert-client.pem
> +openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-md5-des=
.pem -topk8 -passout pass:abc
> +openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-des.=
pem -topk8 -v2 des-cbc -passout pass:abc
> +openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-des-=
ede3.pem -topk8 -v2 des-ede3-cbc -passout pass:abc
> +openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-aes1=
28.pem -topk8 -v2 aes128 -passout pass:abc
> +openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-aes2=
56.pem -topk8 -v2 aes256 -passout pass:abc
>

I was looking at cert generation yesterday, and found that the above =

commands did not work with openssl 1.1. I believe these work with both 1.0 =

and 1.1:

openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-md5-des.pe=
m -topk8 -v1 PBE-MD5-DES -passout pass:abc
openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-des.pem=
 -topk8 -v2 des-cbc -v2prf hmacWithSHA1 -passout pass:abc
openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-des-ede=
3.pem -topk8 -v2 des-ede3-cbc -v2prf hmacWithSHA1 -passout pass:abc
openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-aes128.=
pem -topk8 -v2 aes128 -v2prf hmacWithSHA1 -passout pass:abc
openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-aes256.=
pem -topk8 -v2 aes256 -v2prf hmacWithSHA1 -passout pass:abc

I had to add "-v2prf hmacWithSHA1" to get the unit tests to pass when the =

certs are created with openssl 1.1. The default changed from hmacWithSHA1 =

in 1.0 to hmacWithSHA256 in 1.1. Would you expect the tests to pass either =

way?

Regards,

--
Mat Martineau
Intel OTC

--===============1435177950489599261==--

