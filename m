Content-Type: multipart/mixed; boundary="===============1369392291655884578=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 3/4] unit: Check l_aead_cipher_* return values
Date: Wed, 24 Jan 2018 13:51:28 -0800
Message-ID: <20180124215129.13337-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20180124215129.13337-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1369392291655884578==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-cipher.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/unit/test-cipher.c b/unit/test-cipher.c
index 6a365df..c99650c 100644
--- a/unit/test-cipher.c
+++ b/unit/test-cipher.c
@@ -175,6 +175,7 @@ static void test_aes_ccm(const void *data)
 	char *decbuf;
 	size_t decbuflen;
 	int r;
+	bool success;
 	const struct ccm_test_vector *tv =3D data;
 =

 	size_t ptlen;
@@ -200,16 +201,18 @@ static void test_aes_ccm(const void *data)
 	cipher =3D l_aead_cipher_new(L_AEAD_CIPHER_AES_CCM, key, keylen, taglen);
 	assert(cipher);
 =

-	l_aead_cipher_encrypt(cipher, pt, ptlen, aad, aadlen,
-				nonce, noncelen, encbuf, encbuflen);
+	success =3D l_aead_cipher_encrypt(cipher, pt, ptlen, aad, aadlen,
+					nonce, noncelen, encbuf, encbuflen);
+	assert(success);
 =

 	r =3D memcmp(encbuf, ct, ctlen);
 	assert(!r);
 	r =3D memcmp(encbuf + ctlen, tag, taglen);
 	assert(!r);
 =

-	l_aead_cipher_decrypt(cipher, encbuf, encbuflen, aad, aadlen, nonce,
-				noncelen, decbuf, decbuflen);
+	success =3D l_aead_cipher_decrypt(cipher, encbuf, encbuflen, aad, aadlen,
+					nonce, noncelen, decbuf, decbuflen);
+	assert (success);
 =

 	r =3D memcmp(decbuf, pt, ptlen);
 	assert(!r);
-- =

2.16.1


--===============1369392291655884578==--

