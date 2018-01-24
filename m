Content-Type: multipart/mixed; boundary="===============6822782374494551201=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] cipher: Correctly propagate AEAD failures
Date: Wed, 24 Jan 2018 17:10:56 -0600
Message-ID: <cb41ecb2-deb3-d6d1-b7a9-2c2190edfe0a@gmail.com>
In-Reply-To: <20180124215129.13337-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6822782374494551201==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 01/24/2018 03:51 PM, Mat Martineau wrote:
> Some pre-4.9 kernels have an AEAD bug that makes recvmsg() return an
> incorrect value that does not include the AAD length. This could cause
> an erroneous successful return from l_aead_cipher_{en,de}crypt() if
> ad_len was longer than the expected output. operate_cipher() now returns
> the number of bytes copied to the 'out' buffer, and the AEAD functions
> only succeed if the expected number of bytes were copied.
> ---
>   ell/cipher.c | 10 +++++++---
>   1 file changed, 7 insertions(+), 3 deletions(-)
> =


All 4 applied, thanks.

Regards,
-Denis


--===============6822782374494551201==--

