Content-Type: multipart/mixed; boundary="===============0432280783877253771=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/3] pem/cert/tls: Use l_secure_memeq for verifying padding
Date: Thu, 11 Feb 2021 00:36:58 +0100
Message-ID: <20210210233659.270554-2-andrew.zaborowski@intel.com>
In-Reply-To: <20210210233659.270554-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0432280783877253771==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Instead of open-coding for loops for verifying padding, use
l_secure_memeq.  This simplifies the code and makes the intent of
the logic easier to understand.
---
 ell/cert.c       | 24 +++++++++++-------------
 ell/pem.c        | 12 ++++++------
 ell/tls-record.c |  7 +++----
 3 files changed, 20 insertions(+), 23 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index c26051f..3f2db1e 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -599,7 +599,7 @@ struct l_key *cert_key_from_pkcs8_encrypted_private_key=
_info(const uint8_t *der,
 	size_t key_info_len, alg_id_len, data_len, tmp_len;
 	struct l_cipher *alg;
 	uint8_t *decrypted;
-	int i;
+	uint8_t pad;
 	struct l_key *pkey;
 	bool r;
 	bool is_block;
@@ -639,24 +639,22 @@ struct l_key *cert_key_from_pkcs8_encrypted_private_k=
ey_info(const uint8_t *der,
 	}
 =

 	decrypted_len =3D data_len;
+	pad =3D decrypted[data_len - 1];
 =

-	if (is_block) {
-		/*
-		 * For block ciphers strip padding as defined in RFC8018
-		 * (for PKCS#5 v1) or RFC1423 / RFC5652 (for v2).
-		 */
+	/*
+	 * For block ciphers strip padding as defined in RFC8018
+	 * (for PKCS#5 v1) or RFC1423 / RFC5652 (for v2).
+	 */
+	if (is_block && pad) {
 		pkey =3D NULL;
 =

-		if (decrypted[data_len - 1] >=3D data_len ||
-				decrypted[data_len - 1] > 16)
+		if (pad > data_len || pad > 16)
 			goto cleanup;
 =

-		for (i =3D 1; i < decrypted[data_len - 1]; i++)
-			if (decrypted[data_len - 1 - i] !=3D
-					decrypted[data_len - 1])
-				goto cleanup;
+		if (!l_secure_memeq(decrypted + data_len - pad, pad - 1U, pad))
+			goto cleanup;
 =

-		decrypted_len -=3D decrypted[data_len - 1];
+		decrypted_len -=3D pad;
 	}
 =

 	pkey =3D cert_key_from_pkcs8_private_key_info(decrypted, decrypted_len);
diff --git a/ell/pem.c b/ell/pem.c
index 67d2af1..d33cf68 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -707,8 +707,8 @@ struct l_key *pem_load_private_key(uint8_t *content, si=
ze_t len, char *label,
 		if (dekalgid) {
 			struct l_cipher *alg;
 			bool r;
-			int i;
 			size_t block_len;
+			uint8_t pad;
 =

 			if (encrypted)
 				*encrypted =3D true;
@@ -731,14 +731,14 @@ struct l_key *pem_load_private_key(uint8_t *content, =
size_t len, char *label,
 				goto err;
 =

 			/* Remove padding like in RFC1423 Section 1.1 */
-			if (content[len - 1] > block_len)
+			pad =3D content[len - 1];
+			if (pad > block_len)
 				goto err;
 =

-			for (i =3D 1; i < content[len - 1]; i++)
-				if (content[len - 1 - i] !=3D content[len - 1])
-					goto err;
+			if (!l_secure_memeq(content + len - pad, pad - 1U, pad))
+				goto err;
 =

-			len -=3D content[len - 1];
+			len -=3D pad;
 		}
 =

 		pkey =3D cert_key_from_pkcs1_rsa_private_key(content, len);
diff --git a/ell/tls-record.c b/ell/tls-record.c
index 505263d..cdbd0b8 100644
--- a/ell/tls-record.c
+++ b/ell/tls-record.c
@@ -522,10 +522,9 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 			tls->mac_length[0];
 		l_put_be16(compressed_len, compressed + 11);
 =

-		for (i =3D 0; i < padding_len; i++)
-			if (compressed[13 + cipher_output_len - 1 -
-					padding_len + i] !=3D padding_len)
-				error =3D 1;
+		error |=3D !l_secure_memeq(compressed + 13 + cipher_output_len -
+						1 - padding_len, padding_len,
+						padding_len);
 =

 		/* Calculate the MAC if needed */
 		tls_write_mac(tls, compressed + 8, 5 + compressed_len,
-- =

2.27.0

--===============0432280783877253771==--

