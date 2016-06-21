Content-Type: multipart/mixed; boundary="===============9079273444163985376=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v7 2/5] cipher: Return number of read bytes from
 asymmetric ops
Date: Mon, 20 Jun 2016 19:11:55 -0500
Message-ID: <5768864B.3050304@gmail.com>
In-Reply-To: <20160620235340.30410-2-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9079273444163985376==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 06/20/2016 06:53 PM, Mat Martineau wrote:
> When using asymmetric cipher operations, the data written to the
> output buffer might be shorter than the full buffer size. The number
> of bytes read is now returned from the asymmetric
> encrypt/decrypt/sign/verify functions. A negative error code is
> returned if the call fails.
> ---
>   ell/cipher.c | 43 +++++++++++++++++++++++--------------------
>   ell/cipher.h | 16 ++++++++--------
>   ell/tls.c    | 45 +++++++++++++++++++++++----------------------
>   3 files changed, 54 insertions(+), 50 deletions(-)
>

Patches 2-5 applied, thanks.

Regards,
-Denis


--===============9079273444163985376==--

