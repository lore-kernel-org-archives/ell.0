Content-Type: multipart/mixed; boundary="===============4447347709481665241=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/11] net: Add l_net_subnet_matches
Date: Mon, 18 Apr 2022 12:59:59 -0500
Message-ID: <d347beb5-ac09-c641-bb62-b919da565d9f@gmail.com>
In-Reply-To: CAOq732JnYMhs3rLhSYspyoKW53Ef+-DXH0g0oNaCTq1WF+FMXg@mail.gmail.com

--===============4447347709481665241==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/18/22 12:21, Andrew Zaborowski wrote:
> On Mon, 18 Apr 2022 at 19:04, Denis Kenzior <denkenz(a)gmail.com> wrote:
>> On 4/18/22 12:01, Andrew Zaborowski wrote:
>>>> There were a bit too many '()' for my liking.  I moved the casts to th=
e variable
>>>> declaration block above which ended up being the same number of lines =
and looked
>>>> a bit cleaner.
>>>
>>> Do we want to do the array[bytes] access after the !bits check to
>>> avoid accessing the byte after the end of the address for weird cases
>>> where the prefix_len is exactly the number of bits in the two buffers
>>> we received.
>>
>> Aren't we guaranteed to be operating on 4 byte values?  So unless prefix=
_len =3D=3D
>> 32, I don't see how we could perform out-of-bounds access?
> =

> 4 or 16 bytes, in theory yes but I can imagine someone trying to use a

IPv6 doesn't really use subnets like IPv4 does though?  I'm not even sure t=
his =

function would be relevant for IPv6?  Is it?  Looks like we do this for FIL=
S, =

but I'm not even certain that the check in ie.c in iwd is correct.

> buffer of just long enough for the subnet address, or passing a
> prefix_len of 32 / 128 for things like a route prefix.

Well, prefix_len of 32/128 implies point-to-point routing (and even 31 in I=
Pv4 =

would be special).  So I'm not sure calling this function with such prefixe=
s =

even makes sense?

Regards,
-Denis
--===============4447347709481665241==--

