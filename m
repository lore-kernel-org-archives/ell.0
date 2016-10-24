Content-Type: multipart/mixed; boundary="===============1405988073680725376=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 2/5] key: Make key/keychain revocation optional when
 freeing
Date: Mon, 24 Oct 2016 11:47:43 -0700
Message-ID: <alpine.OSX.2.20.1610241146030.1909@mjmartin-mac01.wa.intel.com>
In-Reply-To: <20161024184456.25743-2-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1405988073680725376==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


Denis -

On Mon, 24 Oct 2016, Mat Martineau wrote:

> Revoking keys (or keyrings) unlinks them any keyring. Sometimes it is

"unlinks them from any keyring" is what I meant. Can you fix that up =

before committing?

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

--
Mat Martineau
Intel OTC

--===============1405988073680725376==--

