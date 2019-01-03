Content-Type: multipart/mixed; boundary="===============0865424135802257517=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 14/17] tls: DHE_RSA key exchange implementation client side
Date: Thu, 03 Jan 2019 12:36:09 +0100
Message-ID: <CAOq732Lnp2zD5WuMSP-j2mZ1fjeRU2RVGgXRP8RAkZAcYxFv5A@mail.gmail.com>
In-Reply-To: <00db914f-560c-1d08-64da-de3ba6ffb47e@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0865424135802257517==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 3 Jan 2019 at 04:33, Denis Kenzior <denkenz@gmail.com> wrote:
> >> Generating a whole new random number is really a bad way of doing
> >> things.  The entropy pool is a very limited resource, so don't abuse i=
t.
> >>    A much easier way would be to simply set the most-significant-byte =
to
> >> 0.
> >
> > It's a pattern we use in the ecdh code (where the group order is only
> > ~1/2 of the number space -- can improved by switching from the "Black
> > box" method to the "Deterministic" method iirc) and in iwd so we'd
>
> Yeah we might need to fix that, but there might not be an easy way as
> opposed to here.
>
> > probably need to change it everywhere.  But it seems that every way to
> > "fix" the number instead of generating a new one affects the
> > distribution making the algorithm weaker.  If that's ok then yes, we
> > can simply force the top bits of the private value do "0" (down to the
> > first "1" bit of the prime).
>
> This would be fine with all DH groups from RFC 3526.  If TLS uses a
> different set of primes, then setting the upper MSB bits to 0 might be
> okay.

PKCS #3 also mentions generating a priv key between 2^(n-1) and
(2^n)-1, meaning forcing an MSB to 1, which accounts for both the min
and max checks so I think I'm going to do that if we don't care about
uniform distribution.

> If you're worried about this, then perhaps simply re-generating
> the upper N MSB bytes is another solution.

Unfortunately this still would skew the distribution a little.

> Might want to check what
> other implementations do.
>
> >>> +static void tls_handle_dhe_server_key_xchg(struct l_tls *tls,
> >>> +                                             const uint8_t *buf, siz=
e_t len)
> >>> +{
> >>> +     struct tls_dhe_params *params;
> >>> +
> >>> +     params =3D l_new(struct tls_dhe_params, 1);
> >>> +     tls->pending.key_xchg_params =3D params;
> >>
> >> Why do this assignment here?
> >
> > The reason is so that in case of error tls_reset_handshake will free
> > this and we don't have to worry about it, I can add a comment.
>
> Gah, that's really not obvious.  A comment is needed, but it might be
> better to have decode_error label take care of this instead.
>
> >>> +     /*
> >>> +      * RFC 7919 Section 3.0:
> >>> +      * "the client MUST verify that dh_Ys is in the range
> >>> +      * 1 < dh_Ys < dh_p - 1.  If dh_Ys is not in this range, the cl=
ient
> >>> +      * MUST terminate the connection with a fatal handshake_failure=
(40)
> >>> +      * alert."
> >>> +      */
> >>> +     if (params->public_len > params->prime_len ||
> >>> +                     !l_key_validate_dh_payload(params->public_buf,
> >>> +                                                     params->public_=
len,
> >>> +                                                     params->prime_b=
uf,
> >>> +                                                     params->prime_l=
en)) {
> >>
> >> So can we rely on the kernel to do this part for us?
> >
> > Apparently we can't without modifying security/keys/dh.c and our keys
> > code.  The keyctl operation is too smart and assumes
> > generate_public_key and generate_shared_secret are the same operation,
> > so when crypto/dh.c receives the parameters it always thinks it's
> > dealing with a generator and the private value, instead of private and
> > public values.  So it never runs the public value validation.
> > dh_is_pubkey_valid also has one minor unimplemented feature.
>
> That's a bug in the kernel then.  We should fix that.

As far as I understand we'd also need to fix the API then because
keyctl has no way to know which operation we're requesting.  I.e.
split KEYCTL_DH_COMPUTE into two operations or add a field to struct
keyctl_dh_params.  We could also force the check for both private and
public values but others might argue the requirements for private
values may be less strict (in RFC7919 they're the same though, iirc),
or the min and max may have been checked already.

Best regards

--===============0865424135802257517==--

