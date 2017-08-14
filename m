Content-Type: multipart/mixed; boundary="===============6686345650009489849=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/7] pkcs5: Implement PKCS#5 key derivation functions
Date: Mon, 14 Aug 2017 15:22:07 -0500
Message-ID: <59f5f532-0cc8-aff4-5e70-2ee1d7c4d11a@gmail.com>
In-Reply-To: <20170814145750.6683-3-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6686345650009489849==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/14/2017 09:57 AM, Andrew Zaborowski wrote:
> Implement the PBKDF1 and PBKDF2 functions from PKCS#4 - RFC8018.  This
> a dependency for the pkcs5_cipher_from_alg_id but is export publically
> so that iwd can switch to this implementation and drop its own.

I reworded the description slightly...

> ---
>   Makefile.am |   6 ++-
>   ell/ell.h   |   1 +
>   ell/pkcs5.c | 161 +++++++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   ell/pkcs5.h |  47 ++++++++++++++++++
>   4 files changed, 213 insertions(+), 2 deletions(-)
>   create mode 100644 ell/pkcs5.c
>   create mode 100644 ell/pkcs5.h
> =


Applied, thanks.

Regards,
-Denis

--===============6686345650009489849==--

