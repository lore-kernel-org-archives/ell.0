Content-Type: multipart/mixed; boundary="===============2696805722717090586=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/8] key: Add utility to generate DH private values
Date: Tue, 08 Jan 2019 05:29:47 +0100
Message-ID: <20190108042951.21914-4-andrew.zaborowski@intel.com>
In-Reply-To: <20190108042951.21914-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2696805722717090586==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ell.sym |  1 +
 ell/key.c   | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 ell/key.h   |  3 +++
 3 files changed, 52 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index ea64ac2..5f7c4ee 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -301,6 +301,7 @@ global:
 	l_key_extract;
 	l_key_get_payload_size;
 	l_key_get_info;
+	l_key_generate_dh_private;
 	l_key_compute_dh_public;
 	l_key_compute_dh_secret;
 	l_key_encrypt;
diff --git a/ell/key.c b/ell/key.c
index 415658b..3f3db43 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -35,6 +35,7 @@
 #include "util.h"
 #include "key.h"
 #include "string.h"
+#include "random.h"
 =

 #ifndef KEYCTL_DH_COMPUTE
 #define KEYCTL_DH_COMPUTE 23
@@ -423,6 +424,53 @@ LIB_EXPORT bool l_key_get_info(struct l_key *key, enum=
 l_key_cipher_type cipher,
 					public);
 }
 =

+LIB_EXPORT struct l_key *l_key_generate_dh_private(const void *prime_buf,
+							size_t prime_len)
+{
+	uint8_t *buf;
+	const uint8_t *prime =3D prime_buf;
+	size_t prime_bits;
+	unsigned int i;
+	size_t private_bytes;
+	size_t random_bytes;
+	struct l_key *private;
+
+	/* Find the prime's bit length excluding leading 0s */
+
+	for (i =3D 0; i < prime_len && !prime[i]; i++);
+
+	if (i =3D=3D prime_len || (i =3D=3D prime_len - 1 && prime[i] < 5))
+		return NULL;
+
+	prime_bits =3D (prime_len - i) * 8 - __builtin_clz(prime[i]);
+
+	/*
+	 * Generate a random DH private value conforming to 1 < x < p - 1.
+	 * To do this covering all possible values in this range with the
+	 * same probability of generating each value generally requires
+	 * looping.  Instead we generate a value in the range
+	 * [2 ^ (prime_bits - 2), 2 ^ (prime_bits - 1) - 1] by forcing bit
+	 * prime_bits - 2 to 1, i.e. the range in PKCS #3 Section 7.1 for
+	 * l equal to prime_bits - 1.  This means we're using between
+	 * one half and one quarter of the full [2, p - 2] range, i.e.
+	 * between 1 and 2 bits fewer.  Note that since p is odd
+	 * p - 1 has the same bit length as p and so our maximum value
+	 * 2 ^ (prime_bits - 1) - 1 is still less than p - 1.
+	 */
+	private_bytes =3D ((prime_bits - 1) + 7) / 8;
+	random_bytes =3D ((prime_bits - 2) + 7) / 8;
+	buf =3D l_malloc(private_bytes);
+	l_getrandom(buf + private_bytes - random_bytes, random_bytes);
+
+	buf[0] &=3D (1 << ((prime_bits - 2) % 8)) - 1;
+	buf[0] |=3D 1 << ((prime_bits - 2) % 8);
+
+	private =3D l_key_new(L_KEY_RAW, buf, private_bytes);
+	memset(buf, 0, private_bytes);
+	l_free(buf);
+	return private;
+}
+
 static bool compute_common(struct l_key *base, struct l_key *private,
 				struct l_key *prime, void *payload, size_t *len)
 {
diff --git a/ell/key.h b/ell/key.h
index 1529135..aefcfb7 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -72,6 +72,9 @@ bool l_key_get_info(struct l_key *key, enum l_key_cipher_=
type cipher,
 			enum l_checksum_type checksum, size_t *bits,
 			bool *public);
 =

+struct l_key *l_key_generate_dh_private(const void *prime_buf,
+					size_t prime_len);
+
 bool l_key_compute_dh_public(struct l_key *generator, struct l_key *privat=
e,
 				struct l_key *prime,
 				void *payload, size_t *len);
-- =

2.19.1


--===============2696805722717090586==--

