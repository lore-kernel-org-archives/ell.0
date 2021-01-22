Content-Type: multipart/mixed; boundary="===============0786165334828308567=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 1/3] buf: Add a generic extensible buffer struct
Date: Thu, 21 Jan 2021 17:34:24 -0800
Message-ID: <7180e754-1654-b3ea-5c79-60d68c8a14e@linux.intel.com>
In-Reply-To: <CAOq732KczBp-CW0x84EK9tGDj1PuCHXU46YBGqby5wdQNZoWFQ@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0786165334828308567==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 14 Jan 2021, Andrew Zaborowski wrote:

> Hi Mat, thanks for reviewing this.
>
> On Wed, 13 Jan 2021 at 02:00, Mat Martineau
> <mathew.j.martineau@linux.intel.com> wrote:
>> On Fri, 8 Jan 2021, Andrew Zaborowski wrote:
>>> +struct l_buf {
>>> +     struct {
>>> +             struct l_buf *parent;
>>> +             struct l_buf *child;
>>> +             struct iovec *used;
>>> +             unsigned int alloced_cnt;
>>> +     };
>>> +     unsigned int used_cnt;
>>> +     struct iovec iovecs[0];
>>> +};
>>
>> I was expecting to see an opaque structure for l_buf here in the header -
>> that seems more typical for ELL!
>
> Right, most real "classes" in ell are opaque in this sense.  I felt
> that the low level nature of this utility and the fact that it
> replaces basic (c builtin) mechanisms guarantees it being just a
> struct, like the skbufs in the kernel.
>
> I don't know how much effect inlining functions really has, even in
> hot paths.  The other
> feature here that uses the struct definition is that we allow the
> nested l_bufs to be allocated on stack.  For example:
>
> struct l_buf *attr_buf =3D l_genl_msg_append_attr_buf(msg,
> NL80211_ATTR_IE, 100, 100);
>
> if (is_rsn) {
>  struct ie_rsn_info rsn =3D { ... };
>  struct l_buf rsn_buf; /* On stack */
>
>  l_buf_append_init(&rsn_buf, attr_buf, 50, 50);
>  ie_build_rnse(&rsn_buf, &rsn);
>  /* This is made up.  We can have ie_build_rsne allocate rsn_buf
> internally.  It could also append directly to attr_buf but in that
> case it can't *prepend* data and has to build it sequentially. */
> }
>
> /* This is equivalent: */
> if (is_rsn) {
>   struct ie_rsn_info rsn =3D { ... };
>  struct l_buf *rsn_buf =3D l_buf_append_new(attr_buf, 50, 50);
>  /* Here allocated dynamically, although on the next
> l_buf_append_new() call for attr_buf, we'd be re-using the same memory
> and same pointer (as documented the old one becomes invalid) so it's
> not a big difference */
>
>  ie_build_rnse(rsn_buf, &rsn);
> }
>
> We can do without this feature obviously.  I didn't bother with the
> unit tests yet because this is just an RFC for now.

Thanks for the additional background, and for letting me know it's still =

RFC-stage.

I think what it comes down to for me is that exposing the struct internals =

locks those in as part of the "public API" that would be harder to change =

in the future, and that it's less clear how to best use l_buf.

While I lean toward the opaque struct instead of allowing on-stack use, I =

don't know if I convinced you or Denis to lean the same way :)

Thanks for the patches, I think it's a useful feature for ELL.

--
Mat Martineau
Intel
--===============0786165334828308567==--

