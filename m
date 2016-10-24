Content-Type: multipart/mixed; boundary="===============7392758603382799894=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 2/5] key: Make key/keychain revocation optional when
 freeing
Date: Mon, 24 Oct 2016 22:39:08 +0200
Message-ID: <36F5D09E-3EF1-484F-A5F3-4F7153482E46@holtmann.org>
In-Reply-To: <alpine.OSX.2.20.1610241325170.1909@mjmartin-mac01.wa.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7392758603382799894==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

>>>> Revoking keys (or keyrings) unlinks them any keyring. Sometimes it is
>>>> useful to let the kernel keep a key linked even if ELL isn't directly
>>>> keeping track of that key anymore - for example, a keyring of trusted
>>>> keys can be used for validation without keeping l_key objects around f=
or
>>>> every single key in that keyring. The kernel will clean up the kernel
>>>> key objects when there are no more references to them whether or not we
>>>> explicitly revoke from userspace.
>>>> ---
>>>> ell/key.c | 14 ++++++++++----
>>>> ell/key.h |  4 ++--
>>>> ell/tls.c |  6 +++---
>>>> 3 files changed, 15 insertions(+), 9 deletions(-)
>>>> diff --git a/ell/key.c b/ell/key.c
>>>> index 4cf2307..4225271 100644
>>>> --- a/ell/key.c
>>>> +++ b/ell/key.c
>>>> @@ -276,12 +276,15 @@ LIB_EXPORT struct l_key *l_key_new(enum l_key_ty=
pe type, const void *payload,
>>>> 	return key;
>>>> }
>>>> -LIB_EXPORT void l_key_free(struct l_key *key)
>>>> +LIB_EXPORT void l_key_free(struct l_key *key, bool revoke)
>>>> {
>>> I am not a huge fan of glueing on booleans to simple functions like l_k=
ey_free. They should be doing one thing and one thing only. Frankly later o=
n nobody remembers what the difference between l_key_free(x, true) and l_ke=
y_free(x, false) was. It becomes to cumbersome to read and remember in appl=
ication code.
>>> So why not use l_key_free(x) and then introduce l_key_revoke_and_free(x=
). Or just simply go with l_key_revoke(x) and have the API description be c=
lear that it also frees the key.
>> =

>> +1.  Although we do have precedent for this in l_string_free, but that i=
s mostly how GLib API was done.
> =

> Ok, I'll go with l_key_revoke_and_free(). It was l_string_free that sent =
me in the original add-a-flag direction, but that's also a function that ha=
s been a source of confusion.

we need an in depth API review and might even fix the l_string_free and rep=
lace it with two functions.

Regards

Marcel


--===============7392758603382799894==--

