Content-Type: multipart/mixed; boundary="===============0933959236560653605=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 07/17] netconfig: Use an internal rtnl socket for
 l_netconfig_apply_rtnl
Date: Thu, 19 May 2022 16:28:36 -0500
Message-ID: <522021c7-6b24-674c-f139-832624217ff0@gmail.com>
In-Reply-To: CAOq732+u2uG9t6eikhZWkaqV7UEc3DLO6ox7fP3J718N2KvNwQ@mail.gmail.com

--===============0933959236560653605==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 5/19/22 15:53, Andrew Zaborowski wrote:
> On Thu, 19 May 2022 at 22:28, Denis Kenzior <denkenz(a)gmail.com> wrote:
>>> Makes sense.  How about using a global rtnl object for all of the
>>> l_netconfig objects?  Do you still prefer that it be passed from
>>> outside?
>>
>> I have no real preference on whether it is passed in from the outside vs=
 not.
>> But, there's another thing to consider here.  Today the call to l_foo_se=
t_rtnl
>> is used determine whether the dhcp/icmp/dhcp6 object should set everythi=
ng up
>> directly vs letting the outside layer do this.  With l_netconfig I don't=
 think
>> this is a problem per se, but you should consider the other classes when=
 you
>> design this.
> =

> Right but with l_netconfig you make this choice by either calling
> l_netconfig_apply_rtnl or not, and you shouldn't call l_foo_set_rtnl
> on the underlying dhcp/icmp objects.
> =


Sure, but are you assuming we will not have any further classes using rtnl =

besides netconfig?

>>
>> We can start by trying to come up with a nice ell API for obtaining the
>> singleton rtnl object and go from there.
> =

> The global rtnl object I meant is to be used only by l_netconfig
> instances so there's no need for a getter, or I'm misunderstanding
> what you're saying.
> =


We use rtnl all over the place in iwd, like netdev, p2p, ap, etc.  All thes=
e + =

netconfig should share the same one.

Regards,
-Denis
--===============0933959236560653605==--

