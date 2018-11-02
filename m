Content-Type: multipart/mixed; boundary="===============8305414255099573374=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 08/11] tls: Stricter certificate chain verification
Date: Thu, 01 Nov 2018 17:35:08 -0700
Message-ID: <alpine.OSX.2.21.1811011537160.6839@kmannark-mobl1.amr.corp.intel.com>
In-Reply-To: <b9811470-6ccf-b7ba-92ed-4f34a18347e9@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8305414255099573374==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 1 Nov 2018, Denis Kenzior wrote:

> Hi Andrew,
>
> On 11/01/2018 06:54 AM, Andrew Zaborowski wrote:
>> Rewrite tls_cert_verify_certchain to fix a long standing issue where it
>> didn't verify that each certificate in the chain was trusted by the next
>> one.  Since certificates were only being added to the two keyrings and
>> never removed the order in the chain was not being verified.  Now use a
>> single ring and remove the previously added certificates from it once
>> they've been used to show that the next certificate was signed with one
>> of them.  Add lots of comments.
>
> So I actually like this approach a lot.  Few nitpicks:
>
>> ---
>>   ell/tls.c | 206 +++++++++++++++++++++++++++++++++---------------------
>>   1 file changed, 125 insertions(+), 81 deletions(-)
>> =

>> diff --git a/ell/tls.c b/ell/tls.c
>> index fbbc1bf..7f42240 100644
>> --- a/ell/tls.c
>> +++ b/ell/tls.c
>> @@ -2687,27 +2687,99 @@ static const struct pkcs1_encryption_oid {
>>   	},
>>   };
>>   +static struct l_key *tls_cert_verify_root(struct l_key *key,
>> +						struct l_keyring *ring,
>> +						struct l_queue *roots)

Have you considered loading the root certs in to a kernel keyring once =

in l_tls_set_cacert() then keeping it around to reuse?

>> +{
>> +	const struct l_queue_entry *entry;
>> +	unsigned int i, n =3D l_queue_length(roots);
>> +	struct l_key *root_keys[n];
>
> So Marcel will likely hunt you down for VLA usage.  So maybe you want to =

> rethink this.
>
>> +	bool success =3D true;
>> +
>> +	/*
>> +	 * Check that @key is trusted by one of @roots by linking it
>> +	 * to a restricted ring containing only the roots.  If successful
>> +	 * return @key leaving only @key in the keyring.
>> +	 */
>> +
>> +	for (entry =3D l_queue_get_entries(roots), i =3D 0; i < n;
>> +			entry =3D entry->next, i++) {
>> +		const struct tls_cert *root =3D entry->data;
>> +
>> +		root_keys[i] =3D l_key_new(L_KEY_RSA, root->asn1, root->size);
>> +		if (!root_keys[i] || !l_keyring_link(ring, root_keys[i]))
>> +			success =3D false;
>
> So why are we loading the CA keys into the verify ring?  Can't we just lo=
ad =

> all the CA keys into a temporary ring and then remove it when we're done? =

> E.g. the ca ring.

This is possible, but I'm not sure it accomplishes much. Either way you =

still end up deleting all the CA keys, and if you add a temporary ring =

then you have to create and delete that too.

The use case I had in mind was to have a persistent ca_ring that could be =

used to restrict many other short-lived keyrings.

>
>> +	}
>> +
>> +	if (!l_keyring_restrict(ring, L_KEYRING_RESTRICT_ASYM_CHAIN, NULL) ||
>> +			!l_keyring_link(ring, key))
>> +		success =3D false;
>
> And here we could restrict the ring against the ca_ring.  If that succeed=
s, =

> then what we can do is call l_keyring_restrict, this time with last argum=
ent =

> being NULL.  Or is that not possible? Mat?

I'm not 100% sure I'm following Denis here, but you only get one chance to =

call l_keyring_restrict() for a given keyring. So if you restrict against =

ca_ring, you can't change that to NULL later (but you could empty =

ca_ring and get the same effect).

>
>> +
>> +	for (i =3D 0; i < n; i++)
>> +		l_key_free(root_keys[i]);
>> +
>
> Then this just becomes l_keyring_free(ca_ring);

You still have to l_key_free() each root key. The l_keyring tells the =

kernel how to group the keys, but ELL doesn't free its l_key objects based =

on the keyring(s) they are in.

>
>> +	if (success)
>> +		return key;
>> +
>> +	l_key_free(key);
>> +	return NULL;
>> +}
>> +
>>   static void tls_key_cleanup(struct l_key **p)
>>   {
>> -	l_key_free_norevoke(*p);
>> +	l_key_free(*p);
>>   }
>>   -static bool tls_cert_link(struct tls_cert *cert, struct l_keyring *ri=
ng)
>
> <snip>
>
>> @@ -2772,43 +2840,19 @@ static void tls_keyring_cleanup(struct l_keyring =

>> **p)
>>   bool tls_cert_verify_certchain(struct tls_cert *certchain,
>>   				struct l_queue *ca_certs)
>>   {
>> -	L_AUTO_CLEANUP_VAR(struct l_keyring *, ca_ring, tls_keyring_cleanup);
>>   	L_AUTO_CLEANUP_VAR(struct l_keyring *, verify_ring,
>> -				tls_keyring_cleanup);
>> +				tls_keyring_cleanup) =3D l_keyring_new();
>> +	struct l_key *trusted;
>
> This function is so simple I would consider dropping the L_AUTO_CLEANUP_V=
AR =

> completely.

The auto cleanup stuff was handy when there were many different 'return' =

statements, but with the simplified version of this function I agree with =

Denis.

>
>>   -	ca_ring =3D NULL;
>> -
>> -	verify_ring =3D l_keyring_new();
>>   	if (!verify_ring)
>>   		return false;
>>   -	/*
>> -	 * If CA cert(s) were supplied, restrict verify_ring now so
>> -	 * everything else in certchain is validated against the CA(s).
>> -	 * Otherwise, verify_ring will be restricted after the root of
>> -	 * certchain is added to verify_ring by
>> -	 * tls_cert_verify_with_keyring().
>> -	 */
>> -	if (ca_certs) {
>> -		const struct l_queue_entry *entry;
>> -
>> -		ca_ring =3D l_keyring_new();
>> -		if (!ca_ring)
>> -			return false;
>> -
>> -		for (entry =3D l_queue_get_entries(ca_certs); entry;
>> -				entry =3D entry->next)
>> -			if (!tls_cert_link(entry->data, ca_ring))
>> -				return false;
>> -
>> -		if (!l_keyring_restrict(verify_ring,
>> -					L_KEYRING_RESTRICT_ASYM_CHAIN,
>> -					ca_ring))
>> -			return false;
>> -	}
>> +	trusted =3D tls_cert_verify_with_keyring(certchain, verify_ring, =

>> ca_certs);
>> +	if (!trusted)
>> +		return false;
>>   -	return tls_cert_verify_with_keyring(certchain, verify_ring, ca_certs,
>> -						ca_ring);
>> +	l_key_free(trusted);
>> +	return true;
>>   }
>>     void tls_cert_free_certchain(struct tls_cert *cert)
>> =

>

It seems like the implementation is made more complicated by the fact that =

the cert list is a singly-linked list starting with the end-entity cert =

(which we then follow toward the root using the issuer pointers), while in =

order to verify we need to link keys to the restricted keyring starting =

from the root end of the chain.

If we know that it's a linear cert chain, the code could be simplified by =

making the cert chain a doubly-linked list that could be walked in the =

other direction. That would eliminate the recursion, leading to an =

implementation that looks more like this:

1. Create a keyring
2. Load it with the root certs
3. Try to load the first cert in the chain (from the root-facing end)
4. If that works, clear the root certs
5. Try to load the next cert in the chain
6. If that works, clear the previous cert
7. Repeat 5-6 until you get to the end-entity cert

That's the behavior of this patch (from the perspective of the kernel), =

but it's hard to see because recursive calls are used to follow the issuer =

chain toward the root first, then the keyring loads are attempted as the =

stack gets unwound.

(I realize the recursive code structure is inherited from my earlier =

implementation :) )


As Denis pointed out above, it would be convenient to add and remove the =

root certs as a group. The kernel lets keyrings contain keyrings. A =

restricted keyring R will search for signing keys in the trusted keyring T =

(if it wasn't NULL), and within R itself. If R "contains" a link to =

another keyring A, it will search T, R, and A for signing keys.

If we add l_keyring_link_nested(keyring, nested_keyring) to ELL, then you =

could have a persistent ca_ring that is temporarly linked to the verify =

ring to check the first cert, then ca_ring gets unlinked in a single =

operation when you want to check the second cert.


--
Mat Martineau
Intel OTC

--===============8305414255099573374==--

