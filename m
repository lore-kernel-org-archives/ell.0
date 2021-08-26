Content-Type: multipart/mixed; boundary="===============7035417774673130150=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] rtnl: Add neighbor discovery utilities
Date: Thu, 26 Aug 2021 08:50:38 -0500
Message-ID: <c3c98be9-f853-44ca-e3df-1ea154a54af8@gmail.com>
In-Reply-To: <CAOq732Kxtk3=mLE_gSDvadF9ZB3FRP=cV8N5fjM+em436oQq0Q@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7035417774673130150==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>> Use of struct in_addr would imply network order is being used.  Same as
>> inet_ntoa/inet_ntop, etc.
> =

> Right, and same as __be32.  __be32 has the advantage that it's not a
> struct so, 1. you know its size and contents and can pass its pointer
> directly to, say, an attribute builder without looking up internal
> structures, 2. don't need to convert to/from it by assigning cryptic
> field names, 3. can pass it as parameter.

Some of what you say isn't really correct.  Look at the signature of inet_n=
toa =

for example.

You're arguing for use of __be32 because you store ipv4 addresses as uints.=
  I =

get that.  But that doesn't help you with ipv6 and there is already a well =

defined structure to represent an ipv4 address.

Anyhow, given how you're planning to use this, I'd just adopt a signature =

similar to inet_ntop.  Something like:

l_rtnl_neighbor_set_hwaddr(rtnl, ifindex, int family, const void *, const =

uint8_t *hwaddr, size_t hwaddr_len, cb, user_data, destroy)

Also, US spelling of 'neighbor' would be preferred.

Regards,
-Denis
--===============7035417774673130150==--

