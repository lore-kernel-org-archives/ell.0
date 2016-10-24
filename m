Content-Type: multipart/mixed; boundary="===============0126257938254042689=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 2/5] key: Make key/keychain revocation optional when
 freeing
Date: Mon, 24 Oct 2016 20:55:07 +0200
Message-ID: <5CE59FE0-3C49-4E4E-B175-D4A8DF4D32FF@holtmann.org>
In-Reply-To: <20161024184456.25743-2-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0126257938254042689==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

> Revoking keys (or keyrings) unlinks them any keyring. Sometimes it is
> useful to let the kernel keep a key linked even if ELL isn't directly
> keeping track of that key anymore - for example, a keyring of trusted
> keys can be used for validation without keeping l_key objects around for
> every single key in that keyring. The kernel will clean up the kernel
> key objects when there are no more references to them whether or not we
> explicitly revoke from userspace.
> ---
> ell/key.c | 14 ++++++++++----
> ell/key.h |  4 ++--
> ell/tls.c |  6 +++---
> 3 files changed, 15 insertions(+), 9 deletions(-)
> =

> diff --git a/ell/key.c b/ell/key.c
> index 4cf2307..4225271 100644
> --- a/ell/key.c
> +++ b/ell/key.c
> @@ -276,12 +276,15 @@ LIB_EXPORT struct l_key *l_key_new(enum l_key_type =
type, const void *payload,
> 	return key;
> }
> =

> -LIB_EXPORT void l_key_free(struct l_key *key)
> +LIB_EXPORT void l_key_free(struct l_key *key, bool revoke)
> {

I am not a huge fan of glueing on booleans to simple functions like l_key_f=
ree. They should be doing one thing and one thing only. Frankly later on no=
body remembers what the difference between l_key_free(x, true) and l_key_fr=
ee(x, false) was. It becomes to cumbersome to read and remember in applicat=
ion code.

So why not use l_key_free(x) and then introduce l_key_revoke_and_free(x). O=
r just simply go with l_key_revoke(x) and have the API description be clear=
 that it also frees the key.

Regards

Marcel


--===============0126257938254042689==--

