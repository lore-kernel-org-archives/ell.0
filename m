Content-Type: multipart/mixed; boundary="===============0287320868381510557=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/9] tls: Drop local code to add hash OID, let kernel do it
Date: Wed, 28 Nov 2018 13:14:46 +0100
Message-ID: <CAOq732LDz9zo=5KHKAgq+rDn4eLxjkCbhnX9_9_9VXz5CrS4Uw@mail.gmail.com>
In-Reply-To: <0820f66c-2460-2cc0-2697-c0b6fed96dad@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0287320868381510557==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Wed, 28 Nov 2018 at 04:45, Denis Kenzior <denkenz@gmail.com> wrote:
> On 11/27/2018 08:38 PM, Andrew Zaborowski wrote:
> > Drop tls.c code to build the PKCS#1 DigestInfo structure which basically
> > consisted of prepending the signature hash algorithm's OID to the hash.
> > Let the key API do it by setting the hash type in the l_key_sign and
> > l_key_verify calls.  Slightly simplify the tls_rsa_sign and
> > tls_rsa_verify code while doing this.
> > ---
> >   ell/tls.c | 164 ++++++++++++++++++------------------------------------
> >   1 file changed, 53 insertions(+), 111 deletions(-)
> >
>
> <snip>
>
> > @@ -1238,13 +1179,11 @@ static bool tls_send_rsa_client_key_xchg(struct=
 l_tls *tls)
> >   static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t *out, size_t l=
en,
> >                               tls_get_hash_t get_hash)
> >   {
> > -     ssize_t result;
> > -     const struct tls_hash_algorithm *hash_type;
> > -     uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
> > +     ssize_t result =3D -EMSGSIZE;
> > +     enum l_checksum_type sign_checksum_type;
> >       uint8_t sign_input[HANDSHAKE_HASH_MAX_SIZE * 2 + 32];
>
> Does this need to be updated?

It could be reduced to max(HANDSHAKE_HASH_MAX_SIZE, 36) although
HANDSHAKE_HASH_MAX_SIZE is now bigger than 36... for simplicity let's
do HANDSHAKE_HASH_MAX_SIZE + 36.

>
> >       size_t sign_input_len;
> > -     bool prepend_hash_type =3D false;
> > -     size_t expected_bytes;
> > +     uint8_t *ptr =3D out;
> >
> >       if (!tls->priv_key || !tls->priv_key_size) {
> >               TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CE=
RT,
> > @@ -1253,54 +1192,49 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, =
uint8_t *out, size_t len,
> >               return -ENOKEY;
> >       }
> >
> > -     expected_bytes =3D tls->priv_key_size + 2;
> > -
> >       if (tls->negotiated_version >=3D TLS_V12) {
> > -             hash_type =3D &tls_handshake_hash_data[tls->signature_has=
h];
> > -             get_hash(tls, hash_type->tls_id, hash, NULL, NULL);
> > +             const struct tls_hash_algorithm *hash_type =3D
> > +                     hash_type =3D &tls_handshake_hash_data[tls->signa=
ture_hash];
>
> What is going on here?

Oooh I don't know... I'll fix this.

>
> > +
> > +             get_hash(tls, hash_type->tls_id, sign_input, NULL, NULL);
> > +             sign_checksum_type =3D hash_type->l_id;
> > +             sign_input_len =3D hash_type->length;
> >
> > -             pkcs1_write_digest_info(hash_type->l_id,
> > -                                     sign_input, &sign_input_len,
> > -                                     hash, hash_type->length);
> > +             if (len < 2)
> > +                     goto error;
>
> Why do we check this after generating the signature?

Will move it sooner.

Best regards

--===============0287320868381510557==--

