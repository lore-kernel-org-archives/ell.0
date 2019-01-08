Content-Type: multipart/mixed; boundary="===============8576323772474871120=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/8] key: Add l_key_validate_dh_payload
Date: Tue, 08 Jan 2019 05:29:48 +0100
Message-ID: <20190108042951.21914-5-andrew.zaborowski@intel.com>
In-Reply-To: <20190108042951.21914-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8576323772474871120==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a function to validate public values received from the DH peer
against the minimum and maximum values depending on the group's
prime modulus.  This is only necessary ~temporarily as the kernel
*should* be validating the public value in the keyctl operation,
however due to the shape of the syscall keyctl API it can't do that
now so fixing it is not easy and may take a while.  We also can't
do this easily inside l_key_compute_dh_secret because we don't have
the prime's raw value there.  We could perhaps do that if we created
a new "DH group" type (simliar to l_ecc_curve for ECDH) and made the
API more like the ECDH API.

Additionally even after that is fixed in the kernel the additional
check can't hurt and lets user code report a more specific error
because the user code can only assume "internal error" when
l_key_compute_dh_secret fails.
---
 ell/ell.sym |  1 +
 ell/key.c   | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 ell/key.h   |  3 +++
 3 files changed, 52 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 5f7c4ee..95e1a3b 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -304,6 +304,7 @@ global:
 	l_key_generate_dh_private;
 	l_key_compute_dh_public;
 	l_key_compute_dh_secret;
+	l_key_validate_dh_payload;
 	l_key_encrypt;
 	l_key_decrypt;
 	l_key_sign;
diff --git a/ell/key.c b/ell/key.c
index 3f3db43..5038526 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -504,6 +504,54 @@ LIB_EXPORT bool l_key_compute_dh_secret(struct l_key *=
other_public,
 	return compute_common(other_public, private, prime, payload, len);
 }
 =

+static int be_bignum_compare(const uint8_t *a, size_t a_len,
+				const uint8_t *b, size_t b_len)
+{
+	unsigned int i;
+
+	if (a_len >=3D b_len) {
+		for (i =3D 0; i < a_len - b_len; i++)
+			if (a[i])
+				return 1;
+
+		return memcmp(a + i, b, b_len);
+	} else {
+		for (i =3D 0; i < b_len - a_len; i++)
+			if (b[i])
+				return -1;
+
+		return memcmp(a, b + i, a_len);
+	}
+}
+
+/*
+ * Validate that @payload is within range for a private and public key for
+ * a DH computation in the finite field group defined by modulus @prime_bu=
f,
+ * both numbers stored as big-endian integers.  We require a key in the
+ * [2, prime - 2] (inclusive) interval.  PKCS #3 does not exclude 1 as a
+ * private key but other specs do.
+ */
+LIB_EXPORT bool l_key_validate_dh_payload(const void *payload, size_t len,
+				const void *prime_buf, size_t prime_len)
+{
+	static const uint8_t one[] =3D { 1 };
+	uint8_t prime_1[prime_len];
+	unsigned int pos =3D prime_len;
+
+	memcpy(prime_1, prime_buf, prime_len);
+
+	/* Produce prime - 1 for the payload < prime - 1 check */
+	while (pos && !prime_1[--pos]--);
+
+	if (be_bignum_compare(payload, len, one, 1) <=3D 0)
+		return false;
+
+	if (be_bignum_compare(payload, len, prime_1, prime_len) >=3D 0)
+		return false;
+
+	return true;
+}
+
 /* Common code for encrypt/decrypt/sign */
 static ssize_t eds_common(struct l_key *key,
 				enum l_key_cipher_type cipher,
diff --git a/ell/key.h b/ell/key.h
index aefcfb7..024afc6 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -83,6 +83,9 @@ bool l_key_compute_dh_secret(struct l_key *other_public, =
struct l_key *private,
 				struct l_key *prime,
 				void *payload, size_t *len);
 =

+bool l_key_validate_dh_payload(const void *payload, size_t len,
+				const void *prime_buf, size_t prime_len);
+
 ssize_t l_key_encrypt(struct l_key *key, enum l_key_cipher_type cipher,
 			enum l_checksum_type checksum, const void *in,
 			void *out, size_t len_in, size_t len_out);
-- =

2.19.1


--===============8576323772474871120==--

