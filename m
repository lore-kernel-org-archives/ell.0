Content-Type: multipart/mixed; boundary="===============4229416201093726665=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/9] tls: Propagate errors to l_tls_prf_get_bytes
Date: Tue, 27 Nov 2018 21:47:10 -0600
Message-ID: <7cbdd0bb-7fdf-3ad1-3892-88316642f402@gmail.com>
In-Reply-To: <20181128023835.2081-3-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4229416201093726665==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/27/2018 08:38 PM, Andrew Zaborowski wrote:
> Add bool return types to tls_prf_get_bytes, tls10_prf, tls12_prf so that
> l_new_checksum errors can be reported.
> ---
>   ell/tls-private.h |  4 ++--
>   ell/tls.c         | 38 ++++++++++++++++++++++++--------------
>   2 files changed, 26 insertions(+), 16 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============4229416201093726665==--

