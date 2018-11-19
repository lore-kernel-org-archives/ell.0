Content-Type: multipart/mixed; boundary="===============2004820298276013101=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/8] cipher: Only do the RFC3610 IV formatting for CCM
Date: Mon, 19 Nov 2018 13:03:12 -0600
Message-ID: <2c3bae31-1690-89a2-6812-252cdc5b0211@gmail.com>
In-Reply-To: <20181117133811.5470-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2004820298276013101==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/17/2018 07:38 AM, Andrew Zaborowski wrote:
> In preparation to add the AES GCM mode, move the CCM-specific IV
> formatting code from operate_cipher to the callers (only aead encrypt
> and decrypt), make operate_cipher accept the IV buffer directly.  Check
> that the nonce is >=3D 7 bytes.
> =

> Zero the "counter" part of the IV to avoid sending uninitialized bytes
> to the kernel (the kernel will zero them again though)
> ---
>   ell/cipher.c | 96 +++++++++++++++++++++++++++++++++++-----------------
>   1 file changed, 65 insertions(+), 31 deletions(-)
> =


All 8 applied, thanks.

Regards,
-Denis


--===============2004820298276013101==--

