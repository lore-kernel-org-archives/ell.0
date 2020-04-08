Content-Type: multipart/mixed; boundary="===============5469936669273755720=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] cert: Fix verification of the 2nd certificate in chain
Date: Wed, 08 Apr 2020 12:09:45 -0500
Message-ID: <e37ec65a-5946-4b79-79a7-4b5377d12019@gmail.com>
In-Reply-To: <CAOq732KkPQ6vXfkz3-UyU--bDzXeZmVO1HdhZpU34E2m-5U43A@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5469936669273755720==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/8/20 1:37 PM, Andrew Zaborowski wrote:
> Hi Denis!
> =

> On Wed, 8 Apr 2020 at 17:09, Denis Kenzior <denkenz@gmail.com> wrote:
>> On 4/7/20 12:45 PM, Andrew Zaborowski wrote:
>>> In the case that the trusted CA certificates are provided to
>>> l_certchain_verify() and one of them binary-matches the top CA
>>> certificate in the chain being verified, we'd skip linking it to the
>>> keyring and we'd link the next certificate directly.  As a result
>>> that second certificate would be linked to an empty unrestricted keyring
>>> and would not be verified at all.
>>>
>>> Instead add the top CA to the keyring and restrict it the same way we
>>> proceed when no trusted CAs are provided.
>>> ---
>>>    ell/cert.c | 17 ++++++-----------
>>>    1 file changed, 6 insertions(+), 11 deletions(-)
>>>
>>> diff --git a/ell/cert.c b/ell/cert.c
>>> index d1f58d7..dc6b845 100644
>>> --- a/ell/cert.c
>>> +++ b/ell/cert.c
>>> @@ -454,6 +454,7 @@ LIB_EXPORT bool l_certchain_verify(struct l_certcha=
in *chain,
>>>        struct l_cert *cert;
>>>        struct l_key *prev_key =3D NULL;
>>>        int verified =3D 0;
>>> +     bool ca_match;
>>>        static char error_buf[200];
>>>
>>>        if (unlikely(!chain || !chain->leaf))
>>> @@ -464,6 +465,7 @@ LIB_EXPORT bool l_certchain_verify(struct l_certcha=
in *chain,
>>>                RETURN_ERROR("Can't create verify keyring");
>>>
>>>        cert =3D chain->ca;
>>> +     ca_match =3D cert_is_in_set(cert, ca_certs);
>>>
>>>        /*
>>>         * For TLS compatibility the trusted root CA certificate is
>>> @@ -480,16 +482,9 @@ LIB_EXPORT bool l_certchain_verify(struct l_certch=
ain *chain,
>>>         * cert in the chain if it is identical to one of the trusted CA
>>>         * certificates.  It also happens to work around a kernel issue
>>>         * preventing self-signed certificates missing the AKID
>>> -      * extension from being linked to a keyring.
>>> +      * extension from being linked to a restricted keyring.
>>>         */
>>
>> So is this comment still valid now that you've taken out the if block
>> that takes care of this?  At the very least it seems completely out of
>> place now.
> =

> We have the if (ca_caerts && !ca_match) line right after this comment,
> and what the comment refers to now is the !ca_match check.

I guess I can kind of agree with this, but see below... I think the =

comment should be rewritten for clarity

> =

>>
>> Do we have a unit test with a certchain where the root cert doesn't have
>> AKID extension?
> =

> Since we still need this workaound I'd prefer that we don't commit to
> supporting this for now.  We don't know if we may need to make an
> incompatible change at some point...

I'm not following?  We have CA Certs that might be missing the AKID =

extension that are supposed to work in all situations.  Why do we not =

have a test for this that can detect regressions, etc?

> =

> Also if we generate such certificates in the Makefile we'd have to
> hide the command pretty well so that nobody thinks it's the right
> thing to do.
> =


I will have to disagree completely here.  This is a valid use case we =

should be testing.  If someone uses iwd as a guide for 'best practices =

of certificate generation', that is their problem ;)

>>
>>> -     if (cert_is_in_set(cert, ca_certs)) {
>>> -             verified++;
>>> -             cert =3D cert->issued;
>>> -             if (!cert)
>>> -                     return true;
>>> -
>>> -             prev_key =3D cert_try_link(cert, verify_ring);
>>
>> So remind me again what the actual problem was? The code here is
>> 'optimizing' by not trying to link the root cert at all, supposedly
>> because it might be self-signed and missing the AKID extension.
> =

> Previously if we detected that the top certificate was an exact copy
> of one of the trusted CAs, we'd save time by not pushing any of the
> trusted CAs into the kernel, building the CA keyring, etc., and not

I get this part.  By the way, this should probably be part of the =

comment above.

> even pushing that top certificate into the kernel... but that was
> wrong because the second certificate was completely unchecked, I think
> we had a serious security problem there.

Right...

> =

> Now we still skip building the whole ca_ring but we do link the first
> certificate to verify_ring so that the second certificate can be
> verified like the rest of the chain.  The code for this is common with
> the case where no trusted CA list is provided.
> =

> In terms of the AKID extension, when we link the first certificate to
> verify_ring it is not restricted so the restrict functions don't run
> and there should be no issue.  Previously we didn't even link that
> certificate so that also worked...

So to be clear, the issue with AKID extension is only in the following =

scenario:

CACerts =3D ca1 ca2 ca3
PeerCertchain =3D ca2 int1 int2 leaf

Lets say ca2 is self-signed and missing AKID.

If we load the CACerts into the ca_ring, link it to the verify ring and =

restrict the verify ring, the linking of ca2 from the PeerCertchain =

would fail.  This is the limitation in the kernel we're working around, =

right?

So the optimization is that since we know that ca2 is a bitwise copy, we =

can load ca2 into the verify_ring, restrict the verify ring.  Any =

subsequent linking of int1 would then succeed.

Right?  So why don't we have a unit test of this case? ;)

Regards,
-Denis
--===============5469936669273755720==--

