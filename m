Content-Type: multipart/mixed; boundary="===============0775464492456398813=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] cipher: Allow zero byte input for AEAD cipher
Date: Fri, 10 Sep 2021 17:17:20 -0500
Message-ID: <dc82fcd3-9289-d5ee-8d75-86edeb7e0867@gmail.com>
In-Reply-To: <20210910222432.26046-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0775464492456398813==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Inga,

On 9/10/21 5:24 PM, Inga Stotland wrote:
> For AEAD-based cipher, either the plaintext or the associated
> data may contain zero bytes.
> =

> Add extra checks to disallow combinations of NULL input data and
> nonzero data length.
> ---
>   ell/cipher.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis

--===============0775464492456398813==--

