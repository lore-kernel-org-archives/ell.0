Content-Type: multipart/mixed; boundary="===============4474975412583807397=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 3/5] unit: Update for new l_key_free/l_keyring_free revoke
 parameter
Date: Mon, 24 Oct 2016 11:44:54 -0700
Message-ID: <20161024184456.25743-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20161024184456.25743-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4474975412583807397==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/unit/test-key.c b/unit/test-key.c
index 1195da4..124e2ce 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -83,7 +83,7 @@ static void test_user(const void *data)
 	assert(len =3D=3D KEY2_LEN);
 	assert(!strcmp(buf, KEY2_STR));
 =

-	l_key_free(key);
+	l_key_free(key, true);
 }
 =

 struct dh_test_vector {
@@ -231,7 +231,7 @@ static void testkey_from_string(const char *keystr, str=
uct testkey *tk)
 =

 static void testkey_free_contents(struct testkey *tk)
 {
-	l_key_free(tk->key);
+	l_key_free(tk->key, true);
 	l_free(tk->bytes);
 }
 =

@@ -358,11 +358,11 @@ static void test_simple_keyring(const void *data)
 	success =3D l_keyring_link(ring, key2);
 	assert(success);
 =

-	l_key_free(key1);
+	l_key_free(key1, true);
 	success =3D l_keyring_unlink(ring, key2);
 	assert(success);
-	l_keyring_free(ring);
-	l_key_free(key2);
+	l_keyring_free(ring, true);
+	l_key_free(key2, true);
 }
 =

 static void test_trusted_keyring(const void *data)
@@ -400,10 +400,10 @@ static void test_trusted_keyring(const void *data)
 	success =3D l_keyring_link(ring, key);
 	assert(success);
 =

-	l_keyring_free(trust);
-	l_keyring_free(ring);
-	l_key_free(cakey);
-	l_key_free(key);
+	l_keyring_free(trust, true);
+	l_keyring_free(ring, true);
+	l_key_free(cakey, true);
+	l_key_free(key, true);
 	l_free(cacert);
 	l_free(cert);
 }
@@ -457,10 +457,10 @@ static void test_trust_chain(const void *data)
 	success =3D l_keyring_link(ring, key);
 	assert(success);
 =

-	l_keyring_free(trust);
-	l_keyring_free(ring);
-	l_key_free(cakey);
-	l_key_free(key);
+	l_keyring_free(trust, true);
+	l_keyring_free(ring, true);
+	l_key_free(cakey, true);
+	l_key_free(key, true);
 	l_free(cacert);
 	l_free(cert);
 }
@@ -638,8 +638,8 @@ static void test_key_crypto(const void *data)
 				strlen(plaintext), sizeof(ciphertext));
 	assert(!success);
 =

-	l_key_free(key);
-	l_key_free(pubkey);
+	l_key_free(key, true);
+	l_key_free(pubkey, true);
 	l_free(cert);
 	l_free(pubcert);
 }
-- =

2.10.1


--===============4474975412583807397==--

