Content-Type: multipart/mixed; boundary="===============5913779161780228449=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/3] buf: Add a generic extensible buffer struct
Date: Fri, 22 Jan 2021 12:19:56 +0100
Message-ID: <CAOq732LXpL4T64T4=HBEMjd8JbWj8rH7Revc-K=fRoXs_hA9qQ@mail.gmail.com>
In-Reply-To: <CAOq732LHhCg-UgPrMv9B5X5SXZMUwqSfRioJN7idAvGq9ArrJQ@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5913779161780228449==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 22 Jan 2021 at 12:05, Andrew Zaborowski
<andrew.zaborowski@intel.com> wrote:
> On Fri, 22 Jan 2021 at 06:43, Denis Kenzior <denkenz@gmail.com> wrote:
> > > Right, most real "classes" in ell are opaque in this sense.  I felt
> > > that the low level nature of this utility and the fact that it
> > > replaces basic (c builtin) mechanisms guarantees it being just a
> > > struct, like the skbufs in the kernel.
> >
> > skbuf is a bit strange because it has public and private members.  And =
then some
> > things are expected to be done via the API and some via accessing membe=
rs.
> > There are probably very good reasons for all that, but I'm not sure we =
want to
> > use that as a model in ell.
> >
> > >
> > > I don't know how much effect inlining functions really has, even in
> > > hot paths.  The other
> > > feature here that uses the struct definition is that we allow the
> > > nested l_bufs to be allocated on stack.  For example:
> > >
> > > struct l_buf *attr_buf =3D l_genl_msg_append_attr_buf(msg,
> > > NL80211_ATTR_IE, 100, 100);
> > >
> > > if (is_rsn) {
> > >    struct ie_rsn_info rsn =3D { ... };
> > >    struct l_buf rsn_buf; /* On stack */
> > >
> > >    l_buf_append_init(&rsn_buf, attr_buf, 50, 50);
> > >    ie_build_rnse(&rsn_buf, &rsn);
> >
> > So, are you focusing on the ATTR_IE building as one of the use cases fo=
r this?
> > With ATTR_IE we generally build the RSN and other IEs well before the g=
enl
> > message exists though?  So by the time we can call  l_genl_msg_append_a=
ttr_buf,
> > the IE is already inside the handshake object or in a scratch buffer an=
d we have
> > to memcpy it anyway.
> >
> > I guess you have some of that in ap.c.  But then, RSNE is typically lik=
e 40
> > bytes, so not sure this is worth it to try and optimize a memcpy for it?
>
> Right, I think we don't have any good examples where we'd be passing a
> lot of data or have many nested structures.  I took building IE
> sequences as an example, I think for now this is the only potential
> user (outside of ell) of the l_buf API since the rest of the changes
> can be hidden by l_genl.
>
> >
> > >    /* This is made up.  We can have ie_build_rsne allocate rsn_buf
> > > internally.  It could also append directly to attr_buf but in that
> > > case it can't *prepend* data and has to build it sequentially. */
> > > }
> >
> > Do you have a use case in mind for prepending?
>
> So this whole special buffer idea is most useful when you have
> multiple layers of nested messages like in the kernel network stack,
> our use cases are kinda trivial in comparison.  I have 3
> l_buf_prepend() calls in the genl patch, the use case is something
> like the following:
>
> * P2P wants to update the P2P IE in the beacons, it calls ap.c API to
> get an l_buf
>
> * ap.c knows how much headroom and tailroom it needs for the other
> beacon elements, it calls l_genl to create a message and get an
> attribute l_buf like in the example in my reply to Mat,
>
> * l_genl knows how much headroom and tailroom it needs for the
> attribute, it creates the nested attribute l_buf from the "base"
> message l_buf and returns it,
>
> * ap.c just returns it to P2P.
>
> * P2P writes its data (P2P IE, WFD IE) probably using the append API
> but then it calls back into ap.c
>
> * Now in ap.c since the IE order doesn't matter (I believe?) we can
> prepend or append the other IEs, it doesn't matter.  Or we can create
> nested l_bufs for each IE, we have various options here.
>
> * l_genl prepends the attribute headers and the message headers and
> sends the message.
>
> So hmm, basically l_genl is the only user that benefits from the
> prepend calls in this particular scenario.  I think internally in P2P,
> WFD can be seen as aonther layer on top of P2P but since the P2P IE
> and WSC IE don't share any header, there's no use case for
> l_buf_prepend.
>
> The situation is going to look very similar with frame-xchg.  When
> p2p.c wants to send the P2P Negotiation Request frame it gets an l_buf
> from frame-xchg.c instead of from ap.c, but frame-xchg.c doesn't need
> to prepend any extra headers to the frame data so technically there's
> no use case for l_buf_prepend either.
>
> Eventually we could integrate ie_tlv_encapsulate_wsc_payload and
> ie_tlv_encapsulate_p2p_payload into wsc_attr_builder and
> p2p_attr_builder to avoid more memcpy's and they could also use l_buf.
> When we want to build a new P2P IE for the beacon or another frame,
> we'd first call ap.c/frame-xchg.c to get an l_buf and we'd then pass
> it to p2p_build_{frame type}.  That function has no chance to add its
> headroom beacuse it's not allocating the l_buf, but it can nested
> l_bufs if there's any IE subelement that is big or complicated enough,
> and then it'd use l_buf_prepend() for the attribute header.  That said
> I don't think it's worth it for any of the subelements we currently
> use.
>
> >
> > It might be nice to take some part of ap.c or p2p.c from iwd and try co=
nverting
> > it so we can see how things would look like on a concrete example.
>
> In ap.c I think the beacon update API is going to be the main explicit
> user.  We don't have that API yet because it's blocked by the l_buf
> stuff ;-)  But I imagine it as two functions something like:
>
> struct l_buf *ap_new_beacon(struct ap_state *ap, size_t headroom,
> size_t tailroom)
> {
>     struct l_genl_msg *cmd;
>     uint64_t wdev_id =3D netdev_get_wdev_id(ap->netdev);
>     struct l_buf *buf;
>     static const uint8_t bcast_addr[6] =3D {
>         0xff, 0xff, 0xff, 0xff, 0xff, 0xff
>     };
>
>     if (L_WARN_ON(!ap->started))
>         return;
>
>     cmd =3D l_genl_msg_new_sized(NL80211_CMD_SET_BEACON, 32);
>     l_genl_msg_append_attr(cmd, NL80211_ATTR_IE, 0, "");
>     l_genl_msg_append_attr(cmd, NL80211_ATTR_IE_PROBE_RESP, 0, "");
>     l_genl_msg_append_attr(cmd, NL80211_ATTR_IE_ASSOC_RESP, 0, "");
>
>     buf =3D l_genl_msg_append_attr_buf(cmd, NL80211_ATTR_BEACON_HEAD, 0, =
256);
>     ap_build_beacon_pr_head(ap, MPDU_MANAGEMENT_SUBTYPE_BEACON,
> bcast_addr, buf);
>
>     buf =3D l_genl_msg_append_attr_buf(cmd, NL80211_ATTR_BEACON_HEAD, 0, =
256);
>     ap_build_beacon_pr_head(ap, MPDU_MANAGEMENT_SUBTYPE_BEACON,
> bcast_addr, buf);

This was supposed to read:
     buf =3D l_genl_msg_append_attr_buf(cmd, NL80211_ATTR_BEACON_TAIL, 0, 2=
56);
     ap_build_beacon_pr_tail(ap, MPDU_MANAGEMENT_SUBTYPE_BEACON,
bcast_addr, buf);

>
>     ap->pending_set_beacon =3D cmd;
>     return buf;

And this would need to be:
    return l_buf_append_new(buf, headroom, tailroom);

> }

Best regards
--===============5913779161780228449==--

