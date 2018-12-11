Content-Type: multipart/mixed; boundary="===============0454949399642702107=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v6 1/4] ecc: moved ecc from IWD into ell
Date: Tue, 11 Dec 2018 17:18:34 -0600
Message-ID: <82b39d17-8aa0-daac-d184-8e90f5d2d284@gmail.com>
In-Reply-To: <20181211231534.22832-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0454949399642702107==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 12/11/2018 05:15 PM, James Prestwood wrote:
> IWD had its own implementation for ECC and math operations. Eventually
> TLS will indirectly require this (via ECDH) so it made sense to move
> everything into ell. Some changes had to be made to the original file
> to accomidate the ell style.
> =

> The original file (ecc.c) has remained mostly intact, and was put in
> ell/3rdparty/ folder. Any internal vli functions that needed to be
> exposed privately were defined in ecc-private.h. This allows us to
> create a new file ell/ecc.c which holds all the public APIs, as well
> as keep the original ECC unit tests.
> =

> To create a proper set of ECC APIs three new objects were added,
> l_ecc_curve, l_ecc_point and l_ecc_constant. The curve object is used
> to initialize any l_ecc_point/l_ecc_constant. The curve object can
> be obtained with l_ecc_curve_get(int group); This allows ELL to hide
> all the implementation details of the curve (byte size and curve
> parameters).
> =

> For now, the API set is limited to only what ECDH requires, but future
> patches will add a full set of operations needed for other ECC
> protocols.
> ---
>   Makefile.am        |   9 +-
>   ell/ecc-external.c | 934 +++++++++++++++++++++++++++++++++++++++++++++
>   ell/ecc-private.h  |  90 +++++
>   ell/ecc.c          | 381 ++++++++++++++++++
>   ell/ecc.h          |  68 ++++
>   ell/ell.h          |   1 +
>   ell/ell.sym        |  10 +
>   7 files changed, 1491 insertions(+), 2 deletions(-)
>   create mode 100644 ell/ecc-external.c
>   create mode 100644 ell/ecc-private.h
>   create mode 100644 ell/ecc.c
>   create mode 100644 ell/ecc.h
> =


All applied, thanks.

Regards,
-Denis


--===============0454949399642702107==--

