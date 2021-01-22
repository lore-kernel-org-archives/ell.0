Content-Type: multipart/mixed; boundary="===============0669467858536718577=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] buf: Add a generic extensible buffer struct
Date: Thu, 21 Jan 2021 23:43:31 -0600
Message-ID: <155e2614-69f0-8a00-e4f5-aeeef42c0f80@gmail.com>
In-Reply-To: <CAOq732KczBp-CW0x84EK9tGDj1PuCHXU46YBGqby5wdQNZoWFQ@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0669467858536718577==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> Right, most real "classes" in ell are opaque in this sense.  I felt
> that the low level nature of this utility and the fact that it
> replaces basic (c builtin) mechanisms guarantees it being just a
> struct, like the skbufs in the kernel.

skbuf is a bit strange because it has public and private members.  And then=
 some =

things are expected to be done via the API and some via accessing members. =

There are probably very good reasons for all that, but I'm not sure we want=
 to =

use that as a model in ell.

> =

> I don't know how much effect inlining functions really has, even in
> hot paths.  The other
> feature here that uses the struct definition is that we allow the
> nested l_bufs to be allocated on stack.  For example:
> =

> struct l_buf *attr_buf =3D l_genl_msg_append_attr_buf(msg,
> NL80211_ATTR_IE, 100, 100);
> =

> if (is_rsn) {
>    struct ie_rsn_info rsn =3D { ... };
>    struct l_buf rsn_buf; /* On stack */
> =

>    l_buf_append_init(&rsn_buf, attr_buf, 50, 50);
>    ie_build_rnse(&rsn_buf, &rsn);

So, are you focusing on the ATTR_IE building as one of the use cases for th=
is? =

With ATTR_IE we generally build the RSN and other IEs well before the genl =

message exists though?  So by the time we can call  l_genl_msg_append_attr_=
buf, =

the IE is already inside the handshake object or in a scratch buffer and we=
 have =

to memcpy it anyway.

I guess you have some of that in ap.c.  But then, RSNE is typically like 40 =

bytes, so not sure this is worth it to try and optimize a memcpy for it?

>    /* This is made up.  We can have ie_build_rsne allocate rsn_buf
> internally.  It could also append directly to attr_buf but in that
> case it can't *prepend* data and has to build it sequentially. */
> }

Do you have a use case in mind for prepending?

It might be nice to take some part of ap.c or p2p.c from iwd and try conver=
ting =

it so we can see how things would look like on a concrete example.

Regards,
-Denis
--===============0669467858536718577==--

