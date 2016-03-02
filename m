Content-Type: multipart/mixed; boundary="===============6360546222289871058=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] key: Add basic keystore support
Date: Wed, 02 Mar 2016 14:05:01 -0600
Message-ID: <56D7476D.7050604@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1603020914380.2527@tjha-mobl.amr.corp.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6360546222289871058==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

<snip>

 >>> +
>>> +    copied =3D kernel_read_key(key->serial, payload, *len);
>>> +
>>> +    if (copied < 0 || (size_t)copied > *len)
>>> +        return false;
>>
>> So what is the behavior of the kernel syscall here?  How can copied
>> ever be greater than len?
>>
>
> The syscall return value is the total length of the key, which may be
> larger than the buffer passed to the kernel. I will change "copied" to
> "keylen".
>

Sounds good.

>> Another issue is whether userspace has any way of obtaining
>> information on how large the payload is.  E.g. what size len to pass
>> in.  Should we track the key size or extract it out somehow?
>>
>
> The KEYCTL_READ syscall lets us get the length without copying anything
> if a zero-length buffer is passed in. I think it's best to expose that
> (l_key_get_size()), since there may be keys that we ask the kernel to
> generate for us.
>

Yes, I think something like this is needed.

Are there kernel keyctl internal enumerations for key types as well? =

E.g. how do we know that a certificate loaded by keyctl is a private key =

vs a public key?

>>> +
>>> +    *len =3D copied;
>>> +    return true;
>>> +}
>>> +
>>> +LIB_EXPORT bool l_key_get_type(struct l_key *key, enum l_key_type
>>> *type)
>>
>> We avoided having to deal with this type of situation where an enum
>> needs to be extracted back out of an instance.  Some may like doing
>> something like:
>>
>> enum l_key_type l_key_get_type(struct l_key *key) better.  However,
>> doing it this way would require us to introduce an _INVALID enum
>> value.  Not sure which one is better/worse.
>>
>
> We think very much alike here! I considered both options but I didn't
> see other examples of the _INVALID approach, so I went with the bool
> return to handle the error case and figured we could discuss the
> alternatives.
>
> Using an _INVALID enum would be less awkward in the common case, where
> the caller would check to see if the type matched an expected value.
> Returning a bool means the caller has to check both the boolean return
> value and (if that is 'true') the retrieved type.
>
> The use case I envisioned is that l_keys will be passed to other APIs,
> like cipher. The specific cipher implementation would check the expected
> key type before trying to use it. If we instead opt to skip that kind of
> check and let the cipher operation fail if they key isn't applicable,
> then we can remove l_key_type altogether.

So looking at the key_type enumeration again, I'm still a bit unsure of =

the real-life usage.

E.g. for Diffie-Hellman, we want something like:

l_getrandom(key, size);
private =3D l_key_new(L_KEY_DH_PRIVATE, key, size);
prime =3D l_key_new(??, prime, size);
generator =3D l_key_new(??, generator, size);
public =3D l_key_new_dh_public(generator, private, prime);

peer_public =3D l_key_new(L_KEY_DH_PUBLIC, peer_key, peer_key_size);
shared_secret =3D l_key_new_dh_shared(peer_public, private, prime);

Note that the implementation of dh_shared and dh_public are =

(mathematically) the same, just the expected input key types might be =

different.

What key type do we use for prime and generator?
Do we really need to make the distinction between private / public =

types?  If the types are dropped above, not much of value is lost...

Regards,
-Denis

--===============6360546222289871058==--

