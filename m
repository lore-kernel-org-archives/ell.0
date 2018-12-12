Content-Type: multipart/mixed; boundary="===============8153431576297949545=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 3/3] unit: added P384 unit tests
Date: Tue, 11 Dec 2018 16:29:00 -0800
Message-ID: <20181212002900.11739-4-james.prestwood@linux.intel.com>
In-Reply-To: <20181212002900.11739-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8153431576297949545==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-ecdh.c | 66 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 66 insertions(+)

diff --git a/unit/test-ecdh.c b/unit/test-ecdh.c
index 3f9e949..cc0f3a8 100644
--- a/unit/test-ecdh.c
+++ b/unit/test-ecdh.c
@@ -148,6 +148,71 @@ static void test_vector_p256(const void *data)
 	l_ecc_scalar_free(b_shared);
 }
 =

+/*
+ * Test vector from RFC 5114 - 384-bit Random ECP Group
+ */
+static void test_vector_p384(const void *data)
+{
+	const struct l_ecc_curve *curve =3D l_ecc_curve_get(20);
+
+	uint64_t a_sec_buf[6] =3D { 0x86F05FEADB9376F1ull, 0xD706A90CBCB5DF29ull,
+				0xD709EE7A7962A156ull, 0x5DFD8A7965571C48ull,
+				0x44DD14E9FD126071ull, 0xD27335EA71664AF2ull };
+	uint64_t a_pub_buf[12] =3D { 0x7D016FE27A8B8C66ull, 0x7E6A8EA9D1FD7742ull,
+				0x0EE6B0403D627954ull, 0xE057AB62F82054D1ull,
+				0xDA4C6D9074417D05ull, 0x793148F1787634D5ull,
+				0xBACED214A1A1D128ull, 0x8F7A685923DE3B67ull,
+				0x6B8F398BB29E4236ull, 0xC947392E94F4C3F0ull,
+				0xF480F4FB4CD40504ull, 0xC6C41294331D23E6ull };
+	uint64_t b_sec_buf[6] =3D { 0x2C4A6C768BCD94D2ull, 0x9BE52E00C194A413ull,
+				0x1F80231121CCE3D3ull, 0x3B6125262C36A7DFull,
+				0x9C0F00D456C2F702ull, 0x52D1791FDB4B70F8ull };
+	uint64_t b_pub_buf[12] =3D { 0x223F12B5A1ABC120ull, 0x789D72A84865AE2Full,
+				0x4ABC17647B6B9999ull, 0x5B36DB65915359B4ull,
+				0xF74B8D4EFB708B3Dull, 0x5CD42AB9C41B5347ull,
+				0xE035B0EDF36755DEull, 0x40BDE8723415A8ECull,
+				0x0CECA16356CA9332ull, 0x8F6D5B348C0FA4D8ull,
+				0xA3A8BFAC46B404BDull, 0xE171458FEAA939AAull };
+	uint64_t ss_buf[6] =3D {
+				0xDE159A58028ABC0Eull, 0x27AA8A4540884C37ull,
+				0x59D926EB1B8456E4ull, 0xCAE53160137D904Cull,
+				0x55981B110575E0A8ull, 0x5EA1FC4AF7256D20ull };
+	struct l_ecc_scalar *a_shared;
+	struct l_ecc_scalar *b_shared;
+
+	struct l_ecc_scalar *a_secret =3D _ecc_constant_new(curve, a_sec_buf,
+							sizeof(a_sec_buf));
+	struct l_ecc_point *a_public =3D l_ecc_point_new(curve);
+
+	struct l_ecc_scalar *b_secret =3D _ecc_constant_new(curve, b_sec_buf,
+							sizeof(b_sec_buf));
+	struct l_ecc_point *b_public =3D l_ecc_point_new(curve);
+
+	memcpy(a_public->x, a_pub_buf, 48);
+	memcpy(a_public->y, a_pub_buf + 6, 48);
+	memcpy(b_public->x, b_pub_buf, 48);
+	memcpy(b_public->y, b_pub_buf + 6, 48);
+
+	use_real_getrandom =3D false;
+
+	assert(l_ecdh_generate_shared_secret(curve, a_secret, b_public,
+						&a_shared));
+	assert(l_ecdh_generate_shared_secret(curve, b_secret, a_public,
+						&b_shared));
+
+	assert(!memcmp(a_shared->c, ss_buf, 48));
+	assert(!memcmp(b_shared->c, ss_buf, 48));
+
+	use_real_getrandom =3D true;
+
+	l_ecc_scalar_free(a_secret);
+	l_ecc_scalar_free(b_secret);
+	l_ecc_point_free(a_public);
+	l_ecc_point_free(b_public);
+	l_ecc_scalar_free(a_shared);
+	l_ecc_scalar_free(b_shared);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -156,6 +221,7 @@ int main(int argc, char *argv[])
 		l_test_add("ECDH Basic", test_basic, NULL);
 =

 	l_test_add("ECDH test vector P256", test_vector_p256, NULL);
+	l_test_add("ECDH test vector P384", test_vector_p384, NULL);
 =

 	return l_test_run();
 }
-- =

2.17.1


--===============8153431576297949545==--

