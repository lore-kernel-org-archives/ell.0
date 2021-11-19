Content-Type: multipart/mixed; boundary="===============3253315260802734699=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/2] base64: Null terminate encoding
Date: Fri, 19 Nov 2021 10:13:23 -0600
Message-ID: <58bdc1a9-5650-3ec6-d9d9-d4417b60a1f6@gmail.com>
In-Reply-To: 20211117215000.3111579-1-prestwoj@gmail.com

--===============3253315260802734699==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 11/17/21 3:49 PM, James Prestwood wrote:
> l_base64_encode was returning a char* without any NULL terminator. This
> appeared to be written to satisfy the only use in ELL (pem.c) but made
> for a confusing public API. Anyone using this API would expect a char*
> return to be NULL terminated.
> =

> Now l_base64_encode will NULL terminate which also removes the need for
> the length out parameter.
> =

> pem.c was updated to use strlen rather than rely on the out parameter.
> ---
>   ell/base64.c | 8 ++++----
>   ell/base64.h | 3 +--
>   ell/pem.c    | 3 ++-
>   3 files changed, 7 insertions(+), 7 deletions(-)
> =


Both applied, thanks.

Regards,
-Denis

--===============3253315260802734699==--

