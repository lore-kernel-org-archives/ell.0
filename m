Content-Type: multipart/mixed; boundary="===============2773549411931347952=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 3/4] tls: DHE_RSA key exchange implementation server side
Date: Thu, 10 Jan 2019 02:21:00 +0100
Message-ID: <CAOq732LauROY-t1Xb=skRBzR2YRQ6chhP4NB2FAOYb5BcWQVKA@mail.gmail.com>
In-Reply-To: <822f4e43-ebd3-a198-4527-2018cc3a855c@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2773549411931347952==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Wed, 9 Jan 2019 at 18:12, Denis Kenzior <denkenz@gmail.com> wrote:
> On 01/09/2019 04:43 AM, Andrew Zaborowski wrote:
> > Add the handler for the ClientKeyExchange message and a builder callback
> > +     params->server_dh_params_buf =3D ptr;
>
> This part seems a bit hacky..

Would the same mechanism with a comment be better?  It saves us from
rebuilding this structure in tls_get_server_dh_params like in the
previous version of the patch.

>
> > +
> > +     /* RFC 5246, Section 7.4.3 */
> > +
> > +     l_put_be16(params->prime_len, ptr);
> > +     memcpy(ptr + 2, prime_buf, params->prime_len);
> > +     ptr +=3D 2 + params->prime_len;
> > +
> > +     l_put_be16(1, ptr);
> > +     memcpy(ptr + 2, &generator_buf, 1);
> > +     ptr +=3D 2 + 1;
> > +
> > +     l_put_be16(public_len - zeros, ptr);
> > +     memcpy(ptr + 2, public_buf + zeros, public_len - zeros);
> > +     ptr +=3D 2 + public_len - zeros;
> > +
> > +     params->server_dh_params_len =3D ptr - params->server_dh_params_b=
uf;
> > +     tls->pending.key_xchg_params =3D params;
> > +
> > +     sign_len =3D tls->pending.cipher_suite->key_xchg->sign(tls, ptr,
> > +                                     buf + sizeof(buf) - ptr,
> > +                                     tls_get_server_dh_params_hash);
>
> The way you did it in ecdh seems to be much cleaner.

I had it done this way in the previous version but when you suggested
keeping the buffer in the params struct I noticed we could avoid
rebuilding the buffer, and that means we also don't have to keep the
pointers to the raw values of the three l_keys in the params struct so
in the end I'd say it's about as clean.

> Perhaps the
> sign/verify operation should be receiving the data to be hashed directly
> (maybe as an iovec), instead of having get_hash function lookup the hash
> id, create the checksum, run it, check for errors, etc).  You are
> already duplicating these steps in tls_get_server_ecdh_params_hash and
> tls_get_server_dh_params_hash.  Admittedly, tls_get_prev_digest_by_id is
> a bit of a special case.

Yes, this API needed to be universal because we don't want to keep
copies of all the handshake messages for tls_get_prev_digest_by_id and
tls_get_handshake_hash_by_id.  We can move the hash lookups from the
callbacks to the sign/verify although there'd then be duplication in
those functions and any new signature methods added, same if those
functions have to deal with an iovec (I guess we couldn't know we'd
have new key exchange mechanisms before we have new signature
mechanisms).  What we also could do is pass two callbacks to
sign/verify, one to return the data to be hashed if we have it and
another to do the hashing which would be common.  Personally I
wouldn't worry if it's just about tls_get_server_ecdh_params and
tls_get_server_dh_params.

>
> At the very least can we zero out the server_dh_params &
> server_dh_params_len after you're done here (and similarly in patch 2)?

Ok, so as to not leave pointers to data that was on stack (in the
previous version I think I was committing the same sin with the
pointers to the raw key data)

>
> > +     if (sign_len < 0)
> > +             return false;
> > +
> > +     ptr +=3D sign_len;
> > +     tls_tx_handshake(tls, TLS_SERVER_KEY_EXCHANGE, buf, ptr - buf);
> > +     return true;
> > +
> > +free_params:
> > +     l_key_free(params->prime);
> > +     l_key_free(params->generator);
> > +     l_key_free(params->private);
> > +     l_free(params);
> > +     return false;
> > +}
> > +
>
> Anyway, I applied all 4 of these.

Thank you.

--===============2773549411931347952==--

