Content-Type: multipart/mixed; boundary="===============1185043989047282552=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] tls: Move DER code to the TLS module and make static
Date: Wed, 05 Oct 2016 14:58:37 -0500
Message-ID: <57F55B6D.8070705@gmail.com>
In-Reply-To: <20161005182552.8850-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1185043989047282552==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 10/05/2016 01:25 PM, Mat Martineau wrote:
> ---
>   ell/cipher-private.h | 37 ------------------------------
>   ell/cipher.c         | 50 -----------------------------------------
>   ell/tls.c            | 63 +++++++++++++++++++++++++++++++++++++++++++++=
++++++-
>   3 files changed, 62 insertions(+), 88 deletions(-)
>   delete mode 100644 ell/cipher-private.h
>

Both applied, thanks.  I also pushed a patch removing cipher-private.h =

from Makefile.am.

Regards,
-Denis


--===============1185043989047282552==--

