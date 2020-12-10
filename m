Content-Type: multipart/mixed; boundary="===============3074901439728323977=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 04/13] cipher: Add ARC4 implementation
Date: Thu, 10 Dec 2020 22:46:51 +0000
Message-ID: <a1f12cf6-5b30-fbdb-baeb-636fd44d5ede@gmail.com>
In-Reply-To: <20201210193202.526451-4-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3074901439728323977==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 12/10/20 1:31 PM, Andrew Zaborowski wrote:
> Re-add the L_CIPHER_ARC4 stream cipher for use in decoding PKCS#12
> files.  Like RC2 it's implemented completely in cipher.c because the
> kernel API doesn't support it.  This cipher is also discouraged where it
> can be avoided.
> ---
>   ell/cipher.c | 98 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/cipher.h |  4 +--
>   2 files changed, 100 insertions(+), 2 deletions(-)
> =


Looks like there's a funny character in this patch somewhere and git am com=
plains.

Regards,
-Denis
--===============3074901439728323977==--

