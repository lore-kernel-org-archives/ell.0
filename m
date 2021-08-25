Content-Type: multipart/mixed; boundary="===============0638488973244907851=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] rtnl: Add neighbor discovery utilities
Date: Wed, 25 Aug 2021 17:45:13 -0500
Message-ID: <e4662281-c4f7-0b3e-485c-69243a6f0104@gmail.com>
In-Reply-To: <CAOq732KRGfd=PWeOqRUNbmb6VarFsRx+7=riBbpA-dwpxxtpuQ@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0638488973244907851==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>> I was hoping to avoid using in_addr / in6_addr in the public API, but ma=
ybe that
>> would be the lesser evil option than 'const uint8_t *'.  Or just use
>> l_rtnl_address for everything.
> =

> My preference would be for in_addr / in6_addr, l_rtnl_address seems to
> be overkill for a wrapper for a 32-bit value.

I wouldn't actually mind seeing more context on how you're using these.  In =

theory you would need the rtnl address anyway, unless you're using this wit=
hin =

dhcp server classes.  In which case you can provide a private API as well.

> =

> The only evil aspect of these that I can see is uint32_t's endianness
> ambiguity (something similar to kernel's __be32 would have been
> better) but the simplicity is a big advantage.
> =


Use of struct in_addr would imply network order is being used.  Same as =

inet_ntoa/inet_ntop, etc.

>>
>>> +                                     l_rtnl_neighbour_get_cb_t cb,
>>> +                                     void *user_data,
>>> +                                     l_netlink_destroy_func_t destroy);
>>> +uint32_t l_rtnl_neighbour_get_addr_hwaddr(struct l_netlink *rtnl, int =
ifindex,
>>> +                                     const struct l_rtnl_address *addr,
>>> +                                     l_rtnl_neighbour_get_cb_t cb,
>>> +                                     void *user_data,
>>> +                                     l_netlink_destroy_func_t destroy);
>>> +uint32_t l_rtnl_neighbour_set_ipv4_hwaddr(struct l_netlink *rtnl, int =
ifindex,
>>> +                                     uint32_t addr, const uint8_t *hwa=
ddr,
>>
>> You're making an assumption that hwaddr is always 6?  That will not real=
ly be
>> true long term.  Might as well take care of this now.
> =

> I am, but if the address is not 6 bytes the user will know it based on
> the ifindex too.  We can be more explicit and include a length though.

User might, but API implementation doesn't.  How does the implementation of=
 this =

function know that ifindex is for a device that uses 8 byte hardware addres=
s? =

ifindex is just an int as far as it is concerned.  So unless you're going t=
o =

introduce a netdev abstraction, hardware length would be needed here at som=
e point.

Regards,
-Denis
--===============0638488973244907851==--

