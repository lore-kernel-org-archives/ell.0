Content-Type: multipart/mixed; boundary="===============1907570667540081366=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/11] net: Add l_net_subnet_matches
Date: Mon, 18 Apr 2022 12:04:32 -0500
Message-ID: <8ce78b6d-b4f1-d5ca-d903-77a46ed61e46@gmail.com>
In-Reply-To: CAOq732JYG1Ld4OLboAvWGZZYbT=sQNB4xPTnvbzWYTJM3RXsGw@mail.gmail.com

--===============1907570667540081366==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/18/22 12:01, Andrew Zaborowski wrote:
> Hi Denis,
> =

> On Mon, 18 Apr 2022 at 18:34, Denis Kenzior <denkenz(a)gmail.com> wrote:
>>> +     return !bits ||
>>> +             ((((const uint8_t *) a)[bytes] ^ ((const uint8_t *) b)[by=
tes]) &
>>> +              (0xff00u >> bits)) =3D=3D 0;
>>
>> There were a bit too many '()' for my liking.  I moved the casts to the =
variable
>> declaration block above which ended up being the same number of lines an=
d looked
>> a bit cleaner.
> =

> Do we want to do the array[bytes] access after the !bits check to
> avoid accessing the byte after the end of the address for weird cases
> where the prefix_len is exactly the number of bits in the two buffers
> we received.

Aren't we guaranteed to be operating on 4 byte values?  So unless prefix_le=
n =3D=3D =

32, I don't see how we could perform out-of-bounds access?

Regards,
-Denis
--===============1907570667540081366==--

