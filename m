Content-Type: multipart/mixed; boundary="===============0434997400216880871=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 5/8] cert: Add l_cert_load_container_file
Date: Sat, 09 Jan 2021 01:51:03 +0100
Message-ID: <CAOq732+A=Dycd6uzhLpcYWA9ZatwSSh7PodmZ8xz0Jmm0xKzfg@mail.gmail.com>
In-Reply-To: <6386fded-e857-d1c4-0765-b8d41781fda7@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0434997400216880871==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 8 Jan 2021 at 05:37, Denis Kenzior <denkenz@gmail.com> wrote:
>
> Hi Andrew,
>
> On 1/6/21 1:54 PM, Andrew Zaborowski wrote:
> > + * Currently supported are:
> > + *  PEM X.509 certificates
> > + *  PEM PKCS#8 encrypted and unenecrypted private keys
> > + *  PEM legacy PKCS#1 encrypted and unenecrypted private keys
>
> I fixed 'unenerypted' -> 'unencrypted' in these two lines
>
> > +                     privkey =3D pem_load_private_key(der, der_len, ty=
pe_label,
> > +                                                     password, headers,
> > +                                                     &encrypted);
>
> Remind me again why pem_load_private_key frees all the input data?

Within pem.c this avoided some duplication in the callers, but...

> This makes
> things really asymmetrical in this function.

It does, let me know if you prefer it fixed.

Best regards
--===============0434997400216880871==--

