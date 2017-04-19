Content-Type: multipart/mixed; boundary="===============1647103220289892362=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 1/3] key: Use keyring restriction keyctl
Date: Wed, 19 Apr 2017 11:47:19 -0500
Message-ID: <8550caae-d316-ad68-e350-b359de51769b@gmail.com>
In-Reply-To: <20170419002419.9762-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1647103220289892362==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 04/18/2017 07:24 PM, Mat Martineau wrote:
> Now that the restricted keyring patches have been applied to keys-next
> and are on track for the v4.12 merge window, ELL needs to be updated for
> the final API.
>
> There are two significant changes from the previous API:
>
> 1. Key restrictions are now applied in a separate step after a keyring
> is created, not at creation time.
>
> 2. The first key added to an empty, "chain" restricted keyring no longer
> bypasses the signature check.
>
> The latter required a change to l_keyring_new() so that the root key
> could be added to a keyring after it is created but before it is
> restricted. There's a new l_keyring_restrict() function to restrict an
> existing keyring.
> ---
>  ell/key.c | 76 ++++++++++++++++++++++++++++++++++++++++-----------------=
------
>  ell/key.h | 13 ++++++-----
>  ell/tls.c | 48 ++++++++++++++++++++++++++++++++++------
>  3 files changed, 96 insertions(+), 41 deletions(-)
>

All applied, thanks.

Regards,
-Denis


--===============1647103220289892362==--

