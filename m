Content-Type: multipart/mixed; boundary="===============4041790508716814174=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 2/4] unit: Update expected peer identity strings in TLS
Date: Thu, 08 Aug 2019 01:30:12 +0200
Message-ID: <CAOq732LiDAS5zS5T2S9v-dZc_rKJaL3QPDhWCminDZu_Gq9qnQ@mail.gmail.com>
In-Reply-To: <d3d9ba83-a6e9-3b65-4dad-d04e7f3e3e3a@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4041790508716814174==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Thu, 8 Aug 2019 at 00:53, Denis Kenzior <denkenz@gmail.com> wrote:
>
> Hi Andrew,
>
> On 8/6/19 8:45 AM, Andrew Zaborowski wrote:
> > ---
> >   unit/test-tls.c | 33 ++++++++++++++++++++++-----------
> >   1 file changed, 22 insertions(+), 11 deletions(-)
> >
>
> Applied, but any chance we can get some spoofed certs for negative testin=
g?

We've got one negative test for the subject matching in the iwd
patches (which I still need to respin I think) but we don't need a
special cert for that we just use a wrong subject_match string. And I
think we've got some test cases in ell where the actual RSA crypto is
supposed to fail if we're verifying against a wrong cert.

>
> > diff --git a/unit/test-tls.c b/unit/test-tls.c
> > index 03c5370..d701f42 100644
> > --- a/unit/test-tls.c
> > +++ b/unit/test-tls.c
> > @@ -326,7 +326,8 @@ static const struct tls_conn_test tls_conn_test_ser=
ver_auth =3D {
> >       .server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
> >       .server_expect_identity =3D NULL,
> >       .client_ca_cert_path =3D CERTDIR "cert-ca.pem",
> > -     .client_expect_identity =3D "Foo Example Organization",
> > +     .client_expect_identity =3D "/O=3DFoo Example Organization"
> > +             "/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail=
.example",
>
> Also, what happens if the strings contain a '/' character? Or is that
> not possible?

So apparently openssl has some \ unescaping support for these strings
when you generate the certificate and probably the characters are
escaped again when you extract this string from a cert.  We could
replicate this but in terms of security I think it doesn't add
anything, users will just need to remember to not escape the
characters in the iwd configs.

Best regards

--===============4041790508716814174==--

