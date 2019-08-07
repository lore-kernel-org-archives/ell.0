Content-Type: multipart/mixed; boundary="===============1759196695051650229=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/4] unit: Update expected peer identity strings in TLS
Date: Wed, 07 Aug 2019 17:53:28 -0500
Message-ID: <d3d9ba83-a6e9-3b65-4dad-d04e7f3e3e3a@gmail.com>
In-Reply-To: <20190806134514.6340-2-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1759196695051650229==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 8/6/19 8:45 AM, Andrew Zaborowski wrote:
> ---
>   unit/test-tls.c | 33 ++++++++++++++++++++++-----------
>   1 file changed, 22 insertions(+), 11 deletions(-)
> =


Applied, but any chance we can get some spoofed certs for negative testing?

> diff --git a/unit/test-tls.c b/unit/test-tls.c
> index 03c5370..d701f42 100644
> --- a/unit/test-tls.c
> +++ b/unit/test-tls.c
> @@ -326,7 +326,8 @@ static const struct tls_conn_test tls_conn_test_serve=
r_auth =3D {
>   	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
>   	.server_expect_identity =3D NULL,
>   	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
> -	.client_expect_identity =3D "Foo Example Organization",
> +	.client_expect_identity =3D "/O=3DFoo Example Organization"
> +		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",

Also, what happens if the strings contain a '/' character? Or is that =

not possible?

>   };
>   =

>   static const struct tls_conn_test tls_conn_test_client_auth_attempt =3D=
 {

Regards,
-Denis

--===============1759196695051650229==--

