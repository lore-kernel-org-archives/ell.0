Content-Type: multipart/mixed; boundary="===============3971589882840367324=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 13/17] key: Add l_key_validate_dh_payload
Date: Tue, 01 Jan 2019 20:49:35 +0100
Message-ID: <20190101194939.5974-13-andrew.zaborowski@intel.com>
In-Reply-To: <20190101194939.5974-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3971589882840367324==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a function to validate local private value payloads against a
the group's prime before creating kernel keys out of them, and to
validate public values received from the peer.
---
 ell/ell.sym |  1 +
 ell/key.c   | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 ell/key.h   |  3 +++
 3 files changed, 52 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index ea64ac2..c3e6156 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -303,6 +303,7 @@ global:
 	l_key_get_info;
 	l_key_compute_dh_public;
 	l_key_compute_dh_secret;
+	l_key_validate_dh_payload;
 	l_key_encrypt;
 	l_key_decrypt;
 	l_key_sign;
diff --git a/ell/key.c b/ell/key.c
index 415658b..297e456 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -456,6 +456,54 @@ LIB_EXPORT bool l_key_compute_dh_secret(struct l_key *=
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
index 1529135..e8688c6 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -80,6 +80,9 @@ bool l_key_compute_dh_secret(struct l_key *other_public, =
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


--===============3971589882840367324==--

