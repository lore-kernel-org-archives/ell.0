Content-Type: multipart/mixed; boundary="===============8151103502261791073=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] ecc: Clear point coordinates, use explicit_bzero
Date: Tue, 19 Mar 2019 14:19:37 -0500
Message-ID: <0e0d9b84-e8f3-cf86-909d-95c01d23ef5d@gmail.com>
In-Reply-To: <20190319004843.13451-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8151103502261791073==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/18/2019 07:48 PM, Andrew Zaborowski wrote:
> We would only zero out memory used by the scalar type because
> Diffie-Hellman secrets are scalars, but in PWD the PWD and PK values may
> be points so also clear those.  Update l_ecc_scalar_free to use
> explicit_bzero too.
> ---
>   ell/ecc.c  | 7 ++++++-
>   ell/ecdh.c | 2 --
>   2 files changed, 6 insertions(+), 3 deletions(-)
> =


All applied, thanks.

Regards,
-Denis


--===============8151103502261791073==--

