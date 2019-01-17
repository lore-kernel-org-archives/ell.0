Content-Type: multipart/mixed; boundary="===============7523107849739389151=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/2] tls: Pass optional data parameter to sign/verify
 callbacks
Date: Thu, 17 Jan 2019 22:37:39 +0100
Message-ID: <CAOq732K7hCcahLOhJHaKjLMx9RpeJhduWQBdYwDLoBQeN4kijQ@mail.gmail.com>
In-Reply-To: <5e13d457-a422-2ab6-7cec-00e54eedc520@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7523107849739389151==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 17 Jan 2019 at 18:03, Denis Kenzior <denkenz@gmail.com> wrote:
> On 01/11/2019 07:14 AM, Andrew Zaborowski wrote:
> > This is to illustrate the possible cleanup in DHE to avoid putting a
> > pointer to a stack structure in the handshake state.
> > ---
> >   ell/tls-private.h |   3 +
> >   ell/tls-suites.c  | 198 ++++++++++++++++++++--------------------------
> >   ell/tls.c         |   6 +-
> >   3 files changed, 91 insertions(+), 116 deletions(-)
>
> So I like this approach way more than the current situation.
>
> >
> > diff --git a/ell/tls-private.h b/ell/tls-private.h
> > index c82a4d5..134203f 100644
> > --- a/ell/tls-private.h
> > +++ b/ell/tls-private.h
> > @@ -59,6 +59,7 @@ struct tls_hash_algorithm {
> >   extern const struct tls_hash_algorithm tls_handshake_hash_data[];
> >
> >   typedef bool (*tls_get_hash_t)(struct l_tls *tls, uint8_t tls_id,
> > +                             const uint8_t *data, size_t data_len,
> >                               uint8_t *out, size_t *len,
>
> Can we call this out_len to make this clearer?

Ok.

>
> >                               enum l_checksum_type *type);
>
> So one question I have is whether this type argument is needed.  It
> seems like you only ever use it in 1 place, and pass in NULL everywhere
> else.
>
> You could simply add a convenience method to lookup l_checksum from a
> tls_id, no?

Yeah, I was also wondering why I wasn't doing the mapping to the
l_checksum_type inside the caller, I'm going to re-check this and
possibly convert the signature.

>
> >
> > @@ -80,8 +81,10 @@ struct tls_key_exchange_algorithm {
> >                                               const uint8_t *buf, size_=
t len);
> >
> >       ssize_t (*sign)(struct l_tls *tls, uint8_t *out, size_t len,
>
> Can we name this out_len to make it clearer

Ok.

>
> > +                     const uint8_t *data, size_t data_len,
>
> These maybe might need to come after the get_hash, since our general
> pattern is callback, userdata, not the other way around.

Ok I can switch that around although it's a little different from the
other userdata's.

>
> >                       tls_get_hash_t get_hash);
> >       bool (*verify)(struct l_tls *tls, const uint8_t *in, size_t len,
> > +                     const uint8_t *data, size_t data_len,
> >                       tls_get_hash_t get_hash);
>
> As above

Ok.

Best regards

--===============7523107849739389151==--

