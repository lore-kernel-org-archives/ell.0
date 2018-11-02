Content-Type: multipart/mixed; boundary="===============5425656902043117586=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 04/11] pem: Add l_pem_load_certificate_list utility
Date: Fri, 02 Nov 2018 08:32:07 +0100
Message-ID: <CAOq732JHSGgvP2UOHqn8wQwd95=aZhf8UMf-t6aA5XPK5U7ttg@mail.gmail.com>
In-Reply-To: <ab97fe67-0aab-e098-1e29-f5b5c0b2ad7c@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5425656902043117586==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Thu, 1 Nov 2018 at 20:40, Denis Kenzior <denkenz@gmail.com> wrote:
> On 11/01/2018 06:54 AM, Andrew Zaborowski wrote:
> > +static void pem_element_free(void *data)
> > +{
> > +     struct l_pem_list_element *element =3D data;
> > +
> > +     l_free(element->content);
> > +     l_free(element);
> > +}
>
> So I see that we duplicate this free function a bunch of times in the
> later commits in this series.  Perhaps we should bite the bullet and
> make l_pem an actual first class object with some getters and a destructo=
r.

So an l_pem would represent a single '----- BEGIN' to '----- END'
fragment of a PEM file?  I'd the rather call it an l_pem_element or
similar, and make l_pem_element_free() public, and could also make the
struct non-public and add accessors but that doesn't help much I
think.

However what I'd really prefer instead is to add back the l_cert type,
which could be a first class object with a lot of functionality and
tls.c would become much shorter.  It could hide the l_key usage (but
could have an accessor for the public key in the certificate) and also
could have l_cert_new_from_pem(), or alternatively pem.c could rather
have a l_pem_load_cert() returning l_cert objects.

Similarly maybe our current l_pem_load_private_key() could be changed
to return an l_key directly.

>
> E.g.
>
> const void *l_pem_get_content(struct l_pem *);
> size_t l_pem_get_content_length(struct l_pem *);
>
> void l_pem_free(struct l_pem *);
>
> and possibly:
> enum l_pem_type l_pem_get_type(struct l_pem *);
>
> > +
> > +LIB_EXPORT struct l_queue *l_pem_load_certificate_list(const char *fil=
ename)
> > +{
> > +     int fd;
> > +     struct stat st;
> > +     uint8_t *data;
> > +     size_t start =3D 0;
> > +     struct l_queue *result =3D NULL;
> > +
> > +     fd =3D open(filename, O_RDONLY);
> > +     if (fd < 0)
> > +             return NULL;
> > +
> > +     if (fstat(fd, &st) < 0) {
> > +             close(fd);
> > +
> > +             return NULL;
> > +     }
> > +
> > +     data =3D mmap(NULL, st.st_size, PROT_READ, MAP_SHARED, fd, 0);
> > +     if (data =3D=3D MAP_FAILED) {
> > +             close(fd);
> > +
> > +             return NULL;
> > +     }
> > +
> > +     while (1) {
> > +             uint8_t *certificate;
> > +             size_t len;
> > +             char *label;
> > +             struct l_pem_list_element *element;
> > +             const uint8_t *end;
> > +
> > +             certificate =3D pem_load_buffer(data + start, st.st_size =
- start, 0,
> > +                                             &label, &len, &end);
> > +             if (!certificate)
> > +                     goto done;
>
> I'm not so sure about this.  pem_load_buffer can fail for base64 decode
> failure reasons.  So I wouldn't think that you can assume that a failure
> means EOF + success.

I was thinking about the case of having 5 certificates already loaded
and the last one failing -- in this case we might just want to return
the 5 that parsed ok but I can add better error checking.

>
> > +
> > +             if (strcmp(label, "CERTIFICATE")) {
> > +                     l_free(certificate);
> > +                     break;
> > +             }
> > +
> > +             l_free(label);
> > +             element =3D l_malloc(sizeof(struct l_pem_list_element));
>
> l_new?
>
> > +             element->content =3D certificate;
> > +             element->len =3D len;
> > +
> > +             if (!result)
> > +                     result =3D l_queue_new();
> > +
> > +             l_queue_push_tail(result, element);
> > +             start =3D end - data;
>
> You really need serious mental gymnastics to get this part.  Can't we
> just have a curpos variable or something?

Ok, if I rename "start" to "curpos" and "end" to "newendpos" or
similar I think it should be pretty clear.

>
> > +     }
> > +
> > +     /* Error occured */
> > +     l_queue_destroy(result, pem_element_free);
> > +     result =3D NULL;
> > +
> > +done:
> > +     munmap(data, st.st_size);
> > +     close(fd);
> > +
> > +     return result;
> > +}
> > +
> >   /**
> >    * l_pem_load_private_key
> >    * @filename: path string to the PEM file to load
> > diff --git a/ell/pem.h b/ell/pem.h
> > index 93282a3..9cead5c 100644
> > --- a/ell/pem.h
> > +++ b/ell/pem.h
> > @@ -27,12 +27,20 @@
> >   extern "C" {
> >   #endif
> >
> > +struct l_queue;
> > +
> > +struct l_pem_list_element {
> > +     uint8_t *content;
> > +     size_t len;
> > +};
> > +
>
> As mentioned above, this probably should be a first class opaque data now.
>
> >   uint8_t *l_pem_load_buffer(const uint8_t *buf, size_t buf_len,
> >                               int index, char **type_label, size_t *out=
_len);
>
> and we can change this to
>
> struct l_pem *l_pem_load_buffer(buf, buf_len, index, char **);
>
> I also really wonder if we want to take this function out of the public
> API, though we do need to add support for TPM 1.2 certificates as well.

This could be done separately but I think having a public function to
just get the first PEM fragment in a file is practical (saves you from
loading all of them and freeing all but the first struct.)

Best regards

--===============5425656902043117586==--

