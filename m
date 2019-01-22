Content-Type: multipart/mixed; boundary="===============3508066902050619798=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] tls: Drop unneeded ecc curve data
Date: Tue, 22 Jan 2019 19:02:29 +0100
Message-ID: <20190122180229.12051-2-andrew.zaborowski@intel.com>
In-Reply-To: <20190122180229.12051-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3508066902050619798==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Drop the information on ECC curves that we can get from the l_ecc APIs
except for the name and the curve ID.  We keep the IDs in the
tls_group_pref array so we can set the curve preference independently of
the list of ecc.c supported curves and don't have to generate the array
dynamically.
---
 ell/tls-extensions.c | 10 ++--------
 ell/tls-private.h    |  4 ----
 ell/tls-suites.c     | 37 +++++++++++++++++++++++--------------
 3 files changed, 25 insertions(+), 26 deletions(-)

diff --git a/ell/tls-extensions.c b/ell/tls-extensions.c
index 6769948..d179e67 100644
--- a/ell/tls-extensions.c
+++ b/ell/tls-extensions.c
@@ -325,14 +325,8 @@ static const uint8_t tls_dh14_prime[] =3D {
 };
 =

 static const struct tls_named_group tls_group_pref[] =3D {
-	{
-		"secp256r1", 23, TLS_GROUP_TYPE_EC,
-		.ec =3D { .l_group =3D 19, .point_bytes =3D 64 },
-	},
-	{
-		"secp384r1", 24, TLS_GROUP_TYPE_EC,
-		.ec =3D { .l_group =3D 20, .point_bytes =3D 96 },
-	},
+	{ "secp256r1", 23, TLS_GROUP_TYPE_EC },
+	{ "secp384r1", 24, TLS_GROUP_TYPE_EC },
 	{
 		"ffdhe2048", 256, TLS_GROUP_TYPE_FF,
 		.ff =3D {
diff --git a/ell/tls-private.h b/ell/tls-private.h
index b8c436a..03ad07c 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -155,10 +155,6 @@ struct tls_named_group {
 		TLS_GROUP_TYPE_FF,
 	} type;
 	union {
-		struct {
-			unsigned int l_group;
-			size_t point_bytes;
-		} ec;
 		struct {
 			const uint8_t *prime;
 			size_t prime_len;
diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index d6b4caa..c11c28d 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -396,24 +396,27 @@ static void tls_free_ecdhe_params(struct l_tls *tls)
 	l_free(params);
 }
 =

-static size_t tls_write_ecpoint(uint8_t *buf,
+static size_t tls_write_ecpoint(uint8_t *buf, size_t len,
 				const struct tls_named_group *curve,
 				const struct l_ecc_point *point)
 {
+	size_t point_bytes;
+
 	/* RFC 8422, Section 5.4.1 */
-	buf[0] =3D 1 + curve->ec.point_bytes;	/* length */
+	point_bytes =3D l_ecc_point_get_data(point, buf + 2, len - 2);
+	buf[0] =3D 1 + point_bytes;		/* length */
 	buf[1] =3D 4;				/* form: uncompressed */
-	return 2 + l_ecc_point_get_data(point, buf + 2, curve->ec.point_bytes);
+	return 2 + point_bytes;
 }
 =

-static size_t tls_write_server_ecdh_params(struct l_tls *tls, uint8_t *buf)
+static size_t tls_write_server_ecdh_params(struct l_tls *tls, uint8_t *buf=
, size_t len)
 {
 	struct tls_ecdhe_params *params =3D tls->pending.key_xchg_params;
 =

 	/* RFC 8422, Section 5.4 */
 	buf[0] =3D 3;				/* curve_type: named_curve */
 	l_put_be16(tls->negotiated_curve->id, buf + 1);
-	return 3 + tls_write_ecpoint(buf + 3, tls->negotiated_curve,
+	return 3 + tls_write_ecpoint(buf + 3, len - 3, tls->negotiated_curve,
 					params->public);
 }
 =

@@ -445,7 +448,7 @@ static bool tls_send_ecdhe_server_key_xchg(struct l_tls=
 *tls)
 	}
 =

 	server_ecdh_params_ptr =3D ptr;
-	ptr +=3D tls_write_server_ecdh_params(tls, ptr);
+	ptr +=3D tls_write_server_ecdh_params(tls, ptr, buf + sizeof(buf) - ptr);
 =

 	if (tls->pending.cipher_suite->signature) {
 		sign_len =3D tls->pending.cipher_suite->signature->sign(tls, ptr,
@@ -470,6 +473,7 @@ static void tls_handle_ecdhe_server_key_xchg(struct l_t=
ls *tls,
 	struct tls_ecdhe_params *params;
 	uint16_t namedcurve;
 	const uint8_t *server_ecdh_params_ptr =3D buf;
+	size_t point_bytes;
 =

 	/* RFC 8422, Section 5.4 */
 =

@@ -498,9 +502,11 @@ static void tls_handle_ecdhe_server_key_xchg(struct l_=
tls *tls,
 =

 	TLS_DEBUG("Negotiated %s", tls->negotiated_curve->name);
 =

-	if (*buf++ !=3D 1 + tls->negotiated_curve->ec.point_bytes)
+	if (*buf < 1)
 		goto decode_error;
 =

+	point_bytes =3D *buf++ - 1;
+
 	if (*buf !=3D 4) {	/* uncompressed */
 		TLS_DISCONNECT(TLS_ALERT_ILLEGAL_PARAM, 0,
 				"Unsupported (deprecated?) PointConversionForm "
@@ -511,7 +517,7 @@ static void tls_handle_ecdhe_server_key_xchg(struct l_t=
ls *tls,
 	buf++;
 	len -=3D 2;
 =

-	if (len < tls->negotiated_curve->ec.point_bytes)
+	if (len < point_bytes)
 		goto decode_error;
 =

 	/*
@@ -527,10 +533,11 @@ static void tls_handle_ecdhe_server_key_xchg(struct l=
_tls *tls,
 						L_ECC_POINT_TYPE_FULL,
 						buf, len);
 	tls->pending.key_xchg_params =3D params;
-	buf +=3D tls->negotiated_curve->ec.point_bytes;
-	len -=3D tls->negotiated_curve->ec.point_bytes;
+	buf +=3D point_bytes;
+	len -=3D point_bytes;
 =

-	if (!params->public) {
+	if (!params->public || point_bytes !=3D
+			2 * l_ecc_curve_get_scalar_bytes(params->curve)) {
 		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
 				"ServerKeyExchange.params.public decode error");
 		return;
@@ -575,7 +582,8 @@ static bool tls_send_ecdhe_client_key_xchg(struct l_tls=
 *tls)
 		return false;
 	}
 =

-	ptr +=3D tls_write_ecpoint(ptr, tls->negotiated_curve, our_public);
+	ptr +=3D tls_write_ecpoint(ptr, buf + sizeof(buf) - ptr,
+					tls->negotiated_curve, our_public);
 	l_ecc_point_free(our_public);
 =

 	/*
@@ -624,13 +632,14 @@ static void tls_handle_ecdhe_client_key_xchg(struct l=
_tls *tls,
 	ssize_t pre_master_secret_len;
 	struct l_ecc_point *other_public;
 	struct l_ecc_scalar *secret;
+	size_t point_bytes =3D 2 * l_ecc_curve_get_scalar_bytes(params->curve);
 =

 	/* RFC 8422, Section 5.7 */
 =

 	if (len < 2)
 		goto decode_error;
 =

-	if (*buf++ !=3D 1 + tls->negotiated_curve->ec.point_bytes)
+	if (*buf++ !=3D 1 + point_bytes)
 		goto decode_error;
 =

 	if (*buf !=3D 4) {	/* uncompressed */
@@ -643,7 +652,7 @@ static void tls_handle_ecdhe_client_key_xchg(struct l_t=
ls *tls,
 	buf++;
 	len -=3D 2;
 =

-	if (len !=3D tls->negotiated_curve->ec.point_bytes)
+	if (len !=3D point_bytes)
 		goto decode_error;
 =

 	/*
-- =

2.19.1


--===============3508066902050619798==--

