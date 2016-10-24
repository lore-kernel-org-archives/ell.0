Content-Type: multipart/mixed; boundary="===============5654607384534544347=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 2/5] key: Make key/keychain revocation optional when
 freeing
Date: Mon, 24 Oct 2016 13:34:53 -0700
Message-ID: <alpine.OSX.2.20.1610241325170.1909@mjmartin-mac01.wa.intel.com>
In-Reply-To: <580E5BEC.3080305@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5654607384534544347==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Mon, 24 Oct 2016, Denis Kenzior wrote:

> Hi Mat,
>
> On 10/24/2016 01:55 PM, Marcel Holtmann wrote:
>> Hi Mat,
>> =

>>> Revoking keys (or keyrings) unlinks them any keyring. Sometimes it is
>>> useful to let the kernel keep a key linked even if ELL isn't directly
>>> keeping track of that key anymore - for example, a keyring of trusted
>>> keys can be used for validation without keeping l_key objects around for
>>> every single key in that keyring. The kernel will clean up the kernel
>>> key objects when there are no more references to them whether or not we
>>> explicitly revoke from userspace.
>>> ---
>>> ell/key.c | 14 ++++++++++----
>>> ell/key.h |  4 ++--
>>> ell/tls.c |  6 +++---
>>> 3 files changed, 15 insertions(+), 9 deletions(-)
>>> =

>>> diff --git a/ell/key.c b/ell/key.c
>>> index 4cf2307..4225271 100644
>>> --- a/ell/key.c
>>> +++ b/ell/key.c
>>> @@ -276,12 +276,15 @@ LIB_EXPORT struct l_key *l_key_new(enum l_key_typ=
e =

>>> type, const void *payload,
>>> 	return key;
>>> }
>>> =

>>> -LIB_EXPORT void l_key_free(struct l_key *key)
>>> +LIB_EXPORT void l_key_free(struct l_key *key, bool revoke)
>>> {
>> =

>> I am not a huge fan of glueing on booleans to simple functions like =

>> l_key_free. They should be doing one thing and one thing only. Frankly =

>> later on nobody remembers what the difference between l_key_free(x, true=
) =

>> and l_key_free(x, false) was. It becomes to cumbersome to read and remem=
ber =

>> in application code.
>> =

>> So why not use l_key_free(x) and then introduce l_key_revoke_and_free(x)=
. =

>> Or just simply go with l_key_revoke(x) and have the API description be =

>> clear that it also frees the key.
>> =

>
> +1.  Although we do have precedent for this in l_string_free, but that is =

> mostly how GLib API was done.

Ok, I'll go with l_key_revoke_and_free(). It was l_string_free that sent =

me in the original add-a-flag direction, but that's also a function that =

has been a source of confusion.

--
Mat Martineau
Intel OTC

--===============5654607384534544347==--

