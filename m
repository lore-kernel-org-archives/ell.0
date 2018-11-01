Content-Type: multipart/mixed; boundary="===============0348377951469435583=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 10/11] tls: Propagate errors to l_tls_prf_get_bytes
Date: Thu, 01 Nov 2018 12:54:52 +0100
Message-ID: <20181101115453.10373-10-andrew.zaborowski@intel.com>
In-Reply-To: <20181101115453.10373-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0348377951469435583==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add bool return types to tls_prf_get_bytes, tls10_prf, tls12_prf so that
l_new_checksum errors can be reported.
---
 ell/tls-private.h |  6 +++---
 ell/tls.c         | 36 +++++++++++++++++++++++-------------
 2 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 95b8c65..d71a3bb 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -207,12 +207,12 @@ struct l_tls {
 	bool ready;
 };
 =

-void tls10_prf(const void *secret, size_t secret_len,
+bool tls10_prf(const void *secret, size_t secret_len,
 		const char *label,
 		const void *seed, size_t seed_len,
 		uint8_t *out, size_t out_len);
 =

-void tls12_prf(enum l_checksum_type type, size_t hash_len,
+bool tls12_prf(enum l_checksum_type type, size_t hash_len,
 		const void *secret, size_t secret_len,
 		const char *label,
 		const void *seed, size_t seed_len,
@@ -254,7 +254,7 @@ void tls_cert_free_certchain(struct tls_cert *cert);
 =

 enum tls_cert_key_type tls_cert_get_pubkey_type(struct tls_cert *cert);
 =

-void tls_prf_get_bytes(struct l_tls *tls,
+bool tls_prf_get_bytes(struct l_tls *tls,
 				enum l_checksum_type type, size_t hash_len,
 				const void *secret, size_t secret_len,
 				const char *label,
diff --git a/ell/tls.c b/ell/tls.c
index 0aa10e7..7420772 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -40,7 +40,7 @@
 #include "asn1-private.h"
 #include "queue.h"
 =

-void tls10_prf(const void *secret, size_t secret_len,
+bool tls10_prf(const void *secret, size_t secret_len,
 		const char *label,
 		const void *seed, size_t seed_len,
 		uint8_t *out, size_t out_len)
@@ -59,24 +59,28 @@ void tls10_prf(const void *secret, size_t secret_len,
 	 * the first byte of S2.
 	 */
 =

-	tls12_prf(L_CHECKSUM_MD5, 16,
+	if (!tls12_prf(L_CHECKSUM_MD5, 16,
 			secret, l_s1,
 			label, seed, seed_len,
-			out, out_len);
+			out, out_len))
+		return false;
 =

 	if (secret_len > 0)
 		secret +=3D secret_len - l_s1;
 =

-	tls12_prf(L_CHECKSUM_SHA1, 20,
+	if (!tls12_prf(L_CHECKSUM_SHA1, 20,
 			secret, l_s1,
 			label, seed, seed_len,
-			p_hash2, out_len);
+			p_hash2, out_len))
+		return false;
 =

 	for (i =3D 0; i < out_len; i++)
 		out[i] ^=3D p_hash2[i];
+
+	return true;
 }
 =

-void tls12_prf(enum l_checksum_type type, size_t hash_len,
+bool tls12_prf(enum l_checksum_type type, size_t hash_len,
 		const void *secret, size_t secret_len,
 		const char *label,
 		const void *seed, size_t seed_len,
@@ -86,6 +90,9 @@ void tls12_prf(enum l_checksum_type type, size_t hash_len,
 	size_t a_len, chunk_len, prfseed_len =3D strlen(label) + seed_len;
 	uint8_t a[128], prfseed[prfseed_len];
 =

+	if (!hmac)
+		return false;
+
 	/* Generate the hash seed or A(0) as label + seed */
 	memcpy(prfseed, label, strlen(label));
 	memcpy(prfseed + strlen(label), seed, seed_len);
@@ -112,9 +119,10 @@ void tls12_prf(enum l_checksum_type type, size_t hash_=
len,
 	}
 =

 	l_checksum_free(hmac);
+	return true;
 }
 =

-void tls_prf_get_bytes(struct l_tls *tls,
+bool tls_prf_get_bytes(struct l_tls *tls,
 				enum l_checksum_type type, size_t hash_len,
 				const void *secret, size_t secret_len,
 				const char *label,
@@ -122,10 +130,11 @@ void tls_prf_get_bytes(struct l_tls *tls,
 				uint8_t *buf, size_t len)
 {
 	if (tls->negotiated_version >=3D TLS_V12)
-		tls12_prf(type, hash_len, secret, secret_len, label,
-				seed, seed_len, buf, len);
+		return tls12_prf(type, hash_len, secret, secret_len, label,
+					seed, seed_len, buf, len);
 	else
-		tls10_prf(secret, secret_len, label, seed, seed_len, buf, len);
+		return tls10_prf(secret, secret_len, label,
+					seed, seed_len, buf, len);
 }
 =

 LIB_EXPORT bool l_tls_prf_get_bytes(struct l_tls *tls,
@@ -134,6 +143,7 @@ LIB_EXPORT bool l_tls_prf_get_bytes(struct l_tls *tls,
 				const char *label, uint8_t *buf, size_t len)
 {
 	uint8_t seed[64];
+	bool r;
 =

 	if (unlikely(!tls))
 		return false;
@@ -142,16 +152,16 @@ LIB_EXPORT bool l_tls_prf_get_bytes(struct l_tls *tls,
 	memcpy(seed + 32, tls->pending.server_random, 32);
 =

 	if (use_master_secret)
-		tls_prf_get_bytes(tls, type, hash_len,
+		r =3D tls_prf_get_bytes(tls, type, hash_len,
 						tls->pending.master_secret, 48,
 						label, seed, 64, buf, len);
 	else
-		tls_prf_get_bytes(tls, type, hash_len, "", 0,
+		r =3D tls_prf_get_bytes(tls, type, hash_len, "", 0,
 						label, seed, 64, buf, len);
 =

 	memset(seed, 0, 64);
 =

-	return true;
+	return r;
 }
 =

 static void tls_write_random(uint8_t *buf)
-- =

2.19.1


--===============0348377951469435583==--

