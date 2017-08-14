Content-Type: multipart/mixed; boundary="===============6997535116347460976=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 5/7] pem: Support encrypted keys in l_pem_load_private_key
Date: Mon, 14 Aug 2017 15:29:47 -0500
Message-ID: <6ac3860d-ae86-ebf7-d721-248ac8c6fe81@gmail.com>
In-Reply-To: <20170814145750.6683-5-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6997535116347460976==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/14/2017 09:57 AM, Andrew Zaborowski wrote:
> Add support for loading PKCS#8 encrypted private key files (those
> generated with "openssl pkcs8 ..." or "openssl pkey ..." commands, not
> "openssl rsa ..." commands).  The 'encrypted' parameter can be used to
> check if a password is required to decode the key if the caller knows
> nothing about the key other than the file path.
> ---
>   ell/pem.c | 112 +++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++-----
>   ell/pem.h |   4 +--
>   ell/tls.c |   1 +
>   3 files changed, 107 insertions(+), 10 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============6997535116347460976==--

