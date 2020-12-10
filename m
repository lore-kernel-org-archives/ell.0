Content-Type: multipart/mixed; boundary="===============2526322705245169639=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 01/13] pem: Wipe more memory in PKCS#1 private key decoding
Date: Thu, 10 Dec 2020 22:47:41 +0000
Message-ID: <1720fbe9-4505-bbc2-ead1-d2fc25cb5a7b@gmail.com>
In-Reply-To: <20201210193202.526451-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2526322705245169639==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 12/10/20 1:31 PM, Andrew Zaborowski wrote:
> bzero some more potentially sensitive memory that we weren't bzeroing in
> the recently added openssl legacy PKCS#1 private key format decoding.
> ---
>   ell/pem.c | 18 +++++++++++++-----
>   1 file changed, 13 insertions(+), 5 deletions(-)
> =


I went ahead and applied 1, 2, 3 and 5.

Regards,
-Denis

--===============2526322705245169639==--

