Content-Type: multipart/mixed; boundary="===============5901859046435216619=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] netlink: Allow command handler to use l_netlink_cancel
Date: Tue, 02 Mar 2021 17:29:50 -0600
Message-ID: <5714469c-3d54-b9f5-6b98-07e726767eeb@gmail.com>
In-Reply-To: <CAOq732KjYnE2xgB26OdeM3QznVoBbq6RXuhC8Wg1Ea7JBJFOxg@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5901859046435216619==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew

On 3/2/21 3:30 PM, Andrew Zaborowski wrote:
> On Tue, 2 Mar 2021 at 17:35, Denis Kenzior <denkenz@gmail.com> wrote:
>>> In the IWD AP case I want to cancel a dump command which I think is
>>> already handled correctly, but if the API can be made more robust then
>>> I think it's an improvement.  There can be complicated code paths
>>> where you destroy an object that owns the netlink command as a result
>>> of the command response.
>>
>> Sure, I buy the more robust argument, though I still wonder how one woul=
d even
>> get into such a state on purpose.  But the last sentence seems to be han=
dwaving?
> =

> Well, in the AP code we're actually careful to reset e.g.
> ap->rtnl_add_cmd to 0 at the beginning of the reply handler but if we
> were resetting it any later we'd be affected by this.
> =


Hmm... This is pretty typical pattern for when one doesn't provide a destro=
y =

callback.  I'm not sure I understand what you're trying to convey here...?

Are you trying to stop callbacks mid-dump or ?

>>    So did you somehow trigger this condition or just fixing ghost bugs?
> =

> I was only checking the code to see if it was safe to cancel the dump
> command the way I did it in my IWD patchset.  It seemed to be safe for
> dump commands but not for regular commands.

Yes, but *why* would you use l_netlink_cancel for the command when you're =

already in the handler for that exact same command?

> =

> The normal sequence is this:
> 1. l_netlink_send call
> 2. handler callback
> 3. destroy callback
> =

> After 3. I'd consider it wrong to call l_netlink_cancel() with the
> original ID because you'd be risking cancelling an unrelated command
> (there's no guarantee that the ID wasn't re-used since), but until 3.
> I think it should be made safe.

I can't really imagine why anyone would invoke l_netlink_cancel in a callba=
ck. =

Not saying we shouldn't allow this, but the use case is still a mystery to =
me?

Also, we sort of cheat in many places and assume that only a single message=
 will =

be sent for certain commands.  Underneath, there's no real difference betwe=
en a =

dump and a non-dump.  In fact the kernel might (someday) choose to send mul=
tiple =

messages as a reply.  The only way you know that you're done (for netlink/g=
enl =

at least) is after the destroy callback has been called.  The callback itse=
lf =

has no way of knowing whether it is a single-part or multi-part message...

Regards,
-Denis
--===============5901859046435216619==--

