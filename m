Content-Type: multipart/mixed; boundary="===============3415961929600677579=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] ecc: clarify curves to group mapping
Date: Wed, 16 Jan 2019 15:04:22 -0600
Message-ID: <ea960ff8-d5b4-6c15-731f-0cec40231076@gmail.com>
In-Reply-To: <20190116190801.25091-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3415961929600677579==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 01/16/2019 01:08 PM, James Prestwood wrote:
> RFC 5114 defines the ECC group numbers, and depending on if your using
> TLS these group numbers differ. Rather than TLS maintaining the mapping
> between TLS group numbers and IKE group numbers we store both group
> numbers in the curve structures as 'ike_group' and 'tls_group'. Also,
> the curve name was added.
> =

> There are now several new APIs where you can get a curve for either
> tls or ike, as well as get a curve by group name. Similarly there is
> a set of APIs for getting supported groups for both ike and tls.
> ---
>   ell/ecc-private.h |  4 ++-
>   ell/ecc.c         | 83 ++++++++++++++++++++++++++++++++++++++++-------
>   ell/ecc.h         |  8 +++--
>   ell/tls-suites.c  |  4 +--
>   4 files changed, 82 insertions(+), 17 deletions(-)
> =


Both applied, thanks.

Regards,
-Denis


--===============3415961929600677579==--

