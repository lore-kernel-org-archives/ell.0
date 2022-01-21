Content-Type: multipart/mixed; boundary="===============4046656319775730099=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] ecc: enforce strict length with l_ecc_point_from_data
Date: Fri, 21 Jan 2022 10:33:31 -0800
Message-ID: <251d2c897e0a3232c88e9ed609906c38e8b215d7.camel@gmail.com>
In-Reply-To: 769ff176-449d-ff4c-d591-5a74e9e8024b@gmail.com

--===============4046656319775730099==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 2022-01-21 at 10:51 -0600, Denis Kenzior wrote:
> Hi James,
> =

> On 1/21/22 10:45, James Prestwood wrote:
> > This add some extra convenience to users of l_ecc_point_from_data
> > allowing the exact length to be verified in addition to creating
> > the point.
> > ---
> > =C2=A0 ell/ecc.c | 10 +++++-----
> > =C2=A0 1 file changed, 5 insertions(+), 5 deletions(-)
> > =

> =

> This seems to break test-sae?

Yes patch coming. Every other use passed the exact bytes except SAE.

> =

> Regards,
> -Denis
> =



--===============4046656319775730099==--

