Content-Type: multipart/mixed; boundary="===============7344642747663910892=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v4 1/6] cipher: Update for current kernel akcipher
 interface
Date: Thu, 16 Jun 2016 18:17:24 -0500
Message-ID: <57633384.7030402@gmail.com>
In-Reply-To: <20160615171823.20699-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7344642747663910892==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 06/15/2016 12:18 PM, Mat Martineau wrote:
> There are some significant differences in the current iteration of
> kernel AF_ALG akcipher support:
>   * Kernel handles padding
>   * Kernel accepts DER-encoded certs as-is (no need to extract values)
>   * Must explicitly set private or public key
> ---
>   ell/cipher-private.h |   3 -
>   ell/cipher.c         | 305 +++++++++++++-------------------------------=
-------
>   ell/cipher.h         |   3 +-
>   ell/tls.c            |  54 ++++-----
>   4 files changed, 101 insertions(+), 264 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============7344642747663910892==--

