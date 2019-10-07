Content-Type: multipart/mixed; boundary="===============4257776760540275125=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] pem: ensure we dont side-effect type_label
Date: Mon, 07 Oct 2019 11:33:42 -0500
Message-ID: <7c490ba1-bd23-54b4-f92c-f33e75d81945@gmail.com>
In-Reply-To: <20191004224024.3541-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4257776760540275125==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/4/19 5:40 PM, James Prestwood wrote:
> In pem_load_buffer, l_base64_decode could fail. If it does we were
> still keeping type_label set. Instead use a temporary variable to
> hold the label, and only set if l_base64_decode succeeds. Otherwise
> free the temp label and return NULL.
> ---
>   ell/pem.c | 14 ++++++++++++--
>   1 file changed, 12 insertions(+), 2 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============4257776760540275125==--

