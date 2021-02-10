Content-Type: multipart/mixed; boundary="===============1289798571640193219=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/3] pem/cert: Ensure RFC8018/RFC1423 padding isn't 0
Date: Thu, 11 Feb 2021 00:36:59 +0100
Message-ID: <20210210233659.270554-3-andrew.zaborowski@intel.com>
In-Reply-To: <20210210233659.270554-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1289798571640193219==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/cert.c | 8 ++++----
 ell/pem.c  | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index 3f2db1e..1413563 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -599,7 +599,6 @@ struct l_key *cert_key_from_pkcs8_encrypted_private_key=
_info(const uint8_t *der,
 	size_t key_info_len, alg_id_len, data_len, tmp_len;
 	struct l_cipher *alg;
 	uint8_t *decrypted;
-	uint8_t pad;
 	struct l_key *pkey;
 	bool r;
 	bool is_block;
@@ -639,16 +638,17 @@ struct l_key *cert_key_from_pkcs8_encrypted_private_k=
ey_info(const uint8_t *der,
 	}
 =

 	decrypted_len =3D data_len;
-	pad =3D decrypted[data_len - 1];
 =

 	/*
 	 * For block ciphers strip padding as defined in RFC8018
 	 * (for PKCS#5 v1) or RFC1423 / RFC5652 (for v2).
 	 */
-	if (is_block && pad) {
+	if (is_block) {
+		uint8_t pad =3D decrypted[data_len - 1];
+
 		pkey =3D NULL;
 =

-		if (pad > data_len || pad > 16)
+		if (pad > data_len || pad > 16 || pad =3D=3D 0)
 			goto cleanup;
 =

 		if (!l_secure_memeq(decrypted + data_len - pad, pad - 1U, pad))
diff --git a/ell/pem.c b/ell/pem.c
index d33cf68..aec59ef 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -732,7 +732,7 @@ struct l_key *pem_load_private_key(uint8_t *content, si=
ze_t len, char *label,
 =

 			/* Remove padding like in RFC1423 Section 1.1 */
 			pad =3D content[len - 1];
-			if (pad > block_len)
+			if (pad > block_len || pad =3D=3D 0)
 				goto err;
 =

 			if (!l_secure_memeq(content + len - pad, pad - 1U, pad))
-- =

2.27.0

--===============1289798571640193219==--

