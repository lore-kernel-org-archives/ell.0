Content-Type: multipart/mixed; boundary="===============1262321751695682242=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 04/13] netconfig: Support IPv6 static configurations
Date: Wed, 27 Apr 2022 17:01:42 -0500
Message-ID: <0f3b0a8c-9fa4-c039-d41e-66e542410693@gmail.com>
In-Reply-To: CAOq732JGL_OGXtiMiCGmC1dV3=-JiOn0Q9NHPV+WPEBB-+Ho5g@mail.gmail.com

--===============1262321751695682242==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/27/22 16:42, Andrew Zaborowski wrote:
> On Wed, 27 Apr 2022 at 16:48, Denis Kenzior <denkenz(a)gmail.com> wrote:
>>>> However, the more general question here is why do we want to store and=
 compute
>>>> the prefix route separately?  Is the assumption here that all addresse=
s use the
>>>> noprefixroute flag?  Wouldn't it be simpler to just have the kernel ha=
ndle this?
>>>
>>> So I think we can do that if we're committing the addresses to the
>>> kernel ourselves.  If we have to delegate it to NM we still need this
>>> code.  In the end I think it's easier to have just one branch here.
>>
>> Explain?  NM doesn't understand the noprefixroute flag?  Just curious.  =
I think
>> we do indeed need to do it as you propose.  See below.
> =

> After some digging my understanding is that NM internally stores the
> address flags bitmap and the IWD backend could set it or clear
> IFA_F_NOPREFIXROUTE on the addresses received from IWD.  But the core
> code doesn't often look at whether IFA_F_NOPREFIXROUTE is set because
> there's a policy in their netconfig code that basically it should be
> always set.  The logic is quite involved but basically NM will set the
> flag when talking to the kernel, and then will autogenerate the subnet
> routes for IPv4 (statically or dynamically assigned) and for IPv6
> static configs.  That means that IWD doesn't need to give NM those
> subnet routes, same as if IFA_F_NOPREFIXROUTE was cleared.

Thanks, that was helpful.

> =

> On the other hand my thinking is that 1. we might want to not shape
> the ell API based on current NM behaviour and might want to add the
> subnet routes at the risk of NM ignoring them or adding duplicates.

I really have no strong feelings one way or the other.  I suspect that unle=
ss we =

can add a metric info directly to the address, we are stuck using noprefixr=
oute =

flag in all cases.

<snip>

> =

> Here are some interesting comments in NM code:
> https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/main/=
src/libnm-platform/nm-platform.c#L5388-5404
> https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/main/=
src/libnm-platform/nm-platform.h#L411-425
> https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/main/=
src/core/nm-l3-config-data.c#L2418-2430
> https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/main/=
src/core/nm-l3-config-data.c#L2457-2465
> =


So they actually try and work around kernels with no 'noprefixroute' flag =

support.  We don't need to worry about this since iwd only works with kerne=
ls =

where this is standard.

>>
>>>
>>> Having the kernel handle the subnet routes is even more obvious for
>>> IPv4 because it works for static as well as DHCP.  For some reason the
>>> IWD code always sets this flag for both IPv4 and IPv6.
>>>
>>
>> I don't recall exactly why we originally added the connected route separ=
ately.
>> I'm pretty sure this resulted in two prefix routes in the routing table =
until I
>> introduced the noprefixroute flag to ell.
>>
>> But I *think* the reason we add a separate connected route, in icmp6 at =
least,
>> is to make sure the metric is applied properly.  If noprefixroute flag i=
sn't
>> set, the kernel will automagically create a new connected route when the=
 address
>> is installed.  But the metric used for this route is the default.
> =

> Ok I didn't know that, and it matches what NM comments say too.  I
> guess this matters because the local subnet needs a higher metric than
> other routes?

It is mostly to deal with multiple interfaces connected to the same subnet.=
  For =

example, you may have wifi + ethernet connected to the same access point.  =
You =

would want the packets to the local subnet to be routed over ethernet (with=
 a =

lower metric) than over WiFi.

Regards,
-Denis
--===============1262321751695682242==--

