Content-Type: multipart/mixed; boundary="===============0219045316915039276=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] netlink: Allow command handler to use l_netlink_cancel
Date: Tue, 02 Mar 2021 22:30:04 +0100
Message-ID: <CAOq732KjYnE2xgB26OdeM3QznVoBbq6RXuhC8Wg1Ea7JBJFOxg@mail.gmail.com>
In-Reply-To: <7219a940-0eb2-11cc-3134-f6b8807c7d3c@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0219045316915039276==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Tue, 2 Mar 2021 at 17:35, Denis Kenzior <denkenz@gmail.com> wrote:
> > In the IWD AP case I want to cancel a dump command which I think is
> > already handled correctly, but if the API can be made more robust then
> > I think it's an improvement.  There can be complicated code paths
> > where you destroy an object that owns the netlink command as a result
> > of the command response.
>
> Sure, I buy the more robust argument, though I still wonder how one would=
 even
> get into such a state on purpose.  But the last sentence seems to be hand=
waving?

Well, in the AP code we're actually careful to reset e.g.
ap->rtnl_add_cmd to 0 at the beginning of the reply handler but if we
were resetting it any later we'd be affected by this.

>   So did you somehow trigger this condition or just fixing ghost bugs?

I was only checking the code to see if it was safe to cancel the dump
command the way I did it in my IWD patchset.  It seemed to be safe for
dump commands but not for regular commands.

The normal sequence is this:
1. l_netlink_send call
2. handler callback
3. destroy callback

After 3. I'd consider it wrong to call l_netlink_cancel() with the
original ID because you'd be risking cancelling an unrelated command
(there's no guarantee that the ID wasn't re-used since), but until 3.
I think it should be made safe.

Best regards
--===============0219045316915039276==--

