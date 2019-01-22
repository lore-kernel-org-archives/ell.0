Content-Type: multipart/mixed; boundary="===============6827223742181143291=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/2] tls: Drop unneeded ecc curve data
Date: Tue, 22 Jan 2019 12:30:31 -0600
Message-ID: <d045570b-a27b-9d68-f097-e77c07ea0d64@gmail.com>
In-Reply-To: <20190122180229.12051-2-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6827223742181143291==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/22/2019 12:02 PM, Andrew Zaborowski wrote:
> Drop the information on ECC curves that we can get from the l_ecc APIs
> except for the name and the curve ID.  We keep the IDs in the
> tls_group_pref array so we can set the curve preference independently of
> the list of ecc.c supported curves and don't have to generate the array
> dynamically.
> ---
>   ell/tls-extensions.c | 10 ++--------
>   ell/tls-private.h    |  4 ----
>   ell/tls-suites.c     | 37 +++++++++++++++++++++++--------------
>   3 files changed, 25 insertions(+), 26 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============6827223742181143291==--

