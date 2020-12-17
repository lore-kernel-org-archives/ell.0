Content-Type: multipart/mixed; boundary="===============7646599354795521350=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 2/4] pem: Add pem_write_certificate_chain
Date: Thu, 17 Dec 2020 22:19:27 +0100
Message-ID: <CAOq732KosmVovMf9d4VxTf-=q9=R8FytjQvWbaoDdM0dnEAs7g@mail.gmail.com>
In-Reply-To: <719043d6-db51-5e4f-5ce2-993315d59f2c@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7646599354795521350==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 17 Dec 2020 at 21:08, Denis Kenzior <denkenz@gmail.com> wrote:
> On 12/16/20 7:32 PM, Andrew Zaborowski wrote:
> > @@ -45,6 +45,7 @@
> >   #include "cipher.h"
> >   #include "cert-private.h"
> >   #include "missing.h"
> > +#include "io.h"
>
> Is this really needed?

Oops, I forgot to clean up after refactoring this a few times.

>
> >   #include "pem-private.h"
> >
> >   #define PEM_START_BOUNDARY  "-----BEGIN "
> > @@ -364,6 +365,55 @@ LIB_EXPORT struct l_certchain *l_pem_load_certific=
ate_chain(
> >       return pem_list_to_chain(list);
> >   }
> >
> > +static bool pem_write_one_cert(struct l_cert *cert, void *user_data)
> > +{
> > +     int *fd =3D user_data;
> > +     const uint8_t *der;
> > +     size_t der_len;
> > +     struct iovec iov[3];
> > +     ssize_t r;
> > +
> > +     der =3D l_cert_get_der_data(cert, &der_len);
> > +
> > +     iov[0].iov_base =3D "-----BEGIN CERTIFICATE-----\n";
> > +     iov[0].iov_len =3D strlen(iov[0].iov_base);
> > +     iov[1].iov_base =3D l_base64_encode(der, der_len, 64, &iov[1].iov=
_len);
>
> Is this being leaked?

Yep.

>
> > +     iov[2].iov_base =3D "\n-----END CERTIFICATE-----\n";
> > +     iov[2].iov_len =3D strlen(iov[2].iov_base);
> > +     r =3D L_TFR(writev(*fd, iov, 3));
> > +
> > +     if (r =3D=3D (ssize_t) (iov[0].iov_len + iov[1].iov_len + iov[2].=
iov_len))
> > +             return false;
> > +
> > +     close(*fd);
>
> Maybe the close should be in pem_write_certificate_chain()?

Ok.

Best regards
--===============7646599354795521350==--

