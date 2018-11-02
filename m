Content-Type: multipart/mixed; boundary="===============3882513614425730657=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 08/11] tls: Stricter certificate chain verification
Date: Thu, 01 Nov 2018 19:55:15 -0500
Message-ID: <d83e1648-de36-8864-3232-0e243532b98e@gmail.com>
In-Reply-To: <alpine.OSX.2.21.1811011537160.6839@kmannark-mobl1.amr.corp.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3882513614425730657==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 11/01/2018 07:35 PM, Mat Martineau wrote:
> On Thu, 1 Nov 2018, Denis Kenzior wrote:
> =

>> Hi Andrew,
>>
>> On 11/01/2018 06:54 AM, Andrew Zaborowski wrote:
>>> Rewrite tls_cert_verify_certchain to fix a long standing issue where it
>>> didn't verify that each certificate in the chain was trusted by the next
>>> one.=C2=A0 Since certificates were only being added to the two keyrings=
 and
>>> never removed the order in the chain was not being verified.=C2=A0 Now =
use a
>>> single ring and remove the previously added certificates from it once
>>> they've been used to show that the next certificate was signed with one
>>> of them.=C2=A0 Add lots of comments.
>>
>> So I actually like this approach a lot.=C2=A0 Few nitpicks:
>>
>>> ---
>>> =C2=A0 ell/tls.c | 206 +++++++++++++++++++++++++++++++++---------------=
------
>>> =C2=A0 1 file changed, 125 insertions(+), 81 deletions(-)
>>>
>>> diff --git a/ell/tls.c b/ell/tls.c
>>> index fbbc1bf..7f42240 100644
>>> --- a/ell/tls.c
>>> +++ b/ell/tls.c
>>> @@ -2687,27 +2687,99 @@ static const struct pkcs1_encryption_oid {
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 },
>>> =C2=A0 };
>>> =C2=A0 +static struct l_key *tls_cert_verify_root(struct l_key *key,
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 struc=
t l_keyring *ring,
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 struc=
t l_queue *roots)
> =

> Have you considered loading the root certs in to a kernel keyring once =

> in l_tls_set_cacert() then keeping it around to reuse?
> =


Exactly.  This is ultimately what we want: to load root CAs once and =

reuse them between multiple connections.  So the CA keyring needs to be =

reusable.

>>> +{
>>> +=C2=A0=C2=A0=C2=A0 const struct l_queue_entry *entry;
>>> +=C2=A0=C2=A0=C2=A0 unsigned int i, n =3D l_queue_length(roots);
>>> +=C2=A0=C2=A0=C2=A0 struct l_key *root_keys[n];
>>
>> So Marcel will likely hunt you down for VLA usage.=C2=A0 So maybe you wa=
nt =

>> to rethink this.
>>
>>> +=C2=A0=C2=A0=C2=A0 bool success =3D true;
>>> +
>>> +=C2=A0=C2=A0=C2=A0 /*
>>> +=C2=A0=C2=A0=C2=A0=C2=A0 * Check that @key is trusted by one of @roots=
 by linking it
>>> +=C2=A0=C2=A0=C2=A0=C2=A0 * to a restricted ring containing only the ro=
ots.=C2=A0 If successful
>>> +=C2=A0=C2=A0=C2=A0=C2=A0 * return @key leaving only @key in the keyrin=
g.
>>> +=C2=A0=C2=A0=C2=A0=C2=A0 */
>>> +
>>> +=C2=A0=C2=A0=C2=A0 for (entry =3D l_queue_get_entries(roots), i =3D 0;=
 i < n;
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ent=
ry =3D entry->next, i++) {
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 const struct tls_cert *root=
 =3D entry->data;
>>> +
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 root_keys[i] =3D l_key_new(=
L_KEY_RSA, root->asn1, root->size);
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (!root_keys[i] || !l_key=
ring_link(ring, root_keys[i]))
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 suc=
cess =3D false;
>>
>> So why are we loading the CA keys into the verify ring?=C2=A0 Can't we j=
ust =

>> load all the CA keys into a temporary ring and then remove it when =

>> we're done? E.g. the ca ring.
> =

> This is possible, but I'm not sure it accomplishes much. Either way you =

> still end up deleting all the CA keys, and if you add a temporary ring =

> then you have to create and delete that too.

As an intermediate transform until we get to the point where we keep the =

CAs around in a permanent keyring.  What I suggest above is mostly about =

getting rid of VLA usage.  We can l_key_free_norevoke here right away in =

this case.

> =

> The use case I had in mind was to have a persistent ca_ring that could =

> be used to restrict many other short-lived keyrings.
> =


Yep, I'm with you.

>>
>>> +=C2=A0=C2=A0=C2=A0 }
>>> +
>>> +=C2=A0=C2=A0=C2=A0 if (!l_keyring_restrict(ring, L_KEYRING_RESTRICT_AS=
YM_CHAIN, =

>>> NULL) ||
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 !l_=
keyring_link(ring, key))
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 success =3D false;
>>
>> And here we could restrict the ring against the ca_ring.=C2=A0 If that =

>> succeeds, then what we can do is call l_keyring_restrict, this time =

>> with last argument being NULL.=C2=A0 Or is that not possible? Mat?
> =

> I'm not 100% sure I'm following Denis here, but you only get one chance =

> to call l_keyring_restrict() for a given keyring. So if you restrict =

> against ca_ring, you can't change that to NULL later (but you could =

> empty ca_ring and get the same effect).

Okay, that's what I was wondering, whether we could call restrict =

multiple times.  So if we can't do that, and given the fact that we only =

have a single key we're talking about here, why don't we create a =

temporary keyring.  Put the key into that, and restrict the temporary to =

the CA ring.  If that succeeds, put the key into the actual ring and =

restrict it as we do above.  Hope that makes sense.

> =

>>
>>> +
>>> +=C2=A0=C2=A0=C2=A0 for (i =3D 0; i < n; i++)
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 l_key_free(root_keys[i]);
>>> +
>>
>> Then this just becomes l_keyring_free(ca_ring);
> =

> You still have to l_key_free() each root key. The l_keyring tells the =

> kernel how to group the keys, but ELL doesn't free its l_key objects =

> based on the keyring(s) they are in.
> =


Right, I left out the l_key_free_norevoke detail above.

>>
>>> +=C2=A0=C2=A0=C2=A0 if (success)
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return key;
>>> +
>>> +=C2=A0=C2=A0=C2=A0 l_key_free(key);
>>> +=C2=A0=C2=A0=C2=A0 return NULL;
>>> +}
>>> +
>>> =C2=A0 static void tls_key_cleanup(struct l_key **p)
>>> =C2=A0 {
>>> -=C2=A0=C2=A0=C2=A0 l_key_free_norevoke(*p);
>>> +=C2=A0=C2=A0=C2=A0 l_key_free(*p);
>>> =C2=A0 }
>>> =C2=A0 -static bool tls_cert_link(struct tls_cert *cert, struct l_keyri=
ng =

>>> *ring)
>>
>> <snip>
>>
>>> @@ -2772,43 +2840,19 @@ static void tls_keyring_cleanup(struct =

>>> l_keyring **p)
>>> =C2=A0 bool tls_cert_verify_certchain(struct tls_cert *certchain,
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 struct l_queue *ca_certs)
>>> =C2=A0 {
>>> -=C2=A0=C2=A0=C2=A0 L_AUTO_CLEANUP_VAR(struct l_keyring *, ca_ring, =

>>> tls_keyring_cleanup);
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 L_AUTO_CLEANUP_VAR(struct l_keyring *, v=
erify_ring,
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 tls_keyring_cleanup);
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 tls_keyring_cleanup) =3D l_keyring_new();
>>> +=C2=A0=C2=A0=C2=A0 struct l_key *trusted;
>>
>> This function is so simple I would consider dropping the =

>> L_AUTO_CLEANUP_VAR completely.
> =

> The auto cleanup stuff was handy when there were many different 'return' =

> statements, but with the simplified version of this function I agree =

> with Denis.
> =

>>
>>> =C2=A0 -=C2=A0=C2=A0=C2=A0 ca_ring =3D NULL;
>>> -
>>> -=C2=A0=C2=A0=C2=A0 verify_ring =3D l_keyring_new();
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (!verify_ring)
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return false;
>>> =C2=A0 -=C2=A0=C2=A0=C2=A0 /*
>>> -=C2=A0=C2=A0=C2=A0=C2=A0 * If CA cert(s) were supplied, restrict verif=
y_ring now so
>>> -=C2=A0=C2=A0=C2=A0=C2=A0 * everything else in certchain is validated a=
gainst the CA(s).
>>> -=C2=A0=C2=A0=C2=A0=C2=A0 * Otherwise, verify_ring will be restricted a=
fter the root of
>>> -=C2=A0=C2=A0=C2=A0=C2=A0 * certchain is added to verify_ring by
>>> -=C2=A0=C2=A0=C2=A0=C2=A0 * tls_cert_verify_with_keyring().
>>> -=C2=A0=C2=A0=C2=A0=C2=A0 */
>>> -=C2=A0=C2=A0=C2=A0 if (ca_certs) {
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 const struct l_queue_entry =
*entry;
>>> -
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ca_ring =3D l_keyring_new();
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (!ca_ring)
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ret=
urn false;
>>> -
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for (entry =3D l_queue_get_=
entries(ca_certs); entry;
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 entry =3D entry->next)
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if =
(!tls_cert_link(entry->data, ca_ring))
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 return false;
>>> -
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (!l_keyring_restrict(ver=
ify_ring,
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 L_KEYRING_RESTRICT_ASYM_CHAIN,
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ca_ring))
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ret=
urn false;
>>> -=C2=A0=C2=A0=C2=A0 }
>>> +=C2=A0=C2=A0=C2=A0 trusted =3D tls_cert_verify_with_keyring(certchain,=
 verify_ring, =

>>> ca_certs);
>>> +=C2=A0=C2=A0=C2=A0 if (!trusted)
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return false;
>>> =C2=A0 -=C2=A0=C2=A0=C2=A0 return tls_cert_verify_with_keyring(certchai=
n, verify_ring, =

>>> ca_certs,
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ca_ri=
ng);
>>> +=C2=A0=C2=A0=C2=A0 l_key_free(trusted);
>>> +=C2=A0=C2=A0=C2=A0 return true;
>>> =C2=A0 }
>>> =C2=A0=C2=A0=C2=A0 void tls_cert_free_certchain(struct tls_cert *cert)
>>>
>>
> =

> It seems like the implementation is made more complicated by the fact =

> that the cert list is a singly-linked list starting with the end-entity =

> cert (which we then follow toward the root using the issuer pointers), =

> while in order to verify we need to link keys to the restricted keyring =

> starting from the root end of the chain.
> =

> If we know that it's a linear cert chain, the code could be simplified =

> by making the cert chain a doubly-linked list that could be walked in =

> the other direction. That would eliminate the recursion, leading to an =

> implementation that looks more like this:
> =

> 1. Create a keyring
> 2. Load it with the root certs
> 3. Try to load the first cert in the chain (from the root-facing end)
> 4. If that works, clear the root certs
> 5. Try to load the next cert in the chain
> 6. If that works, clear the previous cert
> 7. Repeat 5-6 until you get to the end-entity cert
> =

> That's the behavior of this patch (from the perspective of the kernel), =

> but it's hard to see because recursive calls are used to follow the =

> issuer chain toward the root first, then the keyring loads are attempted =

> as the stack gets unwound.
> =

> (I realize the recursive code structure is inherited from my earlier =

> implementation :) )
> =


I agree here, I think recursive implementation is actually harder to =

read and more resource intensive.

> =

> As Denis pointed out above, it would be convenient to add and remove the =

> root certs as a group. The kernel lets keyrings contain keyrings. A =

> restricted keyring R will search for signing keys in the trusted keyring =

> T (if it wasn't NULL), and within R itself. If R "contains" a link to =

> another keyring A, it will search T, R, and A for signing keys.
> =

> If we add l_keyring_link_nested(keyring, nested_keyring) to ELL, then =

> you could have a persistent ca_ring that is temporarly linked to the =

> verify ring to check the first cert, then ca_ring gets unlinked in a =

> single operation when you want to check the second cert.
> =


So that might actually be an even better solution than what I proposed =

above with having a temporary restriction ring.

Regards,
-Denis

--===============3882513614425730657==--

