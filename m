Content-Type: multipart/mixed; boundary="===============1074705996561764752=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 3/4] ecc: moved point add, exp, and legendre into ecc.c
Date: Thu, 10 Jan 2019 13:33:58 -0600
Message-ID: <c23b9287-6ad8-fa8c-e4df-ed6feb0f8098@gmail.com>
In-Reply-To: <20190110185316.27969-3-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1074705996561764752==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 01/10/2019 12:53 PM, James Prestwood wrote:
> _ecc_point_add, _vli_mod_exp, and _vli_legendre were all written in
> house, in addition to the ecc code taken from the kernel. Inside IWD
> it was much more convenient to just bundle these into the same file.
> Now (in ELL), since we have ecc-private.h, its much easier to keep
> these separate and out of ecc-external.c.
> ---
>   ell/ecc-external.c | 123 +++++++--------------------------------------
>   ell/ecc-private.h  |   4 ++
>   ell/ecc.c          |  90 +++++++++++++++++++++++++++++++++
>   3 files changed, 111 insertions(+), 106 deletions(-)
> =


Patch 3 & 4 applied, thanks.

Regards,
-Denis

--===============1074705996561764752==--

