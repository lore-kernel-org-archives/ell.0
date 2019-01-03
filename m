Content-Type: multipart/mixed; boundary="===============7263055638643025283=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 14/17] tls: DHE_RSA key exchange implementation client side
Date: Wed, 02 Jan 2019 21:30:10 -0600
Message-ID: <00db914f-560c-1d08-64da-de3ba6ffb47e@gmail.com>
In-Reply-To: <CAOq732JaVEhZLkvv7Mhk99DuFUGb6mpXqY9kkArBU4HbbShbig@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7263055638643025283==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>> It seems like the intent of this function is to be called more than
>> once, piecemeal creating the l_key objects.  Why?  That type of pattern
>> isn't terribly readable / maintainable.
> =

> I guess the intent is to simplify error handling in the callers.  I
> can perhaps split this in 4 separate functions, to avoid inlining all
> the l_key_new and TLS_DISCONNECT calls.
> =


By my reading it seems like this is only needs to be called once for the =

client side.  I can see how this is more useful for the server side.

>> So where is the magic 256 byte thing is coming from?
> =

> It's to workaround this check in random.c:
> =

> 62:        if (len > 256)
> 63:                return false;
> =

> I don't know exactly why it's needed but I'll play with it and see if
> we can remove/work around this limit.

So that check is there due to EINTR.  getrandom guarantees to succeed =

for len up to 256.  After that EINTR is a possibility.  We never needed =

random buffers bigger than 256, so it was a lazy fix.

>> Generating a whole new random number is really a bad way of doing
>> things.  The entropy pool is a very limited resource, so don't abuse it.
>>    A much easier way would be to simply set the most-significant-byte to
>> 0.
> =

> It's a pattern we use in the ecdh code (where the group order is only
> ~1/2 of the number space -- can improved by switching from the "Black
> box" method to the "Deterministic" method iirc) and in iwd so we'd

Yeah we might need to fix that, but there might not be an easy way as =

opposed to here.

> probably need to change it everywhere.  But it seems that every way to
> "fix" the number instead of generating a new one affects the
> distribution making the algorithm weaker.  If that's ok then yes, we
> can simply force the top bits of the private value do "0" (down to the
> first "1" bit of the prime).

This would be fine with all DH groups from RFC 3526.  If TLS uses a =

different set of primes, then setting the upper MSB bits to 0 might be =

okay.  If you're worried about this, then perhaps simply re-generating =

the upper N MSB bytes is another solution.  Might want to check what =

other implementations do.

>>> +static void tls_handle_dhe_server_key_xchg(struct l_tls *tls,
>>> +                                             const uint8_t *buf, size_=
t len)
>>> +{
>>> +     struct tls_dhe_params *params;
>>> +
>>> +     params =3D l_new(struct tls_dhe_params, 1);
>>> +     tls->pending.key_xchg_params =3D params;
>>
>> Why do this assignment here?
> =

> The reason is so that in case of error tls_reset_handshake will free
> this and we don't have to worry about it, I can add a comment.

Gah, that's really not obvious.  A comment is needed, but it might be =

better to have decode_error label take care of this instead.

>>> +     /*
>>> +      * RFC 7919 Section 3.0:
>>> +      * "the client MUST verify that dh_Ys is in the range
>>> +      * 1 < dh_Ys < dh_p - 1.  If dh_Ys is not in this range, the clie=
nt
>>> +      * MUST terminate the connection with a fatal handshake_failure(4=
0)
>>> +      * alert."
>>> +      */
>>> +     if (params->public_len > params->prime_len ||
>>> +                     !l_key_validate_dh_payload(params->public_buf,
>>> +                                                     params->public_le=
n,
>>> +                                                     params->prime_buf,
>>> +                                                     params->prime_len=
)) {
>>
>> So can we rely on the kernel to do this part for us?
> =

> Apparently we can't without modifying security/keys/dh.c and our keys
> code.  The keyctl operation is too smart and assumes
> generate_public_key and generate_shared_secret are the same operation,
> so when crypto/dh.c receives the parameters it always thinks it's
> dealing with a generator and the private value, instead of private and
> public values.  So it never runs the public value validation.
> dh_is_pubkey_valid also has one minor unimplemented feature.

That's a bug in the kernel then.  We should fix that.

Regards,
-Denis

--===============7263055638643025283==--

