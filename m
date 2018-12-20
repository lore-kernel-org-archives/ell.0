Content-Type: multipart/mixed; boundary="===============8532946470200003268=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 5/9] tls: Implement l_tls_set_version_range
Date: Thu, 20 Dec 2018 03:35:08 +0100
Message-ID: <CAOq732KOtHR+gnZaUNT+4z7Ve3fa7tzFn2-pKwVAKzoUe_Ud_w@mail.gmail.com>
In-Reply-To: <52434d94-e953-e55b-1568-23c128da963a@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8532946470200003268==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

HI Denis,

On Wed, 19 Dec 2018 at 17:22, Denis Kenzior <denkenz@gmail.com> wrote:
> On 12/18/2018 06:57 PM, Andrew Zaborowski wrote:
> > Allow user to set custom min and max TLS version limits, this can be
> > used to ensure we comply with a specific security profile.
> > ---
> >   ell/ell.sym       |  1 +
> >   ell/tls-private.h | 10 ++-----
> >   ell/tls-record.c  |  4 +--
> >   ell/tls.c         | 74 +++++++++++++++++++++++++++++++++++++----------
> >   ell/tls.h         | 11 ++++++-
> >   5 files changed, 73 insertions(+), 27 deletions(-)
> >
>
> <snip>
>
> > diff --git a/ell/tls-private.h b/ell/tls-private.h
> > index 0908b9c..e450ac2 100644
> > --- a/ell/tls-private.h
> > +++ b/ell/tls-private.h
> > @@ -20,14 +20,7 @@
> >    *
> >    */
> >
> > -enum l_tls_version {
> > -     L_TLS_V10 =3D ((3 << 8) | 1),
> > -     L_TLS_V11 =3D ((3 << 8) | 2),
> > -     L_TLS_V12 =3D ((3 << 8) | 3),
> > -     L_TLS_V13 =3D ((3 << 8) | 4),     /* Not supported */
> > -};
> > -
> > -#define TLS_VERSION  L_TLS_V12
> > +#define TLS_MAX_VERSION      L_TLS_V12
> >   #define TLS_MIN_VERSION     L_TLS_V10
>
> So we generally discourage #defines that are used only once.  Are you
> planning to use this outside l_tls_new?  This may also be relevant for
> TLS_MIN_VERSION since you are getting rid of many of its usages as well.

Other than l_tls_set_version_range no (although for 1.3 we potentially
may need to move it back to tls-private.h because version negotiation
happens in an extension)

>
> >
> >   enum tls_cipher_type {
> > @@ -147,6 +140,7 @@ struct l_tls {
> >       l_tls_debug_cb_t debug_handler;
> >       l_tls_destroy_cb_t debug_destroy;
> >       void *debug_data;
> > +     enum l_tls_version min_version, max_version;
>
> Separate lines please :)

Okay.

>
> >
> >       struct l_queue *ca_certs;
> >       struct l_certchain *cert;
>
> <snip>
>
> > @@ -393,7 +393,7 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
> >
> >       if ((tls->negotiated_version && tls->negotiated_version !=3D vers=
ion) ||
> >                       (!tls->negotiated_version &&
> > -                      tls->record_buf[1] !=3D 0x03 /* Appending E.1 */=
)) {
> > +                      tls->record_buf[1] !=3D 0x03 /* Appendix E.1 */)=
) {
>
> Separate patch please
>
> >               TLS_DISCONNECT(TLS_ALERT_PROTOCOL_VERSION, 0,
> >                               "Record version mismatch: %02x", version);
> >               return false;
>
> <snip>
>
> > @@ -589,10 +603,13 @@ static bool tls_cipher_suite_is_compatible(struct=
 l_tls *tls,
> >               return false;
> >       }
> >
> > -     if ((tls->negotiated_version && tls->negotiated_version < L_TLS_V=
12 &&
> > -                     (!l_checksum_is_supported(L_CHECKSUM_MD5, true) ||
> > -                      !l_checksum_is_supported(L_CHECKSUM_SHA1, true))=
) ||
> > -                     (tls->negotiated_version >=3D L_TLS_V12 &&
> > +     if (
> > +                     ((tls->max_version < L_TLS_V12 ||
> > +                       (negotiated && negotiated < L_TLS_V12)) &&
>
> So the previous version of this only looked at the negotiated version,
> but this one also looks at the max version.  Should this function take
> the TLS version as an argument and let the caller figure out the policy?

So the idea here is that we can eliminate some suites before
negotiated_version is set but we're dealing with an interval so we
have a min and a max.  I guess we can simplify it locally (so as not
to complicate it for the callers) by setting min and max to either
tls->min/max_version or tls->negotiated_version.

>
> > +                      (!l_checksum_is_supported(L_CHECKSUM_MD5, true) =
||
> > +                       !l_checksum_is_supported(L_CHECKSUM_SHA1, true)=
)) ||
> > +                     ((tls->min_version >=3D L_TLS_V12 ||
> > +                       negotiated >=3D L_TLS_V12) &&
> >                        !l_checksum_is_supported(
> >                                       suite->prf_hmac !=3D L_CHECKSUM_N=
ONE ?
> >                                       suite->prf_hmac : L_CHECKSUM_SHA2=
56,
>
> Why is this indented so far to the right?

In an attempt to comply with coding-style.txt :) I'm going with the
editor's auto indent for the other lines where we have no specific
rules.

> But really, can we put this
> into a separate function and make this a bit more readable, maybe with a
> few comments?

Ok.

>
> > @@ -2751,6 +2781,18 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls=
 *tls, const char *cert_path,
> >       return true;
> >   }
> >
> > +LIB_EXPORT void l_tls_set_version_range(struct l_tls *tls,
> > +                                     uint16_t min_version,
> > +                                     uint16_t max_version)
>
> Why uint16?
>
> > +{
> > +     tls->min_version =3D
> > +             (min_version && min_version > TLS_MIN_VERSION) ?
> > +             min_version : TLS_MIN_VERSION;
> > +     tls->max_version =3D
> > +             (max_version && max_version < TLS_MAX_VERSION) ?
> > +             max_version : TLS_MAX_VERSION;
>
> Yikes.  Again, why not use enums here and skip these checks?  If someone
> wants to pass arbitrary int values to this function, that is their proble=
m.

Oops so I was determined to use enum l_tls_version for the parameters
but somehow screwed up a rebase I think.  Still I think these checks
are useful and we should accept possible other values.

With both l_tls_set_version_range and l_tls_set_cipher_suites I think
it's important that the caller does not have to worry about which
versions and suites we actually support internally.  They should be
able to say "for this instance the policy is ok with anything from SSL
2.0 to TLS 1.1 and such and such cipher suites" without diving into
our .c files.  On the other hand our code can trivially limit this to
the features that are actually usable so we don't end up negotiating a
version we don't support.

Best regards

--===============8532946470200003268==--

