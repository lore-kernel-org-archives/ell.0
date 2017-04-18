Content-Type: multipart/mixed; boundary="===============3860732397148591226=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 1/2] key: Use keyring restriction keyctl
Date: Tue, 18 Apr 2017 16:14:09 -0700
Message-ID: <alpine.OSX.2.21.1704181436140.3492@sehampsh-mobl1.amr.corp.intel.com>
In-Reply-To: <d3881001-2609-be46-19c6-9b5e1a42932d@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3860732397148591226==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Mon, 17 Apr 2017, Denis Kenzior wrote:

> Hi Mat,
>
> On 04/14/2017 02:16 PM, Mat Martineau wrote:
>> Now that the restricted keyring patches have been applied to keys-next
>> and are on track for the v4.12 merge window, ELL needs to be updated for
>> the final API.
>> =

>> There are two significant changes from the previous API:
>> =

>> 1. Key restrictions are now applied in a separate step after a keyring
>> is created, not at creation time.
>> =

>> 2. The first key added to an empty, "chain" restricted keyring no longer
>> bypasses the signature check.
>
> Interesting.  Why was there this behavior in the first place?

It was to allow validation of a cert chain using a single keyring. It =

would start empty, then you'd add the root cert, and everything you added =

after that would be validated back to that initial root cert. Without the =

exception for the first cert, you're stuck with an empty keyring because =

the kernel couldn't find a trusted cert to verify the signature with.

Now you just add the root cert before turning the restrictions on.

>
>> =

>> The latter required a change to l_keyring_new() so that the root key
>> could be added to a keyring after it is created but before it is
>> restricted. There's a new l_keyring_restrict() function to restrict an
>> existing keyring.
>> ---
>>  ell/key.c | 76 =

>> ++++++++++++++++++++++++++++++++++++++++-----------------------
>>  ell/key.h | 13 ++++++-----
>>  ell/tls.c | 20 ++++++++++++-----
>>  3 files changed, 69 insertions(+), 40 deletions(-)
>> =

>
> <snip>
>
>> diff --git a/ell/tls.c b/ell/tls.c
>> index 06e3341..cd85fad 100644
>> --- a/ell/tls.c
>> +++ b/ell/tls.c
>> @@ -2471,7 +2471,8 @@ static void tls_key_cleanup(struct l_key **p)
>>
>>  static int tls_cert_verify_with_keyring(struct tls_cert *cert,
>>  						struct l_keyring *ring,
>> -						struct tls_cert *root)
>> +						struct tls_cert *root,
>> +						struct l_keyring *trusted)
>>  {
>>  	if (!cert)
>>  		return true;
>> @@ -2488,14 +2489,21 @@ static int tls_cert_verify_with_keyring(struct =

>> tls_cert *cert,
>>  			!memcmp(cert->asn1, root->asn1, root->size))
>>  		return true;
>> =

>> -	if (tls_cert_verify_with_keyring(cert->issuer, ring, root)) {
>> +	if (tls_cert_verify_with_keyring(cert->issuer, ring, root, trusted)) =

>> {
>> +		bool result;
>>  		L_AUTO_CLEANUP_VAR(struct l_key *, key, tls_key_cleanup);
>>
>>  		key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->size);
>>  		if (!key)
>>  			return false;
>> =

>> -		return l_keyring_link(ring, key);
>> +		result =3D l_keyring_link(ring, key);
>> +
>> +		if (result && !cert->issuer)
>> +			result =3D l_keyring_restrict(ring, =

>> L_KEYRING_RESTRICT_ASYM_CHAIN,
>> +							trusted);
>> +
>
> So it looks like we are:
>
> 1. recursively calling tls_cert_verify_with_keyring() until we find the =

> 'root' of the certchain.
> 2. load the root of the certchain and link it into the verify_ring
> 3. restrict it to the trusted ca_ring
> 4. For all subsequent entries in the certchain, we try to link the cert i=
nto =

> the verify_ring which will search the verify_ring or the trusted ca_ring =
for =

> the key that can verify this one.
>
> However, there's a comment captured a few lines above that states:
>
>         * RFC5246 7.4.2:
>         * "Because certificate validation requires that root keys be
>         * distributed independently, the self-signed certificate that
>         * specifies the root certificate authority MAY be omitted from
>         * the chain, under the assumption that the remote end must
>         * already possess it in order to validate it in any case."
>
> So if the server omits the root CA key, and we blindly trust the first =

> certificate in the chain, isn't there a problem?

Yes, that's a problem. The kernel special case only kicked in when there =

wasn't a trusted root CA key. I'll fix it and make sure the unit tests =

catch this.

>
>> +		return result;
>>  	}
>>
>>  	return false;
>> @@ -2520,7 +2528,7 @@ bool tls_cert_verify_certchain(struct tls_cert =

>> *certchain,
>>  		L_AUTO_CLEANUP_VAR(struct l_key *, ca_key, tls_key_cleanup);
>>  		ca_key =3D NULL;
>> =

>> -		ca_ring =3D l_keyring_new(L_KEYRING_SIMPLE, NULL);
>> +		ca_ring =3D l_keyring_new();
>>  		if (!ca_ring)
>>  			return false;
>> =

>> @@ -2529,11 +2537,11 @@ bool tls_cert_verify_certchain(struct tls_cert =

>> *certchain,
>>  			return false;
>>  	}
>> =

>> -	verify_ring =3D l_keyring_new(L_KEYRING_TRUSTED_ASYM_CHAIN, ca_ring);
>> +	verify_ring =3D l_keyring_new();
>>  	if (!verify_ring)
>>  		return false;
>> =

>> -	return tls_cert_verify_with_keyring(certchain, verify_ring, ca_cert);
>> +	return tls_cert_verify_with_keyring(certchain, verify_ring, ca_cert, =

>> ca_ring);
>>  }
>>
>>  void tls_cert_free_certchain(struct tls_cert *cert)
>>

--
Mat Martineau
Intel OTC

--===============3860732397148591226==--

