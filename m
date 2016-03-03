Content-Type: multipart/mixed; boundary="===============0383724461225052253=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 1/2] key: Add basic keystore support
Date: Thu, 03 Mar 2016 13:10:06 -0800
Message-ID: <alpine.OSX.2.20.1603031011210.922@mjmartin-mac01.wa.intel.com>
In-Reply-To: <56D7476D.7050604@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0383724461225052253==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Wed, 2 Mar 2016, Denis Kenzior wrote:

<snip>

>>> Another issue is whether userspace has any way of obtaining
>>> information on how large the payload is.  E.g. what size len to pass
>>> in.  Should we track the key size or extract it out somehow?
>>> =

>> =

>> The KEYCTL_READ syscall lets us get the length without copying anything
>> if a zero-length buffer is passed in. I think it's best to expose that
>> (l_key_get_size()), since there may be keys that we ask the kernel to
>> generate for us.
>> =

>
> Yes, I think something like this is needed.
>
> Are there kernel keyctl internal enumerations for key types as well? E.g.=
 how =

> do we know that a certificate loaded by keyctl is a private key vs a publ=
ic =

> key?
>

Asymmetric keys have a "subtype", but there's only one right now (x509). =

When an asymmetric key is created, it has a list of parsers to attempt, =

and a successful parser will set the subtype appropriately. After the key =

is created, KEYCTL_DESCRIBE will return a string which contains the key =

type and subtype information.

User keys are just a blob.

This leads me to think that the type should be retrieved from the kernel =

dynamically, similar to how the size is handled.

>>>> +
>>>> +    *len =3D copied;
>>>> +    return true;
>>>> +}
>>>> +
>>>> +LIB_EXPORT bool l_key_get_type(struct l_key *key, enum l_key_type
>>>> *type)
>>> =

>>> We avoided having to deal with this type of situation where an enum
>>> needs to be extracted back out of an instance.  Some may like doing
>>> something like:
>>> =

>>> enum l_key_type l_key_get_type(struct l_key *key) better.  However,
>>> doing it this way would require us to introduce an _INVALID enum
>>> value.  Not sure which one is better/worse.
>>> =

>> =

>> We think very much alike here! I considered both options but I didn't
>> see other examples of the _INVALID approach, so I went with the bool
>> return to handle the error case and figured we could discuss the
>> alternatives.
>> =

>> Using an _INVALID enum would be less awkward in the common case, where
>> the caller would check to see if the type matched an expected value.
>> Returning a bool means the caller has to check both the boolean return
>> value and (if that is 'true') the retrieved type.
>> =

>> The use case I envisioned is that l_keys will be passed to other APIs,
>> like cipher. The specific cipher implementation would check the expected
>> key type before trying to use it. If we instead opt to skip that kind of
>> check and let the cipher operation fail if they key isn't applicable,
>> then we can remove l_key_type altogether.
>
> So looking at the key_type enumeration again, I'm still a bit unsure of t=
he =

> real-life usage.
>
> E.g. for Diffie-Hellman, we want something like:
>
> l_getrandom(key, size);
> private =3D l_key_new(L_KEY_DH_PRIVATE, key, size);
> prime =3D l_key_new(??, prime, size);
> generator =3D l_key_new(??, generator, size);
> public =3D l_key_new_dh_public(generator, private, prime);
>
> peer_public =3D l_key_new(L_KEY_DH_PUBLIC, peer_key, peer_key_size);
> shared_secret =3D l_key_new_dh_shared(peer_public, private, prime);
>
> Note that the implementation of dh_shared and dh_public are (mathematical=
ly) =

> the same, just the expected input key types might be different.

My current DH implementation in the kernel has separate keyctl commands =

for deriving the public key and shared secret (with the internal =

implementation sharing the common math and key handling), but I'm going to =

change that to just one KEYCTL_DH_COMPUTE command. The user then gets the =

public key by passing in the generator key id, and the shared secret by =

passing in the peer public key.

>
> What key type do we use for prime and generator?
> Do we really need to make the distinction between private / public types?=
  If =

> the types are dropped above, not much of value is lost...

On the kernel side, they're all "user" keys =

(prime/generator/public/private), since the asymmetric type only handles =

x509 format.

There isn't much value in tracking the key types for DH. The motivation =

has more to do with asymmetric ciphers. When creating a new key in the =

kernel, a type string must be specified ("user", "asymmetric", etc.), and =

the enumerations would map to the appropriate kernel key type string. =

However, it's sufficient to have more general types like L_KEY_RAW and =

L_KEY_ASYMMETRIC. Sound like a better approach?


Mat


--===============0383724461225052253==--

