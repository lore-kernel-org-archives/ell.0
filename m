Content-Type: multipart/mixed; boundary="===============2143248381577644050=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/9] tls: Drop the tls12_prf() hash_len parameter
Date: Tue, 22 Jan 2019 07:09:01 +0100
Message-ID: <20190122060905.27452-5-andrew.zaborowski@intel.com>
In-Reply-To: <20190122060905.27452-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2143248381577644050==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls-private.h |  2 +-
 ell/tls.c         | 16 ++++++----------
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 957109d..312492d 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -293,7 +293,7 @@ bool tls10_prf(const void *secret, size_t secret_len,
 		const void *seed, size_t seed_len,
 		uint8_t *out, size_t out_len);
 =

-bool tls12_prf(enum l_checksum_type type, size_t hash_len,
+bool tls12_prf(enum l_checksum_type type,
 		const void *secret, size_t secret_len,
 		const char *label,
 		const void *seed, size_t seed_len,
diff --git a/ell/tls.c b/ell/tls.c
index 1e6884e..a16b947 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -62,8 +62,7 @@ bool tls10_prf(const void *secret, size_t secret_len,
 	 * the first byte of S2.
 	 */
 =

-	if (!tls12_prf(L_CHECKSUM_MD5, 16,
-			secret, l_s1,
+	if (!tls12_prf(L_CHECKSUM_MD5, secret, l_s1,
 			label, seed, seed_len,
 			out, out_len))
 		return false;
@@ -71,8 +70,7 @@ bool tls10_prf(const void *secret, size_t secret_len,
 	if (secret_len > 0)
 		secret +=3D secret_len - l_s1;
 =

-	if (!tls12_prf(L_CHECKSUM_SHA1, 20,
-			secret, l_s1,
+	if (!tls12_prf(L_CHECKSUM_SHA1, secret, l_s1,
 			label, seed, seed_len,
 			p_hash2, out_len))
 		return false;
@@ -83,7 +81,7 @@ bool tls10_prf(const void *secret, size_t secret_len,
 	return true;
 }
 =

-bool tls12_prf(enum l_checksum_type type, size_t hash_len,
+bool tls12_prf(enum l_checksum_type type,
 		const void *secret, size_t secret_len,
 		const char *label,
 		const void *seed, size_t seed_len,
@@ -107,16 +105,14 @@ bool tls12_prf(enum l_checksum_type type, size_t hash=
_len,
 		/* Generate A(i) */
 		l_checksum_reset(hmac);
 		l_checksum_update(hmac, a, a_len);
-		l_checksum_get_digest(hmac, a, hash_len);
-		a_len =3D hash_len;
+		a_len =3D l_checksum_get_digest(hmac, a, sizeof(a));
 =

 		/* Append seed & generate output */
 		memcpy(a + a_len, prfseed, prfseed_len);
 		l_checksum_reset(hmac);
 		l_checksum_update(hmac, a, a_len + prfseed_len);
 =

-		chunk_len =3D out_len < hash_len ? out_len : hash_len;
-		l_checksum_get_digest(hmac, out, chunk_len);
+		chunk_len =3D l_checksum_get_digest(hmac, out, out_len);
 		out +=3D chunk_len;
 		out_len -=3D chunk_len;
 	}
@@ -132,7 +128,7 @@ static bool tls_prf_get_bytes(struct l_tls *tls,
 				uint8_t *buf, size_t len)
 {
 	if (tls->negotiated_version >=3D L_TLS_V12)
-		return tls12_prf(tls->prf_hmac->l_id, tls->prf_hmac->length,
+		return tls12_prf(tls->prf_hmac->l_id,
 					secret, secret_len, label,
 					seed, seed_len, buf, len);
 	else
-- =

2.19.1


--===============2143248381577644050==--

