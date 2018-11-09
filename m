Content-Type: multipart/mixed; boundary="===============7601861212748044711=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/5] cert: Add cert.c for certificate types and routines
Date: Thu, 08 Nov 2018 19:05:53 -0600
Message-ID: <48d3bc46-929a-3b8e-5e91-f96aab451da5@gmail.com>
In-Reply-To: <CAOq732J9TqrhKEw4qxtsjJ+9fSAHfF5FY3qHTZ9QtdQ==ri+Bg@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7601861212748044711==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> Yep, that's the downside of this approach, the up side is less code
> for both the implementation and the user.  I'd understood you actually
> preferred this approach but I'll happily switch to having separate
> types.

When have I ever preferred less code in favor of less readability? :)

Anyhow, I rather have something with clear semantics even if it costs a =

bit more code size.

>>> +
>>> +     if (i =3D=3D L_ARRAY_SIZE(pkcs1_encryption_oids))
>>> +             cert->pubkey_type =3D L_CERT_KEY_UNKNOWN;
>>> +     else
>>> +             cert->pubkey_type =3D pkcs1_encryption_oids[i].key_type;
>>
>> It is unclear to me how you're making sure pubkey_type enumeration
>> actually matches up to key_type.  There's no initializer on the enum, so
>> the compiler can be free to choose anything?
> =

> Sorry, I don't understand what you mean here.  The left side of the
> '=3D' is of the same type as the right side.  The right side will always
> be L_CERT_KEY_RSA for now.
> =


Yes, ignore me.  I misread what this was doing.

>> and consider dropping link_issuer completely.  Just build a certchain
>> from the raw data directly, perhaps as a private constructor for now.
> =

> Could also just do:
> =

> struct l_certchain {
>          struct l_queue *certs;
> };
> =

> for simplicity.  We only have one use case for iterating from root to
> leaf so we can reverse the queue at that time.  We maybe simply want
> two public methods, l_certchain_foreach_from_root and
> l_certchain_foreach_from_leaf.

Yes but a quite common one.  And you still need to memdup the l_cert =

when you add it to the certchain, so maybe just do it right.

> =

> As for the constructor we already need to parse two different "raw"
> formats both of which are defined in pretty distant specs so I don't
> think cert.c should know them, I'd rather have a l_certchain_link_cert
> or similar.

You can also just implement the two constructors directly here, since =

they're the most common case anyway.

>>
>> So we're still doing the recursive verify.  It might makes things
>> clearer if you added l_cert* stub classes first.  Then a separate commit
>> moving the recursive implementation from tls.c to cert.c.
> =

> Ugh, that would be a commit for each method being moved?  There isn't
> really much to review if we're just moving the code, however not
> breaking TLS between the multiple commits could be really complicated.

Still much clearer / preferable than adding a brand new version and then =

removing the old one.  And don't worry about breaking compilation too =

much.  We can handwave that away as long as the entire series makes =

things happy.

Regards,
-Denis

--===============7601861212748044711==--

