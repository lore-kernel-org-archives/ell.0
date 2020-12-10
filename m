Content-Type: multipart/mixed; boundary="===============3807218402175746171=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 01/13] pem: Wipe more memory in PKCS#1 private key decoding
Date: Thu, 10 Dec 2020 20:31:54 +0100
Message-ID: <20201210193202.526451-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3807218402175746171==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

bzero some more potentially sensitive memory that we weren't bzeroing in
the recently added openssl legacy PKCS#1 private key format decoding.
---
 ell/pem.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/ell/pem.c b/ell/pem.c
index 790f2c2..70d1f62 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -581,18 +581,24 @@ static struct l_cipher *cipher_from_dek_info(const ch=
ar *algid, const char *para
 =

 	l_checksum_free(md5);
 =

-	if (!ok)
-		return NULL;
+	if (!ok) {
+		cipher =3D NULL;
+		goto cleanup;
+	}
 =

 	cipher  =3D l_cipher_new(type, key, key_len);
 	if (!cipher)
-		return NULL;
+		goto cleanup;
 =

 	if (l_cipher_set_iv(cipher, iv, iv_len))
-		return cipher;
+		goto cleanup;
 =

 	l_cipher_free(cipher);
-	return NULL;
+	cipher =3D NULL;
+
+cleanup:
+	explicit_bzero(key, sizeof(key));
+	return cipher;
 }
 =

 static struct l_key *pem_load_private_key(uint8_t *content,
@@ -821,8 +827,10 @@ static struct l_key *pem_load_private_key(uint8_t *con=
tent,
 		ptr +=3D sizeof(pkcs1_rsa_encryption);
 		memcpy(ptr, private_key, private_key_len);
 		ptr +=3D private_key_len;
+		explicit_bzero(private_key, private_key_len);
 		l_free(private_key);
 =

+		explicit_bzero(content, len);
 		l_free(content);
 		content =3D one_asymmetric_key;
 		len =3D ptr - one_asymmetric_key;
-- =

2.27.0

--===============3807218402175746171==--

