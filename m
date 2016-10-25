Content-Type: multipart/mixed; boundary="===============8084494309358916123=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 2/3] key: Make key/keychain revocation optional when
 freeing
Date: Mon, 24 Oct 2016 20:59:41 -0500
Message-ID: <580EBC8D.3060305@gmail.com>
In-Reply-To: <20161024213633.10668-2-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8084494309358916123==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 10/24/2016 04:36 PM, Mat Martineau wrote:
> Revoking keys (or keyrings) unlinks them from every keyring. Sometimes
> it is useful to let the kernel keep a key even if ELL isn't directly
> tracking that key anymore - for example, a keyring of trusted keys can
> be used for validation without keeping l_key objects around for every
> single key in that keyring. The kernel will clean up the kernel key
> objects when there are no more references to them whether or not we
> explicitly revoke from userspace.
>
> l_key_free_norevoke and l_keyring_free_norevoke are added to support the
> non-revoking behavior, while the default is still to revoke the key.
> ---
>   ell/key.c | 20 ++++++++++++++++++++
>   ell/key.h |  2 ++
>   2 files changed, 22 insertions(+)
>

Applied, thanks.

Regards,
-Denis


--===============8084494309358916123==--

