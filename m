Content-Type: multipart/mixed; boundary="===============0559315605385932623=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 6/9] tls: Drop struct tls_hash_algorithm.length field
Date: Tue, 22 Jan 2019 07:09:02 +0100
Message-ID: <20190122060905.27452-6-andrew.zaborowski@intel.com>
In-Reply-To: <20190122060905.27452-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0559315605385932623==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls-private.h |  1 -
 ell/tls.c         | 16 ++++++++--------
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 312492d..279fd15 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -45,7 +45,6 @@ struct tls_bulk_encryption_algorithm {
 struct tls_hash_algorithm {
 	uint8_t tls_id;
 	enum l_checksum_type l_id;
-	size_t length;
 	const char *name;
 };
 =

diff --git a/ell/tls.c b/ell/tls.c
index a16b947..6d6edd9 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -556,10 +556,10 @@ static struct tls_compression_method *tls_find_compre=
ssion_method(
 }
 =

 const struct tls_hash_algorithm tls_handshake_hash_data[] =3D {
-	[HANDSHAKE_HASH_SHA384]	=3D { 5, L_CHECKSUM_SHA384, 48, "SHA384" },
-	[HANDSHAKE_HASH_SHA256]	=3D { 4, L_CHECKSUM_SHA256, 32, "SHA256" },
-	[HANDSHAKE_HASH_MD5]	=3D { 1, L_CHECKSUM_MD5, 16, "MD5" },
-	[HANDSHAKE_HASH_SHA1]	=3D { 2, L_CHECKSUM_SHA1, 20, "SHA1" },
+	[HANDSHAKE_HASH_SHA384]	=3D { 5, L_CHECKSUM_SHA384, "SHA384" },
+	[HANDSHAKE_HASH_SHA256]	=3D { 4, L_CHECKSUM_SHA256, "SHA256" },
+	[HANDSHAKE_HASH_MD5]	=3D { 1, L_CHECKSUM_MD5, "MD5" },
+	[HANDSHAKE_HASH_SHA1]	=3D { 2, L_CHECKSUM_SHA1, "SHA1" },
 };
 =

 static bool tls_init_handshake_hash(struct l_tls *tls)
@@ -1144,8 +1144,8 @@ static void tls_get_handshake_hash(struct l_tls *tls,
 	if (!hash)
 		return;
 =

-	l_checksum_get_digest(hash, out, tls_handshake_hash_data[type].length);
-
+	l_checksum_get_digest(hash, out, l_checksum_digest_length(
+					tls_handshake_hash_data[type].l_id));
 	l_checksum_free(hash);
 }
 =

@@ -1217,7 +1217,7 @@ static void tls_send_finished(struct l_tls *tls)
 				break;
 =

 		tls_get_handshake_hash(tls, hash, seed);
-		seed_len =3D tls_handshake_hash_data[hash].length;
+		seed_len =3D l_checksum_digest_length(tls->prf_hmac->l_id);
 	} else {
 		tls_get_handshake_hash(tls, HANDSHAKE_HASH_MD5, seed + 0);
 		tls_get_handshake_hash(tls, HANDSHAKE_HASH_SHA1, seed + 16);
@@ -1257,7 +1257,7 @@ static bool tls_verify_finished(struct l_tls *tls, co=
nst uint8_t *received,
 				break;
 =

 		seed =3D tls->prev_digest[hash];
-		seed_len =3D tls_handshake_hash_data[hash].length;
+		seed_len =3D l_checksum_digest_length(tls->prf_hmac->l_id);
 	} else {
 		seed =3D alloca(36);
 		memcpy(seed + 0, tls->prev_digest[HANDSHAKE_HASH_MD5], 16);
-- =

2.19.1


--===============0559315605385932623==--

