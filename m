Content-Type: multipart/mixed; boundary="===============1880384046435503079=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/5] cert: Add cert.c for certificate types and routines
Date: Fri, 09 Nov 2018 09:34:19 -0600
Message-ID: <24bfdbd5-7192-9877-2240-74dfeaddc998@gmail.com>
In-Reply-To: <CAOq732Lm57nfY9Q4U7-nbqae7LePxaO8=RP_V7qn4-TDAeN9jA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1880384046435503079==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/09/2018 02:47 AM, Andrew Zaborowski wrote:
> On Fri, 9 Nov 2018 at 02:05, Denis Kenzior <denkenz@gmail.com> wrote:
>>>> and consider dropping link_issuer completely.  Just build a certchain
>>>> from the raw data directly, perhaps as a private constructor for now.
>>>
>>> Could also just do:
>>>
>>> struct l_certchain {
>>>           struct l_queue *certs;
>>> };
>>>
>>> for simplicity.  We only have one use case for iterating from root to
>>> leaf so we can reverse the queue at that time.  We maybe simply want
>>> two public methods, l_certchain_foreach_from_root and
>>> l_certchain_foreach_from_leaf.
>>
>> Yes but a quite common one.  And you still need to memdup the l_cert
>> when you add it to the certchain, so maybe just do it right.
> =

> By that you mean adding a new l_queue-like structure in cert.c, right?
>   Can we think of an API that avoids the memdup of the whole
> certificate?

I can, but it also makes things way too complicated.  Honestly I think =

we should keep l_certchain fully opaque for now and only expose the =

absolute bare minimum.

> =

>>
>>>
>>> As for the constructor we already need to parse two different "raw"
>>> formats both of which are defined in pretty distant specs so I don't
>>> think cert.c should know them, I'd rather have a l_certchain_link_cert
>>> or similar.
>>
>> You can also just implement the two constructors directly here, since
>> they're the most common case anyway.
> =

> One case is a completely specific to TLS where parse a binary
> structure so there's no reason it shouldn't be in tls.c.  The other

We do use the same constructor in tools/certchain-verify.  So I don't =

buy this argument :)

> case is loading from a PEM file (remember we tried to avoid adding the
> l_pem_load_certificate_list function returning multiple buffers?  We
> can't build the certchain in cert.c without that function, or calling
> l_pem_load_file multiple times)

Sure you can.  Just have pem.c load all of them and then pass a queue or =

an array to a private constructor in cert.c.  Or have some fun magic one =

that just builds certchain in-order.

But neither of these need to be public at all.  I seriously don't see =

any usecase for us right now where a client could need to build =

certificate chains outside of TLS.  So until we have such a use case I =

don't see _any_ reason to make these public.

Regards,
-Denis

--===============1880384046435503079==--

