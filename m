Content-Type: multipart/mixed; boundary="===============7892510117278688251=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] key: Add cert chain validation capability to keyring
Date: Mon, 24 Oct 2016 11:01:14 -0500
Message-ID: <580E304A.1040301@gmail.com>
In-Reply-To: <20161021205226.419-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7892510117278688251==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 10/21/2016 03:52 PM, Mat Martineau wrote:
> Verifying certificate chains was a little awkward using the
> L_KEYRING_TRUSTED_ASYM keyring type, which required verifying the
> signature and then separately adding the verified certificate to the
> "trusted" keyring.
>
> With L_KEYRING_TRUSTED_ASYM_CHAIN, the destination keyring is also
> searched for signing keys.
>
> One use model is to have two keyrings:
>
>   1. trust_keyring: contains long-lived root and intermediate CA certs.
>   2. verify_keyring: an L_KEYRING_TRUSTED_ASYM_CHAIN keyring that
>                      is created with "trust_keyring" referenced for
> 		    trusted certificates.
>
> In order to validate new certificates, they are added to verify_keyring
> in series, starting with certs that are signed by those in
> trust_keyring. Once an intermediate CA cert is added to verify_keyring,
> certs signed by that intermediate CA can also be added to verify_keyring.
> ---
>   ell/key.c | 22 ++++++++++++++++------
>   ell/key.h |  3 ++-
>   2 files changed, 18 insertions(+), 7 deletions(-)
>

All four applied, thanks.

Regards,
-Denis


--===============7892510117278688251==--

