Content-Type: multipart/mixed; boundary="===============0828751376680013388=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/5] unit: Test l_keyring_link_nested and more scenarios
Date: Fri, 23 Nov 2018 10:44:28 +0100
Message-ID: <20181123094429.7190-4-andrew.zaborowski@intel.com>
In-Reply-To: <20181123094429.7190-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0828751376680013388==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 42 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 40 insertions(+), 2 deletions(-)

diff --git a/unit/test-key.c b/unit/test-key.c
index f4235b9..53fb394 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -438,6 +438,7 @@ static void test_trust_chain(const void *data)
 {
 	struct l_keyring *ring;
 	struct l_keyring *trust;
+	struct l_keyring *trust2;
 	struct l_cert *cacert;
 	struct l_cert *intcert;
 	struct l_cert *cert;
@@ -462,6 +463,8 @@ static void test_trust_chain(const void *data)
 =

 	trust =3D l_keyring_new();
 	assert(trust);
+	trust2 =3D l_keyring_new();
+	assert(trust2);
 	ring =3D l_keyring_new();
 	assert(ring);
 =

@@ -480,11 +483,46 @@ static void test_trust_chain(const void *data)
 	assert(success);
 	success =3D l_keyring_link(ring, key);
 	assert(success);
+	success =3D l_keyring_link_nested(ring, trust);
+	assert(!success);
+	success =3D l_keyring_link_nested(ring, trust2);
+	assert(!success);
+	success =3D l_keyring_link_nested(ring, ring);
+	assert(!success);
+	success =3D l_keyring_unlink(ring, key);
+	assert(success);
+	success =3D l_keyring_unlink(ring, intkey);
+	assert(success);
+	l_key_free(cakey);
+	success =3D l_keyring_unlink(ring, intkey);
+	assert(!success);
+	success =3D l_keyring_link_nested(trust, trust2);
+	assert(success);
+	success =3D l_keyring_link(ring, key);
+	assert(!success);
+	success =3D l_keyring_link(trust2, intkey);
+	assert(success);
+	success =3D l_keyring_link(ring, key);
+	assert(success);
+	success =3D l_keyring_unlink(ring, key);
+	assert(success);
+	success =3D l_keyring_unlink_nested(trust, trust2);
+	assert(success);
+	success =3D l_keyring_link(ring, key);
+	assert(!success);
+	success =3D l_keyring_link_nested(trust, trust2);
+	assert(success);
+	l_keyring_free_norevoke(trust2);
+	success =3D l_keyring_link(ring, key);
+	assert(success);
+	success =3D l_keyring_unlink(ring, key);
+	assert(success);
+	l_key_free_norevoke(intkey);
+	success =3D l_keyring_link(ring, key);
+	assert(success);
 =

 	l_keyring_free(trust);
 	l_keyring_free(ring);
-	l_key_free(cakey);
-	l_key_free(intkey);
 	l_key_free(key);
 	l_cert_free(cacert);
 	l_cert_free(intcert);
-- =

2.19.1


--===============0828751376680013388==--

