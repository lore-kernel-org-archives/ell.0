Content-Type: multipart/mixed; boundary="===============4592732034665159815=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: ECC API proposal (for EAP-PWD/SAE)
Date: Wed, 12 Dec 2018 09:15:32 -0800
Message-ID: <27d5494c8c8cbb0aa72fd8a35a509a207d47a224.camel@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4592732034665159815==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi All,

I thought this may be an easier medium for disussion about the new ECC
API's required for PWD/SAE rather than a full patch set. Since OWE only
needs ECDH, the ELL ECDH/ECC API's were reletively limited, mostly
creation of points/scalars and getting the data back out into a buffer.
PWD/SAE are a bit more involved. Here is my API proposal for adding the
functionailty we need for PWD/SAE (plus some explanation). Note these
are in addition to what was just merged.

Both PWD/SAE require adding two scalar values together, to produce
another scalar. In both cases this addition is mod N (order). We could
hide this by having a single API that created two scalars, and added
them together to create the added scalar, where all three scalars would
be out parameters. I decided to not go this route because the code
itself is easier to follow next to the RFC when we have a simpler 'add'
function.

bool l_ecc_scalar_add(struct l_ecc_scalar *ret, struct l_ecc_scalar *a,
                                struct l_ecc_scalar *b);

Point multiply/add/inverse are needed for both PWD/SAE.

bool l_ecc_point_multiply(struct l_ecc_point *ret,
                                struct l_ecc_scalar *scalar,
                                struct l_ecc_point *point);
bool l_ecc_point_add(struct l_ecc_point *ret, struct l_ecc_point *a,
                                struct l_ecc_point *b);
bool l_ecc_point_inverse(struct l_ecc_point *p);

This is all that is needed for EAP-PWD. If this is more or less ok I
can go ahead and submit this portion of the patch for review.

=3D=3D=3D=3D=3D=3D Below are operations ONLY required for SAE =3D=3D=3D=3D=
=3D=3D=3D=3D

SAE has a "blinding" technique when computing the X/Y coordinate for
the password element . Without going into details, it requires creating
two special scalars (residue/non-residue). These scalars are then
inputted into an algorithm which decides if the X value is valid. Per
the spec, these two scalars must be created outside the 'blinding'
loop. This is why we need this scalar constructor ('residue' would be
true/false for residue/non-residue).
struct l_ecc_scalar *l_ecc_scalar_new_residue(const struct l_ecc_curve
*curve,
                                                        bool residue);

This simply verifies that the calculated X 'value' is a quadradic
residue, aka it is a valid X coordinate. EAP-PWD achieves the same
affect by just solving for the Y coordinate, but the SAE spec requires
this technique specifically.

bool l_ecc_scalar_is_quadradic_residue(struct l_ecc_scalar *value,
                                struct l_ecc_scalar *qr,
                                struct l_ecc_scalar *qnr);

The SAE spec requires using the curve prime as an input into a KDF.

ssize_t l_ecc_curve_get_prime(const struct l_ecc_curve *curve, void
*buf,
                                size_t len);

These two could actually be benefitial in PWD as well. SAE says that
any received scalar/point from the other peer must be checked that they
do not match our own scalar/point. This prevents replay attacks. EAP-
PWD may also benefit from the same checks.

bool l_ecc_scalars_are_equal(struct l_ecc_scalar *a, struct
l_ecc_scalar *b);

bool l_ecc_points_are_equal(struct l_ecc_point *a, struct l_ecc_point
*b);

I will admit the SAE API's are pretty special purpose to SAE, but I do
this this is the better of the 2 options. The other option is moving
the entire 'blinding' loop into ELL, which would avoid the need for
l_ecc_scalar_new_residue/l_ecc_scalar_is_quadradic_residue, but would
also require moving 2 separate KDFs into ELL, both of which are used
commonly in IWD. In the end it would remove 2 SAE specific API's, in
favor of a single SAE specific algorithm, plus additional API's to
expose the two KDF's.

Your thoughts/ideas are welcome.

Thanks,
James


--===============4592732034665159815==--

