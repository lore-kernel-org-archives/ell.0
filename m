Content-Type: multipart/mixed; boundary="===============0447036866978552497=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] ecc: add checks for zero, one and order
Date: Thu, 11 Apr 2019 10:19:02 -0500
Message-ID: <ac790c60-1a37-00d0-4353-127c88caf2d7@gmail.com>
In-Reply-To: <20190410183752.6176-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0447036866978552497==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 04/10/2019 01:37 PM, James Prestwood wrote:
> To mitigate potential attacks, checks were added to the two
> scalar initalization APIs l_ecc_scalar{new,new_random}. After
> the scalar is created we check that its not zero or one, and
> less than the group order. For new_random we also keep the check
> that the scalar is less than the group prime, as this is required
> in several RFCs/spec for creating random values.
> ---
>   ell/ecc.c | 32 +++++++++++++++++++++++++++-----
>   1 file changed, 27 insertions(+), 5 deletions(-)
> =


Applied with some credits going to Mathy Vanhoef.

Regards,
-Denis

--===============0447036866978552497==--

