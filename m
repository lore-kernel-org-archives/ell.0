Content-Type: multipart/mixed; boundary="===============7261546417986854732=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 8/9] unit: added P384 unit tests
Date: Thu, 29 Nov 2018 14:08:07 -0800
Message-ID: <20181129220808.22151-8-james.prestwood@linux.intel.com>
In-Reply-To: <20181129220808.22151-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7261546417986854732==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

(also renamed 'test_vectors' to 'test_vector_p256' for consistency)
---
 unit/test-ecdh.c | 49 ++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 47 insertions(+), 2 deletions(-)

diff --git a/unit/test-ecdh.c b/unit/test-ecdh.c
index e44c4b6..10cb47a 100644
--- a/unit/test-ecdh.c
+++ b/unit/test-ecdh.c
@@ -120,7 +120,7 @@ static void test_compliant_key(const void *data)
 /*
  * Test vector from RFC 5114 - 256-bit Random ECP Group
  */
-static void test_vectors(const void *data)
+static void test_vector_p256(const void *data)
 {
 	struct l_ecc_curve *curve =3D l_ecc_curve_get(19);
 =

@@ -161,6 +161,50 @@ static void test_vectors(const void *data)
 	use_real_getrandom =3D true;
 }
 =

+static void test_vector_p384(const void *data)
+{
+	struct l_ecc_curve *curve =3D l_ecc_curve_get(20);
+
+	uint64_t a_secret[6] =3D { 0x86F05FEADB9376F1ull, 0xD706A90CBCB5DF29ull,
+				0xD709EE7A7962A156ull, 0x5DFD8A7965571C48ull,
+				0x44DD14E9FD126071ull, 0xD27335EA71664AF2ull };
+	uint64_t a_public[12] =3D { 0x7D016FE27A8B8C66ull, 0x7E6A8EA9D1FD7742ull,
+				0x0EE6B0403D627954ull, 0xE057AB62F82054D1ull,
+				0xDA4C6D9074417D05ull, 0x793148F1787634D5ull,
+				0xBACED214A1A1D128ull, 0x8F7A685923DE3B67ull,
+				0x6B8F398BB29E4236ull, 0xC947392E94F4C3F0ull,
+				0xF480F4FB4CD40504ull, 0xC6C41294331D23E6ull };
+	uint64_t b_secret[6] =3D { 0x2C4A6C768BCD94D2ull, 0x9BE52E00C194A413ull,
+				0x1F80231121CCE3D3ull, 0x3B6125262C36A7DFull,
+				0x9C0F00D456C2F702ull, 0x52D1791FDB4B70F8ull };
+	uint64_t b_public[12] =3D { 0x223F12B5A1ABC120ull, 0x789D72A84865AE2Full,
+				0x4ABC17647B6B9999ull, 0x5B36DB65915359B4ull,
+				0xF74B8D4EFB708B3Dull, 0x5CD42AB9C41B5347ull,
+				0xE035B0EDF36755DEull, 0x40BDE8723415A8ECull,
+				0x0CECA16356CA9332ull, 0x8F6D5B348C0FA4D8ull,
+				0xA3A8BFAC46B404BDull, 0xE171458FEAA939AAull };
+	uint64_t shared_secret[6] =3D {
+				0xDE159A58028ABC0Eull, 0x27AA8A4540884C37ull,
+				0x59D926EB1B8456E4ull, 0xCAE53160137D904Cull,
+				0x55981B110575E0A8ull, 0x5EA1FC4AF7256D20ull };
+	uint64_t a_shared[6];
+	uint64_t b_shared[6];
+
+	use_real_getrandom =3D false;
+
+	assert(l_ecdh_generate_shared_secret(curve, a_secret,
+						(const void *) b_public,
+						96, a_shared, 48));
+	assert(l_ecdh_generate_shared_secret(curve, b_secret,
+						(const void *) a_public,
+						96, b_shared, 48));
+
+	assert(!memcmp(a_shared, shared_secret, 48));
+	assert(!memcmp(b_shared, shared_secret, 48));
+
+	use_real_getrandom =3D true;
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -170,7 +214,8 @@ int main(int argc, char *argv[])
 		l_test_add("ECDH Compliant key", test_compliant_key, NULL);
 	}
 =

-	l_test_add("ECDH test vector", test_vectors, NULL);
+	l_test_add("ECDH test vector P256", test_vector_p256, NULL);
+	l_test_add("ECDH test vector P384", test_vector_p384, NULL);
 =

 	return l_test_run();
 }
-- =

2.17.1


--===============7261546417986854732==--

