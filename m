Content-Type: multipart/mixed; boundary="===============1208998892176338686=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/13] net: Add l_net_clear_host_bits utility
Date: Fri, 13 May 2022 09:15:45 -0500
Message-ID: <913bb777-2b72-47e8-7b57-de3de66b3af4@gmail.com>
In-Reply-To: CAOq732+eiU7dB=8ZDrej9BkaiTKv_U_18Y5gz=2=UYUxosYWYA@mail.gmail.com

--===============1208998892176338686==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>>> +static inline void l_net_clear_host_bits(uint8_t *address, uint8_t pre=
fix_len,
>>> +                                             uint8_t bytes)
>>
>> I'm not super excited about the naming.  What about l_net_prefix_from_ad=
dress()?
> =

> Ok, I guess host mask is an IPv4 term with the v6 term being interface
> ID.  l_net_prefix_from_address sounds good, or how about

You could also add a separate v4/v6 version instead?  Your set only uses th=
is =

for v6 right now, and you'd be able to drop the bytes parameter?  You could=
 also =

use a static buffer for the return value (or simply a uint32 for the v4 ver=
sion) =

and make address in-only instead of in-out.

> l_net_mask_prefix?

The use of l_net_prefix_from_address() would make it very clear what is =

happening in netconfig_add_v6_static_address_routes().  l_net_mask_prefix b=
etter =

suites the usage in patch 13, though your original naming also works well h=
ere.

Question is, if you're already sanitizing & dropping the address portion in =

netconfig_add_v6_static_routes(), do you even need the use of =

l_net_clear_host_bits in patch 13?

Anyhow, maybe the outcome from this discussion is to just put this into =

net-private.h for now and we can agree on the name later if this function n=
eeds =

to be exposed into public API.

Regards,
-Denis
--===============1208998892176338686==--

