Content-Type: multipart/mixed; boundary="===============0563962268885518255=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 3/5] cert: Add comments about l_certchain_foreach_*
Date: Mon, 26 Nov 2018 22:57:19 +0100
Message-ID: <CAOq732+MODxRkPhn+t5zo25wjS9+RZtuA1prDWuDE8jWTW7vWQ@mail.gmail.com>
In-Reply-To: <dd8a28c4-3875-1493-9a4e-7b19e760b8f5@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0563962268885518255==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Mon, 26 Nov 2018 at 21:07, Denis Kenzior <denkenz@gmail.com> wrote:
> On 11/23/2018 03:44 AM, Andrew Zaborowski wrote:
> > +/*
> > + * Call @cb for each certificate in the chain starting from the leaf
> > + * certificate.  If a call returns @true, stop and return @true to
> > + * the user, otherwise return @false.
> > + */
> >   LIB_EXPORT bool l_certchain_foreach_from_leaf(struct l_certchain *cha=
in,
>
> This is weird to me actually.  Generally any time we use 'foreach', it
> means that the operation is performed on each node.  There are no
> termination semantics.

True, the name suggests the full chain is traversed.

>
> And what does the overall return value mean to the user?

That would be the user's decision, I was thinking about using this for
the trust verification (even though I didn't use it in the end) where
the return value means "error" but it's also useful when searching for
an element where the return value will mean "success".  Or the value
can be ignored.

> How is it
> useful in the first place?
>
> If you want early termination semantics, I would rewrite this as:
>
> void l_certchain_walk_from_leaf()
> and then l_certchain_foreach_cb_t -> l_certchain_walk_cb_t

Ok, will send a patch.  I think it might be useful.

Best regards

--===============0563962268885518255==--

