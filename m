Content-Type: multipart/mixed; boundary="===============4100021357239684434=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 08/11] tls: Stricter certificate chain verification
Date: Fri, 02 Nov 2018 09:38:32 +0100
Message-ID: <CAOq732+adoJWPHCgn-29+R59OeoVSdW=vyPF-Edd4X2E-nKkyw@mail.gmail.com>
In-Reply-To: <d83e1648-de36-8864-3232-0e243532b98e@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4100021357239684434==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, 2 Nov 2018 at 01:55, Denis Kenzior <denkenz@gmail.com> wrote:
> On 11/01/2018 07:35 PM, Mat Martineau wrote:
> > Have you considered loading the root certs in to a kernel keyring once
> > in l_tls_set_cacert() then keeping it around to reuse?
> >
>
> Exactly.  This is ultimately what we want: to load root CAs once and
> reuse them between multiple connections.  So the CA keyring needs to be
> reusable.

Ok.  With it being possible to add nested keyrings this is easy.

> >> <snip>
> >>
> >>> @@ -2772,43 +2840,19 @@ static void tls_keyring_cleanup(struct
> >>> l_keyring **p)
> >>>   bool tls_cert_verify_certchain(struct tls_cert *certchain,
> >>>                   struct l_queue *ca_certs)
> >>>   {
> >>> -    L_AUTO_CLEANUP_VAR(struct l_keyring *, ca_ring,
> >>> tls_keyring_cleanup);
> >>>       L_AUTO_CLEANUP_VAR(struct l_keyring *, verify_ring,
> >>> -                tls_keyring_cleanup);
> >>> +                tls_keyring_cleanup) =3D l_keyring_new();
> >>> +    struct l_key *trusted;
> >>
> >> This function is so simple I would consider dropping the
> >> L_AUTO_CLEANUP_VAR completely.

Ok.

> >
> > The auto cleanup stuff was handy when there were many different 'return'
> > statements, but with the simplified version of this function I agree
> > with Denis.
> >
> >>
> >>>   -    ca_ring =3D NULL;
> >>> -
> >>> -    verify_ring =3D l_keyring_new();
> >>>       if (!verify_ring)
> >>>           return false;
> >>>   -    /*
> >>> -     * If CA cert(s) were supplied, restrict verify_ring now so
> >>> -     * everything else in certchain is validated against the CA(s).
> >>> -     * Otherwise, verify_ring will be restricted after the root of
> >>> -     * certchain is added to verify_ring by
> >>> -     * tls_cert_verify_with_keyring().
> >>> -     */
> >>> -    if (ca_certs) {
> >>> -        const struct l_queue_entry *entry;
> >>> -
> >>> -        ca_ring =3D l_keyring_new();
> >>> -        if (!ca_ring)
> >>> -            return false;
> >>> -
> >>> -        for (entry =3D l_queue_get_entries(ca_certs); entry;
> >>> -                entry =3D entry->next)
> >>> -            if (!tls_cert_link(entry->data, ca_ring))
> >>> -                return false;
> >>> -
> >>> -        if (!l_keyring_restrict(verify_ring,
> >>> -                    L_KEYRING_RESTRICT_ASYM_CHAIN,
> >>> -                    ca_ring))
> >>> -            return false;
> >>> -    }
> >>> +    trusted =3D tls_cert_verify_with_keyring(certchain, verify_ring,
> >>> ca_certs);
> >>> +    if (!trusted)
> >>> +        return false;
> >>>   -    return tls_cert_verify_with_keyring(certchain, verify_ring,
> >>> ca_certs,
> >>> -                        ca_ring);
> >>> +    l_key_free(trusted);
> >>> +    return true;
> >>>   }
> >>>     void tls_cert_free_certchain(struct tls_cert *cert)
> >>>
> >>
> >
> > It seems like the implementation is made more complicated by the fact
> > that the cert list is a singly-linked list starting with the end-entity
> > cert (which we then follow toward the root using the issuer pointers),
> > while in order to verify we need to link keys to the restricted keyring
> > starting from the root end of the chain.
> >
> > If we know that it's a linear cert chain, the code could be simplified
> > by making the cert chain a doubly-linked list that could be walked in
> > the other direction. That would eliminate the recursion, leading to an
> > implementation that looks more like this:
> >
> > 1. Create a keyring
> > 2. Load it with the root certs
> > 3. Try to load the first cert in the chain (from the root-facing end)
> > 4. If that works, clear the root certs
> > 5. Try to load the next cert in the chain
> > 6. If that works, clear the previous cert
> > 7. Repeat 5-6 until you get to the end-entity cert
> >
> > That's the behavior of this patch (from the perspective of the kernel),
> > but it's hard to see because recursive calls are used to follow the
> > issuer chain toward the root first, then the keyring loads are attempted
> > as the stack gets unwound.
> >
> > (I realize the recursive code structure is inherited from my earlier
> > implementation :) )
> >
>
> I agree here, I think recursive implementation is actually harder to
> read and more resource intensive.

Yep, definitely, but using a doubly-linked list for all tls_cert
structs also seems like unneeded overhead.  We can easily create a
temporary reversed list or a plain array in tls_cert_verify_certchain,
which is only called once per l_tls object anyway.

>
> >
> > As Denis pointed out above, it would be convenient to add and remove the
> > root certs as a group. The kernel lets keyrings contain keyrings. A
> > restricted keyring R will search for signing keys in the trusted keyring
> > T (if it wasn't NULL), and within R itself. If R "contains" a link to
> > another keyring A, it will search T, R, and A for signing keys.
> >
> > If we add l_keyring_link_nested(keyring, nested_keyring) to ELL, then
> > you could have a persistent ca_ring that is temporarly linked to the
> > verify ring to check the first cert, then ca_ring gets unlinked in a
> > single operation when you want to check the second cert.
> >
>
> So that might actually be an even better solution than what I proposed
> above with having a temporary restriction ring.

Yes, makes sense, I had actually seen this in the kernel keyring
search function but it didn't occur to me to use it.

Best regards

--===============4100021357239684434==--

