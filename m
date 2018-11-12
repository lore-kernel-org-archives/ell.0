Content-Type: multipart/mixed; boundary="===============5839994632759734634=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/5] cert: Add cert.c for certificate types and routines
Date: Mon, 12 Nov 2018 11:47:50 +0100
Message-ID: <CAOq732JAoJ=gwujWgcfOY_CEr=MDjbi1p_s1HZ=P3OP0tEARhg@mail.gmail.com>
In-Reply-To: <24bfdbd5-7192-9877-2240-74dfeaddc998@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5839994632759734634==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Fri, 9 Nov 2018 at 16:34, Denis Kenzior <denkenz@gmail.com> wrote:
> On 11/09/2018 02:47 AM, Andrew Zaborowski wrote:
> > On Fri, 9 Nov 2018 at 02:05, Denis Kenzior <denkenz@gmail.com> wrote:
> >>>> and consider dropping link_issuer completely.  Just build a certchain
> >>>> from the raw data directly, perhaps as a private constructor for now.
> >>>
> >>> Could also just do:
> >>>
> >>> struct l_certchain {
> >>>           struct l_queue *certs;
> >>> };
> >>>
> >>> for simplicity.  We only have one use case for iterating from root to
> >>> leaf so we can reverse the queue at that time.  We maybe simply want
> >>> two public methods, l_certchain_foreach_from_root and
> >>> l_certchain_foreach_from_leaf.
> >>
> >> Yes but a quite common one.  And you still need to memdup the l_cert
> >> when you add it to the certchain, so maybe just do it right.
> >
> > By that you mean adding a new l_queue-like structure in cert.c, right?
> >   Can we think of an API that avoids the memdup of the whole
> > certificate?
>
> I can, but it also makes things way too complicated.  Honestly I think
> we should keep l_certchain fully opaque for now and only expose the
> absolute bare minimum.

Well, then if we're building the certchain using a private API then we
can probably avoid the memdup more easily.  So I'm thinking of having
the following two public functions:

l_pem_load_certificate
l_pem_load_certificate_list

The first one loads a single certificate, the second one loads all the
certificates in a PEM file and returns an l_queue (not a certchain
object), and then TLS uses a private chertchain_from_queue() or
simliar to convert the l_queue into a certchain object.

>
> >
> >>
> >>>
> >>> As for the constructor we already need to parse two different "raw"
> >>> formats both of which are defined in pretty distant specs so I don't
> >>> think cert.c should know them, I'd rather have a l_certchain_link_cert
> >>> or similar.
> >>
> >> You can also just implement the two constructors directly here, since
> >> they're the most common case anyway.
> >
> > One case is a completely specific to TLS where parse a binary
> > structure so there's no reason it shouldn't be in tls.c.  The other
>
> We do use the same constructor in tools/certchain-verify.  So I don't
> buy this argument :)

This doesn't make it any less TLS-specific, tools/certchain-verify
uses the TLS Certificate.certificate_list format and even uses
tls_cert_from_certificate_list().

Best regards

--===============5839994632759734634==--

