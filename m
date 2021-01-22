Content-Type: multipart/mixed; boundary="===============3458862629626823402=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] buf: Add a generic extensible buffer struct
Date: Fri, 22 Jan 2021 10:07:23 -0600
Message-ID: <60b994d0-653a-f147-241c-7643b9eb3bec@gmail.com>
In-Reply-To: <CAOq732LHhCg-UgPrMv9B5X5SXZMUwqSfRioJN7idAvGq9ArrJQ@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3458862629626823402==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> Right, I think we don't have any good examples where we'd be passing a
> lot of data or have many nested structures.  I took building IE
> sequences as an example, I think for now this is the only potential
> user (outside of ell) of the l_buf API since the rest of the changes
> can be hidden by l_genl.

Hmm, what about EAP-TLS? Do we have use cases there?

> =

>>
>>>     /* This is made up.  We can have ie_build_rsne allocate rsn_buf
>>> internally.  It could also append directly to attr_buf but in that
>>> case it can't *prepend* data and has to build it sequentially. */
>>> }
>>
>> Do you have a use case in mind for prepending?
> =

> So this whole special buffer idea is most useful when you have
> multiple layers of nested messages like in the kernel network stack,

Right, this would be useful in EAP for example where we manage the headroom=
 by =

hand...

> our use cases are kinda trivial in comparison.  I have 3
> l_buf_prepend() calls in the genl patch, the use case is something
> like the following:
> =

> * P2P wants to update the P2P IE in the beacons, it calls ap.c API to
> get an l_buf
> =

> * ap.c knows how much headroom and tailroom it needs for the other
> beacon elements, it calls l_genl to create a message and get an
> attribute l_buf like in the example in my reply to Mat,
> =

> * l_genl knows how much headroom and tailroom it needs for the
> attribute, it creates the nested attribute l_buf from the "base"
> message l_buf and returns it,
> =

> * ap.c just returns it to P2P.
> =

> * P2P writes its data (P2P IE, WFD IE) probably using the append API
> but then it calls back into ap.c
> =

> * Now in ap.c since the IE order doesn't matter (I believe?) we can
> prepend or append the other IEs, it doesn't matter.  Or we can create
> nested l_bufs for each IE, we have various options here.

Actually, the order does matter.  Each frame type specifies the order.

802.11-2016, Section 9.4.2.1:
"The frame body components specified for many management subtypes result in =

elements ordered by ascending values of the Element ID field and then the =

Element ID Extension field (when present), with the exception of the MIC =

Management element (9.4.2.55). If present, the MIC Management element appea=
rs at =

the end of the robust management frame body. See 10.27.6 on the parsing of =

elements."

> =

> * l_genl prepends the attribute headers and the message headers and
> sends the message.
> =

> So hmm, basically l_genl is the only user that benefits from the
> prepend calls in this particular scenario.  I think internally in P2P,
> WFD can be seen as aonther layer on top of P2P but since the P2P IE
> and WSC IE don't share any header, there's no use case for
> l_buf_prepend.
> =

> The situation is going to look very similar with frame-xchg.  When
> p2p.c wants to send the P2P Negotiation Request frame it gets an l_buf
> from frame-xchg.c instead of from ap.c, but frame-xchg.c doesn't need
> to prepend any extra headers to the frame data so technically there's
> no use case for l_buf_prepend either.

So can we get away with a simplified implementation for headroom management=
? =

Like what the kernel skbuf does basically.  You create the buffer and =

immediately set the headroom, which just moves the pointer.  Once data has =
been =

added, headroom can't be extended without making a copy of the buffer.   Th=
is =

generally works out well because the message specific headroom is known ahe=
ad of =

time by some means (perhaps by a driver setting it when registering, etc)

> =

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

In the case of WSC at least it may be easier to just specify how we want th=
e =

element to be built.  So we can fragment it as we build it for example.

> =

>>
>> It might be nice to take some part of ap.c or p2p.c from iwd and try con=
verting
>> it so we can see how things would look like on a concrete example.
> =

> In ap.c I think the beacon update API is going to be the main explicit
> user.  We don't have that API yet because it's blocked by the l_buf
> stuff ;-)  But I imagine it as two functions something like:
> =

> struct l_buf *ap_new_beacon(struct ap_state *ap, size_t headroom,
> size_t tailroom)
> {
>      struct l_genl_msg *cmd;
>      uint64_t wdev_id =3D netdev_get_wdev_id(ap->netdev);
>      struct l_buf *buf;
>      static const uint8_t bcast_addr[6] =3D {
>          0xff, 0xff, 0xff, 0xff, 0xff, 0xff
>      };
> =

>      if (L_WARN_ON(!ap->started))
>          return;
> =

>      cmd =3D l_genl_msg_new_sized(NL80211_CMD_SET_BEACON, 32);
>      l_genl_msg_append_attr(cmd, NL80211_ATTR_IE, 0, "");
>      l_genl_msg_append_attr(cmd, NL80211_ATTR_IE_PROBE_RESP, 0, "");
>      l_genl_msg_append_attr(cmd, NL80211_ATTR_IE_ASSOC_RESP, 0, "");
> =

>      buf =3D l_genl_msg_append_attr_buf(cmd, NL80211_ATTR_BEACON_HEAD, 0,=
 256);
>      ap_build_beacon_pr_head(ap, MPDU_MANAGEMENT_SUBTYPE_BEACON,
> bcast_addr, buf);
> =

>      buf =3D l_genl_msg_append_attr_buf(cmd, NL80211_ATTR_BEACON_HEAD, 0,=
 256);
>      ap_build_beacon_pr_head(ap, MPDU_MANAGEMENT_SUBTYPE_BEACON,
> bcast_addr, buf);
> =

>      ap->pending_set_beacon =3D cmd;
>      return buf;
> }
> =

> void ap_new_beacon_done(struct ap_state *ap)
> {
>      if (l_genl_family_send(ap->nl80211, ap->pending_set_beacon,
> ap_set_beacon_cb, NULL, NULL))
>          goto done;
> =

>      l_genl_msg_unref(ap->pending_set_beacon);
>      l_error("Issuing SET_BEACON failed");
> done:
>      ap->pending_set_beacon =3D NULL;
> }
> =

> Alternatively, since the P2P IE also needs to be added to all other
> frame types (association, probe response, etc.), the beacon IEs can
> use the same mechanism as I propsed in:
> https://lists.01.org/hyperkitty/list/iwd(a)lists.01.org/thread/MCYQTO54DH=
3GOSFMTVRVUIIORPICFL7K/
> So basically p2p.c calls ap_update_beacon(ap) without passing any
> contents.  This calls
> ap->ops->write_mgmt_frame_ies(MPDU_MANAGEMENT_SUBTYPE_BEACON, buf,
> ap->user_data) and p2p.c synchronously writes the contents into the
> provided l_buf.  It has no chance to give the buffer size to
> preallocate but the buffer is extensible.
> =


Hmm, ok.  Let me re-examine this code path again.  It almost feels like we =
can =

fill-out and save for future use much of the beacon head / tails and not bu=
ild =

them every time.

Regards,
-Denis
--===============3458862629626823402==--

