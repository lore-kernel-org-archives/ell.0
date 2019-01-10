Content-Type: multipart/mixed; boundary="===============3360942864219272487=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/4] tls: DHE_RSA key exchange implementation server side
Date: Thu, 10 Jan 2019 11:24:13 -0600
Message-ID: <9e0d3be2-1729-4a42-12b2-3a619d057659@gmail.com>
In-Reply-To: <CAOq732LauROY-t1Xb=skRBzR2YRQ6chhP4NB2FAOYb5BcWQVKA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3360942864219272487==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> Would the same mechanism with a comment be better?  It saves us from
> rebuilding this structure in tls_get_server_dh_params like in the
> previous version of the patch.

Comment might be helpful, though I'm more picking on the use of space in =

the session permanent storage data structure that is only used to pass a =

value that is on the stack.  It doesn't feel elegant.

>> Perhaps the
>> sign/verify operation should be receiving the data to be hashed directly
>> (maybe as an iovec), instead of having get_hash function lookup the hash
>> id, create the checksum, run it, check for errors, etc).  You are
>> already duplicating these steps in tls_get_server_ecdh_params_hash and
>> tls_get_server_dh_params_hash.  Admittedly, tls_get_prev_digest_by_id is
>> a bit of a special case.
> =

> Yes, this API needed to be universal because we don't want to keep
> copies of all the handshake messages for tls_get_prev_digest_by_id and
> tls_get_handshake_hash_by_id.  We can move the hash lookups from the

Right I remember that.

> callbacks to the sign/verify although there'd then be duplication in
> those functions and any new signature methods added, same if those

Well those lookups can be combined to a single static utility function, no?

> functions have to deal with an iovec (I guess we couldn't know we'd
> have new key exchange mechanisms before we have new signature

Hmm, I don't quite understand ?  iovec would make things easy.  Just =

figure out the l_checksum you need to create and call l_checksum_updatev.

> mechanisms).  What we also could do is pass two callbacks to
> sign/verify, one to return the data to be hashed if we have it and
> another to do the hashing which would be common.  Personally I
> wouldn't worry if it's just about tls_get_server_ecdh_params and
> tls_get_server_dh_params.

I keep trying to think of something that would be a bit more elegant.

Would splitting up the verify into two steps be helpful?  So first step =

would pre-check the input/length and figure out which hash types are =

desired and return that (with one being MD5/SHA1 combination)

Then step two could be invoked with the actual hash data.

With such a setup we could support a helper function that would receive =

an iovec and can take care of calling the two steps.

> =

>>
>> At the very least can we zero out the server_dh_params &
>> server_dh_params_len after you're done here (and similarly in patch 2)?
> =

> Ok, so as to not leave pointers to data that was on stack (in the
> previous version I think I was committing the same sin with the
> pointers to the raw key data)
> =


Right.  I noticed these two instances.  We should at least fix these =

ASAP.  If we have others, then we should fix them as well.

Regards,
-Denis

--===============3360942864219272487==--

