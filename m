Content-Type: multipart/mixed; boundary="===============9067738318519126764=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] cipher: Add AEAD API with AES-CCM
Date: Thu, 22 Dec 2016 12:26:05 -0600
Message-ID: <f8a65ee2-0ec1-6718-ca3b-3a3289aa1cb5@gmail.com>
In-Reply-To: <20161222020935.21617-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9067738318519126764==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 12/21/2016 08:09 PM, Mat Martineau wrote:
> Add new function calls to handle encryption and decryption for
> authenticated encryption with associated data (AEAD).
>
> The only AEAD cipher supported so far is AES-CCM.
>
> Requires kernel v4.10 or later for l_aead_cipher_encrypt() and
> l_aead_cipher_decrypt() to return the correct length. Earlier kernels hav=
e a
> bug in AF_ALG aead sockets.
> ---
>  ell/cipher.c | 238 +++++++++++++++++++++++++++++++++++++++++++++++++++++=
+-----
>  ell/cipher.h |  24 ++++++
>  2 files changed, 244 insertions(+), 18 deletions(-)
>

Looks fine to me.  Both applied, thanks.

Regards,
-Denis


--===============9067738318519126764==--

