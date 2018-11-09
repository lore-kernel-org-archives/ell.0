Content-Type: multipart/mixed; boundary="===============2256081647998022496=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/5] cert: Add cert.c for certificate types and routines
Date: Fri, 09 Nov 2018 09:47:29 +0100
Message-ID: <CAOq732Lm57nfY9Q4U7-nbqae7LePxaO8=RP_V7qn4-TDAeN9jA@mail.gmail.com>
In-Reply-To: <48d3bc46-929a-3b8e-5e91-f96aab451da5@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2256081647998022496==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 9 Nov 2018 at 02:05, Denis Kenzior <denkenz@gmail.com> wrote:
> > Yep, that's the downside of this approach, the up side is less code
> > for both the implementation and the user.  I'd understood you actually
> > preferred this approach but I'll happily switch to having separate
> > types.
>
> When have I ever preferred less code in favor of less readability? :)
>
> Anyhow, I rather have something with clear semantics even if it costs a
> bit more code size.

We must have been talking about different things then.

> >> and consider dropping link_issuer completely.  Just build a certchain
> >> from the raw data directly, perhaps as a private constructor for now.
> >
> > Could also just do:
> >
> > struct l_certchain {
> >          struct l_queue *certs;
> > };
> >
> > for simplicity.  We only have one use case for iterating from root to
> > leaf so we can reverse the queue at that time.  We maybe simply want
> > two public methods, l_certchain_foreach_from_root and
> > l_certchain_foreach_from_leaf.
>
> Yes but a quite common one.  And you still need to memdup the l_cert
> when you add it to the certchain, so maybe just do it right.

By that you mean adding a new l_queue-like structure in cert.c, right?
 Can we think of an API that avoids the memdup of the whole
certificate?

>
> >
> > As for the constructor we already need to parse two different "raw"
> > formats both of which are defined in pretty distant specs so I don't
> > think cert.c should know them, I'd rather have a l_certchain_link_cert
> > or similar.
>
> You can also just implement the two constructors directly here, since
> they're the most common case anyway.

One case is a completely specific to TLS where parse a binary
structure so there's no reason it shouldn't be in tls.c.  The other
case is loading from a PEM file (remember we tried to avoid adding the
l_pem_load_certificate_list function returning multiple buffers?  We
can't build the certchain in cert.c without that function, or calling
l_pem_load_file multiple times)

>
> >>
> >> So we're still doing the recursive verify.  It might makes things
> >> clearer if you added l_cert* stub classes first.  Then a separate comm=
it
> >> moving the recursive implementation from tls.c to cert.c.
> >
> > Ugh, that would be a commit for each method being moved?  There isn't
> > really much to review if we're just moving the code, however not
> > breaking TLS between the multiple commits could be really complicated.
>
> Still much clearer / preferable than adding a brand new version and then
> removing the old one.

We're not adding a brand new version here though, I tried to be
careful not to suggest this in the commit.  The structs are new
though, let me send them as one patch, then move the methods in
another and then switch tls from struct tls_cert to struct l_cert.

Best regards

--===============2256081647998022496==--

