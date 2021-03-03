Content-Type: multipart/mixed; boundary="===============8117670006574429942=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] netlink: Allow command handler to use l_netlink_cancel
Date: Wed, 03 Mar 2021 01:02:17 +0100
Message-ID: <CAOq732+BnL-cS8zGz2890wVe2uHMegi0gDxvCTK2CYTRmrQ4xw@mail.gmail.com>
In-Reply-To: <5714469c-3d54-b9f5-6b98-07e726767eeb@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8117670006574429942==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Wed, 3 Mar 2021 at 00:29, Denis Kenzior <denkenz@gmail.com> wrote:
> On 3/2/21 3:30 PM, Andrew Zaborowski wrote:
> > On Tue, 2 Mar 2021 at 17:35, Denis Kenzior <denkenz@gmail.com> wrote:
> >>> In the IWD AP case I want to cancel a dump command which I think is
> >>> already handled correctly, but if the API can be made more robust then
> >>> I think it's an improvement.  There can be complicated code paths
> >>> where you destroy an object that owns the netlink command as a result
> >>> of the command response.
> >>
> >> Sure, I buy the more robust argument, though I still wonder how one wo=
uld even
> >> get into such a state on purpose.  But the last sentence seems to be h=
andwaving?
> >
> > Well, in the AP code we're actually careful to reset e.g.
> > ap->rtnl_add_cmd to 0 at the beginning of the reply handler but if we
> > were resetting it any later we'd be affected by this.
> >
>
> Hmm... This is pretty typical pattern for when one doesn't provide a dest=
roy
> callback.  I'm not sure I understand what you're trying to convey here...?
>
> Are you trying to stop callbacks mid-dump or ?

Yes, in the dump case the use case is pretty obvious -- once you've
received the fragment you were interested in (in my case, I dump IPv4
addresses and I'm interested in one specific ifindex), if you can
cancel the command you don't have to keep a flag that tells you to
ignore further callbacks.  And if you need to destroy the object (e.g.
stop the AP) based on the data you received, you're also free to do
this.

In the non-dump case I see the utility of this change mainly in the
situation where, within the callback, you decide you want to tear-down
the object (e.g. stop the AP), like I said already.  If you're not
allowed to cancel the command at that point, you basically need
reference counting so that you can avoid crashing in your destroy
handler.  And in that case I'd say we should have at least a warning
about this limitation somewhere.

>
> >>    So did you somehow trigger this condition or just fixing ghost bugs?
> >
> > I was only checking the code to see if it was safe to cancel the dump
> > command the way I did it in my IWD patchset.  It seemed to be safe for
> > dump commands but not for regular commands.
>
> Yes, but *why* would you use l_netlink_cancel for the command when you're
> already in the handler for that exact same command?
>
> >
> > The normal sequence is this:
> > 1. l_netlink_send call
> > 2. handler callback
> > 3. destroy callback
> >
> > After 3. I'd consider it wrong to call l_netlink_cancel() with the
> > original ID because you'd be risking cancelling an unrelated command
> > (there's no guarantee that the ID wasn't re-used since), but until 3.
> > I think it should be made safe.
>
> I can't really imagine why anyone would invoke l_netlink_cancel in a call=
back.
> Not saying we shouldn't allow this, but the use case is still a mystery t=
o me?
>
> Also, we sort of cheat in many places and assume that only a single messa=
ge will
> be sent for certain commands.  Underneath, there's no real difference bet=
ween a
> dump and a non-dump.  In fact the kernel might (someday) choose to send m=
ultiple
> messages as a reply.  The only way you know that you're done (for netlink=
/genl
> at least) is after the destroy callback has been called.  The callback it=
self
> has no way of knowing whether it is a single-part or multi-part message...

Oh right, the dump/non-dump distinction in my example is based on the
current rtnl behavior.

Best regards
--===============8117670006574429942==--

