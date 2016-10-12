Content-Type: multipart/mixed; boundary="===============1111223007537637745=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] key: Auto-free the signature hash in l_key_verify
Date: Wed, 12 Oct 2016 12:00:16 -0700
Message-ID: <20161012190016.8186-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1111223007537637745==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This streamlines the existing code by using direct returns rather than a
goto and gets rid of an extra variable. While it does possibly free some
memory immediately after allocation when an invalid checksum type is
requested, this is an uncommon case.
---
 ell/key.c | 29 ++++++++++-------------------
 1 file changed, 10 insertions(+), 19 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index a71bdc8..0222b39 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -599,14 +599,13 @@ LIB_EXPORT bool l_key_verify(struct l_key *key,
 	enum l_key_cipher_type kernel_cipher;
 	ssize_t hash_len;
 	uint8_t *compare_hash;
-	bool success =3D false;
-	uint8_t *sig_hash =3D l_malloc(len_sig);
+	L_AUTO_FREE_VAR(uint8_t *, sig_hash);
+
+	sig_hash =3D l_malloc(len_sig);
 =

 	/* Other checksum types are not yet supported */
-	if (checksum !=3D L_CHECKSUM_NONE) {
-		success =3D false;
-		goto done;
-	}
+	if (checksum !=3D L_CHECKSUM_NONE)
+		return false;
 =

 	/* The keyctl verify implementation compares the verify results
 	 * before we get a chance to unpad it. Instead, use the *encrypt*
@@ -621,10 +620,8 @@ LIB_EXPORT bool l_key_verify(struct l_key *key,
 	hash_len =3D eds_common(key, kernel_cipher, checksum, sig, sig_hash,
 				len_sig, len_sig, KEYCTL_PKEY_ENCRYPT);
 =

-	if (hash_len < 0) {
-		success =3D false;
-		goto done;
-	}
+	if (hash_len < 0)
+		return false;
 =

 	compare_hash =3D sig_hash;
 =

@@ -632,21 +629,15 @@ LIB_EXPORT bool l_key_verify(struct l_key *key,
 		ssize_t unpad_len;
 =

 		unpad_len =3D unpad(sig_hash, NULL, hash_len, 0, 0x01, false);
-		if (unpad_len < 0) {
-			success =3D false;
-			goto done;
-		}
+		if (unpad_len < 0)
+			return false;
 =

 		compare_hash +=3D hash_len - unpad_len;
 		hash_len =3D unpad_len;
 	}
 =

-	success =3D (len_data =3D=3D (size_t)hash_len) &&
+	return (len_data =3D=3D (size_t)hash_len) &&
 		(memcmp(data, compare_hash, hash_len) =3D=3D 0);
-done:
-	l_free(sig_hash);
-
-	return success;
 }
 =

 LIB_EXPORT struct l_keyring *l_keyring_new(enum l_keyring_type type,
-- =

2.10.1


--===============1111223007537637745==--

