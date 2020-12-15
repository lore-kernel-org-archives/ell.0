Content-Type: multipart/mixed; boundary="===============4179792977400688087=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 3/5] pem: Add l_pem_load_container_file
Date: Tue, 15 Dec 2020 01:20:56 +0100
Message-ID: <CAOq732KQNQguigcFnte+0PVs5CpKTWNB5Q9cCnAgQ3DtuYqD+Q@mail.gmail.com>
In-Reply-To: <9077c029-6113-84f8-8538-1b3e3237a675@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4179792977400688087==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Tue, 15 Dec 2020 at 00:53, Denis Kenzior <denkenz@gmail.com> wrote:
> On 12/11/20 6:50 PM, Andrew Zaborowski wrote:
> > Add a function that takes a file path and detects what X.509 certificate
> > and/or private key format it uses and parses it accordingly.  This is to
> > make it easier for clients to support multiple file formats, including
> > raw X.509 certificates -- without this they would have to load the
> > contents of the file and call l_cert_new_from_der().
> > l_pem_load_container can also be used instead of
> > l_pem_load_certificate_chain() and l_pem_load_private_key().
> >
> > This function can now load binary certificate files which are not PEM
>
> So this really makes it seem that it shouldn't be in pem.c?
>
> > but there wasn't a better place for it than pem.c.  I guess the name
> > could also be improved to imply that it's for certificate and private
> > key container files, but I couldn't come up with a name that isn't too
> > long.
>
> Ok, nitpicking here, but this reasoning really belongs in the metadata, n=
ot the
> commit description.

Ok, maybe a code comment would have been better (or just omitting
this.)  Anyway..

>
> So P12 files are mostly binary, but can also be PEM encoded, correct?  Sh=
ould we
> put the pkcs12 DER loading into pkcs12.c or so?  We could also consider r=
enaming
> pkcs5.c to pkcs.c since it seems pkcs5.c is becoming a bit of a jumble of=
 pkcs8,
> pkcs5 and pkcs12 bits...

I initially wanted to add it in cert.c, that's why I exposed
pem_key_from_pkcs8_private_key_info() and
pem_key_from_pkcs8_encrypted_private_key_info() in pem-private.h, but
I ended up using them only from within pem.c because cert.c didn't
seem right for private key stuff.  But maybe that is a good idea.

So cert.c could contain the high-level file loading/parsing/decoding,
and then rather than pkcs.c I'd call it cert-crypto.c or similar for
the low-level crypto stuff?

The reasoning is that PKCS defined some of those formats and
algorithms but some of it comes from openssl code, and a lot is really
currently defined by RFCs.  Initially I think each PKCS standard was
republished as an RFC but each of those RFCs has since been obsoleted
by sets of newer RFCs.

>
> Still, I'm really unconvinced that this logically belongs in pem.c.  Besi=
des
> iwd's TLS module, who is going to be using this function?  Maybe this bel=
ongs in
> iwd itself?

I see it more as library code (like gnutls), anyone using TLS will
need certificate loading.  ell's examples/https-* should also be
switched to use this function.

>
> >
> > This function treats PEM files as containers that can have both private
> > keys and certificates at the same time, openssl can parse such files and
> > also produces such files in some situations and they may have some good
> > uses.
> > ---
> >   ell/ell.sym |   1 +
> >   ell/pem.c   | 157 ++++++++++++++++++++++++++++++++++++++++++++++++++--
> >   ell/pem.h   |   5 ++
> >   3 files changed, 158 insertions(+), 5 deletions(-)
> >
> > diff --git a/ell/ell.sym b/ell/ell.sym
> > index d94b585..03c46d0 100644
> > --- a/ell/ell.sym
> > +++ b/ell/ell.sym
> > @@ -415,6 +415,7 @@ global:
> >       l_pem_load_file;
> >       l_pem_load_private_key;
> >       l_pem_load_private_key_from_data;
> > +     l_pem_load_container_file;
> >       /* pkcs5 */
> >       l_pkcs5_pbkdf1;
> >       l_pkcs5_pbkdf2;
> > diff --git a/ell/pem.c b/ell/pem.c
> > index 1b995d5..90d06fb 100644
> > --- a/ell/pem.c
> > +++ b/ell/pem.c
> > @@ -195,7 +195,7 @@ const char *pem_next(const void *buf, size_t buf_le=
n, char **type_label,
> >
> >   static uint8_t *pem_load_buffer(const void *buf, size_t buf_len,
> >                               char **out_type_label, size_t *out_len,
> > -                             char **out_headers)
> > +                             char **out_headers, const char **out_endp)
> >   {
> >       size_t base64_len;
> >       const char *base64;
> > @@ -203,7 +203,7 @@ static uint8_t *pem_load_buffer(const void *buf, si=
ze_t buf_len,
> >       uint8_t *ret;
> >
> >       base64 =3D pem_next(buf, buf_len, &label, &base64_len,
> > -                             NULL, false);
> > +                             out_endp, false);
> >       if (!base64)
> >               return NULL;
> >
> > @@ -262,7 +262,7 @@ static uint8_t *pem_load_buffer(const void *buf, si=
ze_t buf_len,
> >   LIB_EXPORT uint8_t *l_pem_load_buffer(const void *buf, size_t buf_len,
> >                                       char **type_label, size_t *out_le=
n)
> >   {
> > -     return pem_load_buffer(buf, buf_len, type_label, out_len, NULL);
> > +     return pem_load_buffer(buf, buf_len, type_label, out_len, NULL, N=
ULL);
> >   }
> >
> >   struct pem_file_info {
> > @@ -315,7 +315,8 @@ static uint8_t *pem_load_file(const char *filename,=
 char **out_type_label,
> >               return NULL;
> >
> >       result =3D pem_load_buffer(file.data, file.st.st_size,
> > -                                     out_type_label, out_len, out_head=
ers);
> > +                                     out_type_label, out_len, out_head=
ers,
> > +                                     NULL);
> >       pem_file_close(&file);
> >       return result;
> >   }
> > @@ -888,7 +889,7 @@ LIB_EXPORT struct l_key *l_pem_load_private_key_fro=
m_data(const void *buf,
> >       if (encrypted)
> >               *encrypted =3D false;
> >
> > -     content =3D pem_load_buffer(buf, buf_len, &label, &len, &headers);
> > +     content =3D pem_load_buffer(buf, buf_len, &label, &len, &headers,=
 NULL);
> >
> >       if (!content)
> >               return NULL;
> > @@ -933,3 +934,149 @@ LIB_EXPORT struct l_key *l_pem_load_private_key(c=
onst char *filename,
> >       return pem_load_private_key(content, len, label, passphrase, head=
ers,
> >                                       encrypted);
> >   }
> > +
> > +/*
> > + * Look at a file, try to detect which of the few X.509 certificate an=
d/or
> > + * private key container formats it uses and load any certificates in =
it as
> > + * a certificate chain object, and load the first private key as an l_=
key
> > + * object.
> > + *
> > + * Currently supported are:
> > + *  PEM X.509 certificates
> > + *  PEM PKCS#8 encrypted and unenecrypted private keys
> > + *  PEM legacy PKCS#1 encrypted and unenecrypted private keys
> > + *  Raw X.509 certificates (.cer, .der, .crt)
> > + *
> > + * The raw format contains exactly one certificate, PEM and PKCS#12 fi=
les
> > + * can contain any combination of certificates and private keys.
> > + */
> > +LIB_EXPORT void l_pem_load_container_file(const char *filename,
> > +                                     const char *password,
> > +                                     struct l_certchain **out_certchai=
n,
> > +                                     struct l_key **out_privkey,
> > +                                     bool *out_encrypted)
> > +{
> > +     struct pem_file_info file;
> > +     const char *ptr;
> > +     size_t len;
> > +     bool error =3D false;
> > +
> > +     if (out_encrypted)
> > +             *out_encrypted =3D false;
> > +
> > +     if (out_certchain)
> > +             *out_certchain =3D NULL;
> > +
> > +     if (out_privkey)
> > +             *out_privkey =3D NULL;
>
> This kind of goes against our design patterns.  As a rule our functions s=
hould
> not side-effect on failure.

In this case this is how we signal the failure to load any
certificates and private keys, this just replaces the return value
since I needed a python tuple-like type.

So this should be read as something like:

  r =3D (NULL, NULL, false);

>
> > +
> > +     if (unlikely(!filename))
> > +             return;
>
> And failing silently seems wrong as well...?

And this as:

  return r;

I can change the actual return type from void to bool if you prefer.
I'll still need a way to signal whether the failure is due to
encryption.  In the existing API we do this by setting *out_encrypted.

Best regards
--===============4179792977400688087==--

