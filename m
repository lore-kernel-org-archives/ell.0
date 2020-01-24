Content-Type: multipart/mixed; boundary="===============3480687733934878510=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2] ringbuf: Add l_ringbuf_append function
Date: Fri, 24 Jan 2020 14:39:25 -0600
Message-ID: <efa1261a-1e5e-025b-a754-c47f082f5304@gmail.com>
In-Reply-To: <20200122115606.19382-1-przemyslaw.fierek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3480687733934878510==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Przemys=C5=82aw,

On 1/22/20 5:56 AM, Przemys=C5=82aw Fierek wrote:
> ---
>   ell/ell.sym   |  1 +
>   ell/ringbuf.c | 69 ++++++++++++++++++++++++++++++++++++---------------
>   ell/ringbuf.h |  2 ++
>   3 files changed, 52 insertions(+), 20 deletions(-)
> =


<snip>

> +ssize_t l_ringbuf_append(struct l_ringbuf *ringbuf, void *data, size_t l=
en)
> +{
> +	size_t avail, offset, end, left;
> +

Do note that Linux Kernel coding style wants one variable declaration =

per line.  I know the current code is a bit lax in doing that, but for =

new code or changes this is what we prefer.  Refer to: =

https://www.kernel.org/doc/html/latest/process/coding-style.html, =

Section 8, last paragraph.

I manually amended this patch to fix that and applied.

Regards,
-Denis
--===============3480687733934878510==--

