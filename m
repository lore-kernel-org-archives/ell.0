Content-Type: multipart/mixed; boundary="===============1995389477836966344=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 14/17] tls: DHE_RSA key exchange implementation client side
Date: Thu, 03 Jan 2019 04:03:42 +0100
Message-ID: <CAOq732JaVEhZLkvv7Mhk99DuFUGb6mpXqY9kkArBU4HbbShbig@mail.gmail.com>
In-Reply-To: <8717364a-9053-6bbc-48a3-ce6a17b63d67@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1995389477836966344==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Wed, 2 Jan 2019 at 23:33, Denis Kenzior <denkenz@gmail.com> wrote:
> On 01/01/2019 01:49 PM, Andrew Zaborowski wrote:
> > +static bool tls_create_dhe_keys(struct l_tls *tls)
> > +{
> > +     struct tls_dhe_params *params =3D tls->pending.key_xchg_params;
> > +
> > +     if (!params)
> > +             return false;
> > +
> > +     if (params->prime_buf && !params->prime) {
> > +             params->prime =3D l_key_new(L_KEY_RAW, params->prime_buf,
> > +                                             params->prime_len);
> > +             if (!params->prime) {
> > +                     TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
> > +                                     "l_key_new(prime) failed");
> > +                     return false;
> > +             }
> > +     }
> > +
> > +     if (params->generator_buf && !params->generator) {
> > +             params->generator =3D l_key_new(L_KEY_RAW, params->genera=
tor_buf,
> > +                                             params->generator_len);
> > +             if (!params->generator) {
> > +                     TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
> > +                                     "l_key_new(generator) failed");
> > +                     return false;
> > +             }
> > +     }
> > +
> > +     if (params->private_buf && !params->private) {
> > +             params->private =3D l_key_new(L_KEY_RAW, params->private_=
buf,
> > +                                             params->private_len);
> > +             if (!params->private) {
> > +                     TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
> > +                                     "l_key_new(private) failed");
> > +                     return false;
> > +             }
> > +     }
> > +
> > +     if (params->public_buf && !params->public) {
> > +             params->public =3D l_key_new(L_KEY_RAW, params->public_bu=
f,
> > +                                             params->public_len);
> > +             if (!params->public) {
> > +                     TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
> > +                                     "l_key_new(public) failed");
> > +                     return false;
> > +             }
> > +     }
> > +
> > +     return true;
> > +}
>
> It seems like the intent of this function is to be called more than
> once, piecemeal creating the l_key objects.  Why?  That type of pattern
> isn't terribly readable / maintainable.

I guess the intent is to simplify error handling in the callers.  I
can perhaps split this in 4 separate functions, to avoid inlining all
the l_key_new and TLS_DISCONNECT calls.

>
> > +
> > +static bool tls_generate_dhe_private(struct l_tls *tls, uint8_t *buf, =
size_t len)
> > +{
> > +     struct tls_dhe_params *params =3D tls->pending.key_xchg_params;
> > +
> > +     do {
> > +             unsigned int written =3D 0;
> > +
> > +             /* Leading zeros in the private value are fine */
> > +
> > +             do {
> > +                     size_t chunk_len =3D
> > +                             written + 256 <=3D len ? 256 : len - writ=
ten;
> > +
> > +                     if (!l_getrandom(buf + written, chunk_len)) {
> > +                             TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, =
0,
> > +                                             "l_getrandom(buf, %zu) fa=
iled",
> > +                                             chunk_len);
> > +                             return false;
> > +                     }
> > +
> > +                     written +=3D chunk_len;
> > +             } while (written < len);
>
> So where is the magic 256 byte thing is coming from?

It's to workaround this check in random.c:

62:        if (len > 256)
63:                return false;

I don't know exactly why it's needed but I'll play with it and see if
we can remove/work around this limit.

> Is this due to the
> EINTR possibility?  If so either use TFR() inside l_getrandom itself, or
> have l_getrandom perform this magic.  This blocking logic doesn't belong
> here.
>
> > +     } while (!l_key_validate_dh_payload(buf, len,
> > +                                             params->prime_buf,
> > +                                             params->prime_len));
>
> Generating a whole new random number is really a bad way of doing
> things.  The entropy pool is a very limited resource, so don't abuse it.
>   A much easier way would be to simply set the most-significant-byte to
> 0.

It's a pattern we use in the ecdh code (where the group order is only
~1/2 of the number space -- can improved by switching from the "Black
box" method to the "Deterministic" method iirc) and in iwd so we'd
probably need to change it everywhere.  But it seems that every way to
"fix" the number instead of generating a new one affects the
distribution making the algorithm weaker.  If that's ok then yes, we
can simply force the top bits of the private value do "0" (down to the
first "1" bit of the prime).

> Or maybe even just the most-significant-bit. The prime numbers are
> usually always starting with 0xff, so fudging a single byte out of 192+
> should be safe.

Not in TLS, most of the https servers I test against use custom
generated prime numbers, I guess the openssl or gnutls package
generates a random (likely-to-be) prime at install.

>
> > +
> > +     return true;
> > +}
> > +
>
> <snip>
>
> > +static bool tls_get_server_dh_params_hash(struct l_tls *tls, uint8_t t=
ls_id,
> > +                                             uint8_t *out, size_t *len,
> > +                                             enum l_checksum_type *typ=
e)
> > +{
> > +     unsigned int hash;
> > +     struct l_checksum *checksum;
> > +     uint8_t params[32 + TLS_DHE_MAX_SIZE * 3];
>
> Have you considered making this a static buf inside
> tls_write_server_dh_params?

I guess I can do that.

>
> > +     size_t params_len;
> > +     ssize_t hash_len, ret;
> > +
> > +     params_len =3D tls_write_server_dh_params(tls, params);
> > +
> > +     for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
> > +             if (tls_handshake_hash_data[hash].tls_id =3D=3D tls_id)
> > +                     break;
> > +
> > +     if (hash =3D=3D __HANDSHAKE_HASH_COUNT)
> > +             return false;
>
> Why not perform the search prior to tls_write_server_dh_params?

Ok.

>
> > +
> > +     hash_len =3D tls_handshake_hash_data[hash].length;
> > +
> > +     checksum =3D l_checksum_new(tls_handshake_hash_data[hash].l_id);
> > +     if (!checksum)
> > +             return false;
> > +
> > +     l_checksum_update(checksum, tls->pending.client_random, 32);
> > +     l_checksum_update(checksum, tls->pending.server_random, 32);
> > +     l_checksum_update(checksum, params, params_len);
> > +     ret =3D l_checksum_get_digest(checksum, out, hash_len);
> > +     l_checksum_free(checksum);
> > +
> > +     if (ret !=3D (ssize_t) hash_len)
> > +             return false;
> > +
> > +     if (len)
> > +             *len =3D hash_len;
> > +
> > +     if (type)
> > +             *type =3D tls_handshake_hash_data[hash].l_id;
> > +
> > +     return true;
> > +}
> > +
> > +static void tls_handle_dhe_server_key_xchg(struct l_tls *tls,
> > +                                             const uint8_t *buf, size_=
t len)
> > +{
> > +     struct tls_dhe_params *params;
> > +
> > +     params =3D l_new(struct tls_dhe_params, 1);
> > +     tls->pending.key_xchg_params =3D params;
>
> Why do this assignment here?

The reason is so that in case of error tls_reset_handshake will free
this and we don't have to worry about it, I can add a comment.

>
> > +
> > +     if (len < 2)
> > +             goto decode_error;
> > +
> > +     params->prime_len =3D l_get_be16(buf);
> > +     if (len < 2 + params->prime_len + 2)
> > +             goto decode_error;
> > +
> > +     params->prime_buf =3D l_memdup(buf + 2, params->prime_len);
> > +     buf +=3D 2 + params->prime_len;
> > +     len -=3D 2 + params->prime_len;
> > +
> > +     params->generator_len =3D l_get_be16(buf);
> > +     if (len < 2 + params->generator_len + 2)
> > +             goto decode_error;
> > +
> > +     params->generator_buf =3D l_memdup(buf + 2, params->generator_len=
);;
> > +     buf +=3D 2 + params->generator_len;
> > +     len -=3D 2 + params->generator_len;
> > +
> > +     params->public_len =3D l_get_be16(buf);
> > +     if (len < 2 + params->public_len)
> > +             goto decode_error;
> > +
> > +     params->public_buf =3D buf + 2;
> > +     buf +=3D 2 + params->public_len;
> > +     len -=3D 2 + params->public_len;
> > +
> > +     /*
> > +      * Validate the values received.  Without RFC 7919 we basically h=
ave
> > +      * to blindly accept the provided prime value.  We have no way to
> > +      * confirm that it's actually prime or that it's a "safe prime" or
> > +      * that it forms a group without small sub-groups.  There's also =
no
> > +      * way to whitelist all valid values.  But we do a basic sanity
> > +      * check and require it to be 1024-bit or longer (see weakdh.org),
> > +      * might need to move to 2048 bits actually.
> > +      */
> > +
> > +     if (params->prime_len > TLS_DHE_MAX_SIZE ||
> > +                     params->generator_len > params->prime_len) {
> > +             TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
> > +                             "Server DH prime modulus or generator "
> > +                             "too long");
> > +             return;
> > +     }
> > +
> > +     if (params->prime_len < 128 || params->prime_buf[0] =3D=3D 0x00 ||
> > +                     !(params->prime_buf[params->prime_len - 1] & 1)) {
> > +             TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
> > +                             "Server DH prime modulus invalid");
> > +             return;
> > +     }
> > +
> > +     /*
> > +      * RFC 7919 Section 3.0:
> > +      * "the client MUST verify that dh_Ys is in the range
> > +      * 1 < dh_Ys < dh_p - 1.  If dh_Ys is not in this range, the clie=
nt
> > +      * MUST terminate the connection with a fatal handshake_failure(4=
0)
> > +      * alert."
> > +      */
> > +     if (params->public_len > params->prime_len ||
> > +                     !l_key_validate_dh_payload(params->public_buf,
> > +                                                     params->public_le=
n,
> > +                                                     params->prime_buf,
> > +                                                     params->prime_len=
)) {
>
> So can we rely on the kernel to do this part for us?

Apparently we can't without modifying security/keys/dh.c and our keys
code.  The keyctl operation is too smart and assumes
generate_public_key and generate_shared_secret are the same operation,
so when crypto/dh.c receives the parameters it always thinks it's
dealing with a generator and the private value, instead of private and
public values.  So it never runs the public value validation.
dh_is_pubkey_valid also has one minor unimplemented feature.

Best regards

--===============1995389477836966344==--

