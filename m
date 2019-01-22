Content-Type: multipart/mixed; boundary="===============3188616044154976390=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] ecc: Add l_ecc_curve_get_scalar_bytes
Date: Tue, 22 Jan 2019 12:30:16 -0600
Message-ID: <16358fdc-f28b-150a-3cc7-80af9d3890c4@gmail.com>
In-Reply-To: <20190122180229.12051-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3188616044154976390==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/22/2019 12:02 PM, Andrew Zaborowski wrote:
> Add a function to return the number of bytes used by the *_from_data
> and *_get_data methods.
> ---
>   ell/ecc.c   | 9 ++++++++-
>   ell/ecc.h   | 1 +
>   ell/ell.sym | 6 ++++++
>   3 files changed, 15 insertions(+), 1 deletion(-)
> =


I split this up into two commits (separated out the ell.sym cleanups) =

and applied, thanks.

Regards,
-Denis


--===============3188616044154976390==--

