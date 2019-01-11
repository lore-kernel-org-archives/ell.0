Content-Type: multipart/mixed; boundary="===============4706983099427304285=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 3/4] tls: DHE_RSA key exchange implementation server side
Date: Fri, 11 Jan 2019 11:50:28 +0100
Message-ID: <CAOq732Kv9gJz8DBddxymHo1PXEfV__YrVCCTyOgfQHqRbmaLHw@mail.gmail.com>
In-Reply-To: <9e0d3be2-1729-4a42-12b2-3a619d057659@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4706983099427304285==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Thu, 10 Jan 2019 at 18:24, Denis Kenzior <denkenz@gmail.com> wrote:
> > Would the same mechanism with a comment be better?  It saves us from
> > rebuilding this structure in tls_get_server_dh_params like in the
> > previous version of the patch.
>
> Comment might be helpful, though I'm more picking on the use of space in
> the session permanent storage data structure that is only used to pass a
> value that is on the stack.  It doesn't feel elegant.
>
> >> Perhaps the
> >> sign/verify operation should be receiving the data to be hashed direct=
ly
> >> (maybe as an iovec), instead of having get_hash function lookup the ha=
sh
> >> id, create the checksum, run it, check for errors, etc).  You are
> >> already duplicating these steps in tls_get_server_ecdh_params_hash and
> >> tls_get_server_dh_params_hash.  Admittedly, tls_get_prev_digest_by_id =
is
> >> a bit of a special case.
> >
> > Yes, this API needed to be universal because we don't want to keep
> > copies of all the handshake messages for tls_get_prev_digest_by_id and
> > tls_get_handshake_hash_by_id.  We can move the hash lookups from the
>
> Right I remember that.
>
> > callbacks to the sign/verify although there'd then be duplication in
> > those functions and any new signature methods added, same if those
>
> Well those lookups can be combined to a single static utility function, n=
o?
>
> > functions have to deal with an iovec (I guess we couldn't know we'd
> > have new key exchange mechanisms before we have new signature
>
> Hmm, I don't quite understand ?  iovec would make things easy.  Just
> figure out the l_checksum you need to create and call l_checksum_updatev.

If we do this in a common utility function then yes, we can avoid
duplicating those lines, at least for the case where we do have a
buffer with the data to be hashed.

What I meant is that we couldn't know we'd have new get hash callbacks
for the RSA sign/verify functions before we have new sign/verify
functions for other signature algorithms, hence I preferred to push
the logic out of those functions.

> > mechanisms).  What we also could do is pass two callbacks to
> > sign/verify, one to return the data to be hashed if we have it and
> > another to do the hashing which would be common.  Personally I
> > wouldn't worry if it's just about tls_get_server_ecdh_params and
> > tls_get_server_dh_params.
>
> I keep trying to think of something that would be a bit more elegant.
>
> Would splitting up the verify into two steps be helpful?  So first step
> would pre-check the input/length and figure out which hash types are
> desired and return that (with one being MD5/SHA1 combination)
>
> Then step two could be invoked with the actual hash data.
>
> With such a setup we could support a helper function that would receive
> an iovec and can take care of calling the two steps.

So I think it can be done more simply, why not pass the
tls_rsa_sign/verify an optional input buffer, the output buffer and
the get_hash callback?  The callback would receive the input buffer.

So for the handshake hash the input buffer would be null and the
get_hash callbacks would only change their signatures.

For the ServerDHParams / ServerECDHParams hashes we'd pass the pointer
to those structs and we'd pass the same get_hash function for all 4
use cases.

The buffer can be an iovec although that doesn't help much as we only
need one fragment (possibly complicates it).

Making it "elegant" with too many callbacks has a potential to make it
less readable in the sense that it's not easy to figure out what is
going on in the code, and in this case if I understand your idea
correctly you'd still need a third callback to actually do the RSA
verification.

Best regards

--===============4706983099427304285==--

