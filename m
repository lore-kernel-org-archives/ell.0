Content-Type: multipart/mixed; boundary="===============8494506234381043730=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 9/9] unit: Drop the hash lengths in test-tls
Date: Tue, 22 Jan 2019 07:09:05 +0100
Message-ID: <20190122060905.27452-9-andrew.zaborowski@intel.com>
In-Reply-To: <20190122060905.27452-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8494506234381043730==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index a69e708..01496d2 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -81,7 +81,6 @@ static void test_tls10_prf(const void *data)
 /* https://www.ietf.org/mail-archive/web/tls/current/msg03416.html */
 static struct tls12_prf_test {
 	enum l_checksum_type hash;
-	size_t hash_len;
 	const uint8_t *secret;
 	size_t secret_len;
 	const char *label;
@@ -91,7 +90,6 @@ static struct tls12_prf_test {
 	size_t out_len;
 } tls12_prf_sha256_0 =3D {
 	.hash =3D L_CHECKSUM_SHA256,
-	.hash_len =3D 32,
 	.secret_len =3D 16,
 	.secret =3D (const uint8_t []) {
 		0x9b, 0xbe, 0x43, 0x6b, 0xa9, 0x40, 0xf0, 0x17,
@@ -121,7 +119,6 @@ static struct tls12_prf_test {
 	},
 }, tls12_prf_sha384_0 =3D {
 	.hash =3D L_CHECKSUM_SHA384,
-	.hash_len =3D 48,
 	.secret_len =3D 16,
 	.secret =3D (const uint8_t []) {
 		0xb8, 0x0b, 0x73, 0x3d, 0x6c, 0xee, 0xfc, 0xdc,
@@ -157,7 +154,6 @@ static struct tls12_prf_test {
 	},
 }, tls12_prf_sha512_0 =3D {
 	.hash =3D L_CHECKSUM_SHA512,
-	.hash_len =3D 64,
 	.secret_len =3D 16,
 	.secret =3D (const uint8_t []) {
 		0xb0, 0x32, 0x35, 0x23, 0xc1, 0x85, 0x35, 0x99,
@@ -204,7 +200,7 @@ static void test_tls12_prf(const void *data)
 	const struct tls12_prf_test *test =3D data;
 	uint8_t out_buf[test->out_len];
 =

-	tls12_prf(test->hash, test->hash_len, test->secret, test->secret_len,
+	tls12_prf(test->hash, test->secret, test->secret_len,
 			test->label, test->seed, test->seed_len,
 			out_buf, test->out_len);
 =

-- =

2.19.1


--===============8494506234381043730==--

