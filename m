Content-Type: multipart/mixed; boundary="===============0870101351336609417=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH] unit: Add tests for AES-CMAC hashing
Date: Wed, 05 Jun 2019 14:24:08 -0700
Message-ID: <20190605212408.9366-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0870101351336609417==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The two added tests come from the Bluetooth Mesh v1.0 specifications
sample data section.
---
 unit/test-checksum.c | 74 ++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 74 insertions(+)

diff --git a/unit/test-checksum.c b/unit/test-checksum.c
index f21d0bb..9cba88d 100644
--- a/unit/test-checksum.c
+++ b/unit/test-checksum.c
@@ -180,6 +180,75 @@ static void test_updatev(const void *data)
 	l_checksum_free(checksum);
 }
 =

+struct aes_cmac_test_vector {
+	char *plaintext;
+	char *key;
+	char *ciphertext;
+};
+
+/* Hash AES_CMAC tests based on Bluetooth Mesh published sample data */
+static const struct aes_cmac_test_vector aes_cmac_test1 =3D {
+	.plaintext =3D "74657374",
+	.key =3D "00000000000000000000000000000000",
+	.ciphertext =3D "b73cefbd641ef2ea598c2b6efb62f79c",
+};
+
+static const struct aes_cmac_test_vector aes_cmac_test2 =3D {
+	.plaintext =3D "f7a2a44f8e8a8029064f173ddc1e2b00",
+	.key =3D "4f90480c1871bfbffd16971f4d8d10b1",
+	.ciphertext =3D "2ea6467aa3378c4c545eda62935b9b86",
+};
+
+static void test_aes_cmac(const void *data)
+{
+	struct l_checksum *checksum;
+	char *encbuf;
+	size_t encbuflen;
+	char *decbuf;
+	size_t decbuflen;
+	int r;
+	bool success;
+	const struct aes_cmac_test_vector *tv =3D data;
+
+	size_t ptlen;
+	uint8_t *pt =3D l_util_from_hexstring(tv->plaintext, &ptlen) ?:
+		(uint8_t[]) {};
+	size_t keylen;
+	uint8_t *key =3D l_util_from_hexstring(tv->key, &keylen);
+	size_t ctlen;
+	uint8_t *ct =3D l_util_from_hexstring(tv->ciphertext, &ctlen) ?:
+		(uint8_t[]) {};
+
+	encbuflen =3D ctlen;
+	encbuf =3D alloca(encbuflen);
+	memset(encbuf, 0, encbuflen);
+	decbuflen =3D ptlen;
+	decbuf =3D alloca(decbuflen);
+	memset(decbuf, 0, decbuflen);
+
+	checksum =3D l_checksum_new_cmac_aes(key, keylen);
+	assert(checksum);
+
+	success =3D l_checksum_update(checksum, pt, ptlen);
+	assert(success);
+
+	ctlen =3D l_checksum_get_digest(checksum, encbuf, encbuflen);
+	assert(ctlen =3D=3D encbuflen);
+
+	r =3D memcmp(encbuf, ct, ctlen);
+	assert(!r);
+
+	l_checksum_free(checksum);
+
+	if (ptlen)
+		l_free(pt);
+
+	l_free(key);
+
+	if (ctlen)
+		l_free(ct);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -202,5 +271,10 @@ int main(int argc, char *argv[])
 	if (l_checksum_is_supported(L_CHECKSUM_SHA256, false))
 		l_test_add("sha256-1", test_sha256, NULL);
 =

+	if (l_checksum_cmac_aes_supported()) {
+		l_test_add("aes-cmac-1", test_aes_cmac, &aes_cmac_test1);
+		l_test_add("aes-cmac-2", test_aes_cmac, &aes_cmac_test2);
+	}
+
 	return l_test_run();
 }
-- =

2.14.5


--===============0870101351336609417==--

