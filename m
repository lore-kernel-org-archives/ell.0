Content-Type: multipart/mixed; boundary="===============0888360436029187881=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 06/13] pkcs5: Add the PKCS#12 KDF
Date: Fri, 11 Dec 2020 11:34:38 +0100
Message-ID: <CAOq732J+dz7SEh9sV9x=SZE0ii1KGAWBYvZj2_RGMcyp1BqZTw@mail.gmail.com>
In-Reply-To: <183e3ea3-5ed1-4b15-3030-89a53d3eb4d5@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0888360436029187881==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Thu, 10 Dec 2020 at 23:51, Denis Kenzior <denkenz@gmail.com> wrote:
> On 12/10/20 1:31 PM, Andrew Zaborowski wrote:
> > Add the key derivation algorithm used with PKCS#12 to pkcs5.c so that it
> > can be found together with the two PKCS#5 KDFs, and so that it can also
> > be used when parsing of the PKCS#12 AlgorithmIdentifiers in the next
> > commit.  This KDF is not recommended for new uses.
> > ---
> >   ell/pkcs5-private.h |  12 ++++
> >   ell/pkcs5.c         | 146 ++++++++++++++++++++++++++++++++++++++++++++
> >   2 files changed, 158 insertions(+)
> >
>
> <snip>
>
> > +static bool utf8_to_bmpstring(const char *utf, uint8_t *out_buf,
> > +                             unsigned int *out_len)
> > +{
> > +     unsigned int n;
> > +     int utflen;
> > +     wchar_t cp;
> > +     uint16_t *ptr =3D (uint16_t *) out_buf;
> > +
> > +     for (n =3D strlen(utf); n; n -=3D utflen, utf +=3D utflen) {
> > +             if ((utflen =3D l_utf8_get_codepoint(utf, n, &cp)) <=3D 0=
 ||
> > +                             cp > 0xffff)
> > +                     return false;
>
> So is this just a UCS2BE conversion?  If so, then using l_utf8_to_ucs2be =
might
> be clearer.

Basically yes.  But with l_utf8_to_ucs2be this will look something like:

  uint8_t *usc2;

  if (!l_utf8_validate(utf))
    return false;

  ucs2 =3D l_utf8_to_ucs2be(utf, out_len);
  if (!str)
    return false;

  memcpy(out_buf, ucs2, *out_len);
  explicit_bzero(ucs2);
  l_free(ucs2);

I can do that but it seems we're doing less work without using
l_utf8_to_ucs2be here.

Best regards
--===============0888360436029187881==--

