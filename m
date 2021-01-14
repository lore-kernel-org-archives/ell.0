Content-Type: multipart/mixed; boundary="===============8961442079744223575=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/3] buf: Add a generic extensible buffer struct
Date: Thu, 14 Jan 2021 02:31:44 +0100
Message-ID: <CAOq732KczBp-CW0x84EK9tGDj1PuCHXU46YBGqby5wdQNZoWFQ@mail.gmail.com>
In-Reply-To: <a78e8f12-d5f2-5aec-18f-a43a5fd6ea81@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8961442079744223575==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat, thanks for reviewing this.

On Wed, 13 Jan 2021 at 02:00, Mat Martineau
<mathew.j.martineau@linux.intel.com> wrote:
> On Fri, 8 Jan 2021, Andrew Zaborowski wrote:
> > +struct l_buf {
> > +     struct {
> > +             struct l_buf *parent;
> > +             struct l_buf *child;
> > +             struct iovec *used;
> > +             unsigned int alloced_cnt;
> > +     };
> > +     unsigned int used_cnt;
> > +     struct iovec iovecs[0];
> > +};
>
> I was expecting to see an opaque structure for l_buf here in the header -
> that seems more typical for ELL!

Right, most real "classes" in ell are opaque in this sense.  I felt
that the low level nature of this utility and the fact that it
replaces basic (c builtin) mechanisms guarantees it being just a
struct, like the skbufs in the kernel.

I don't know how much effect inlining functions really has, even in
hot paths.  The other
feature here that uses the struct definition is that we allow the
nested l_bufs to be allocated on stack.  For example:

struct l_buf *attr_buf =3D l_genl_msg_append_attr_buf(msg,
NL80211_ATTR_IE, 100, 100);

if (is_rsn) {
  struct ie_rsn_info rsn =3D { ... };
  struct l_buf rsn_buf; /* On stack */

  l_buf_append_init(&rsn_buf, attr_buf, 50, 50);
  ie_build_rnse(&rsn_buf, &rsn);
  /* This is made up.  We can have ie_build_rsne allocate rsn_buf
internally.  It could also append directly to attr_buf but in that
case it can't *prepend* data and has to build it sequentially. */
}

/* This is equivalent: */
if (is_rsn) {
   struct ie_rsn_info rsn =3D { ... };
  struct l_buf *rsn_buf =3D l_buf_append_new(attr_buf, 50, 50);
  /* Here allocated dynamically, although on the next
l_buf_append_new() call for attr_buf, we'd be re-using the same memory
and same pointer (as documented the old one becomes invalid) so it's
not a big difference */

  ie_build_rnse(rsn_buf, &rsn);
}

We can do without this feature obviously.  I didn't bother with the
unit tests yet because this is just an RFC for now.

Best regards
--===============8961442079744223575==--

