Content-Type: multipart/mixed; boundary="===============8477665823925184633=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v5 1/3] pem: refactor to expose pem iterator privately
Date: Thu, 03 Oct 2019 13:26:38 -0500
Message-ID: <09719e10-76e4-e19d-0a86-a504272c51b6@gmail.com>
In-Reply-To: <20191003162547.14269-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8477665823925184633==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/3/19 11:25 AM, James Prestwood wrote:
> This refactors pem.c to expose a new internal API, pem_next. This
> API will allow iteration/parsing of PEM(s). Other APIs in pem.c were
> updated to use pem_next.
> =

> pem_next behaves similar to pem_load_buffer, except it does not do
> any base64 decoding. Instead it just returns the start of the base64
> data and the caller must decode it. This allows simple PEM iteration
> loops. Strictly for pem.c usage we decode the base64 string in the
> loop, but settings.c will need this for parsing PEMs from settings
> files and returning the PEM as a full string, including the start/end
> tags.
> ---
>   ell/pem-private.h | 32 +++++++++++++++++++
>   ell/pem.c         | 78 ++++++++++++++++++++++++++++++-----------------
>   2 files changed, 82 insertions(+), 28 deletions(-)
>   create mode 100644 ell/pem-private.h
> =

> -v5:
>   * Fixed incorrect commit description (return start of base64 data)
>   * Removed len out parameter in pem_next, endp can be used instead
>   * Fixed base64_len off by one error.
>   * Fixed misleading comment, and removed unused error handling code

Applied, thanks.

Regards,
-Denis

--===============8477665823925184633==--

