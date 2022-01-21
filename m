Content-Type: multipart/mixed; boundary="===============0059344629461047045=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH v2 2/2] tls-suites: use exact length on l_ecc_point_from_data
Date: Fri, 21 Jan 2022 11:36:08 -0800
Message-ID: <20220121193608.2634573-2-prestwoj@gmail.com>
In-Reply-To: 20220121193608.2634573-1-prestwoj@gmail.com

--===============0059344629461047045==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This was passing the remaining length in but prior this length was
only checked if less than point_bytes. If it was greater the
recent update to l_ecc_point_from_data will cause an error return.

Instead use point_bytes directly.
---
 ell/tls-suites.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index 055ee80..1c1ca07 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -534,7 +534,7 @@ static void tls_handle_ecdhe_server_key_xchg(struct l_t=
ls *tls,
 	params->curve =3D l_ecc_curve_from_tls_group(tls->negotiated_curve->id);
 	params->public =3D l_ecc_point_from_data(params->curve,
 						L_ECC_POINT_TYPE_FULL,
-						buf, len);
+						buf, point_bytes);
 	tls->pending.key_xchg_params =3D params;
 	buf +=3D point_bytes;
 	len -=3D point_bytes;
-- =

2.31.1

--===============0059344629461047045==--

