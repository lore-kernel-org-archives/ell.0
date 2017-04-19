Content-Type: multipart/mixed; boundary="===============4501798025682848371=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 2/3] unit: Update key restriction unit tests for modified
 l_keyring API
Date: Tue, 18 Apr 2017 17:24:18 -0700
Message-ID: <20170419002419.9762-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20170419002419.9762-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4501798025682848371==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/unit/test-key.c b/unit/test-key.c
index 455ebb4..067f016 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -347,7 +347,7 @@ static void test_simple_keyring(const void *data)
 	struct l_key *key2;
 	bool success;
 =

-	ring =3D l_keyring_new(L_KEYRING_SIMPLE, NULL);
+	ring =3D l_keyring_new();
 	assert(ring);
 =

 	key1 =3D l_key_new(L_KEY_RAW, "1", 1);
@@ -388,10 +388,12 @@ static void test_trusted_keyring(const void *data)
 	key =3D l_key_new(L_KEY_RSA, cert, certlen);
 	assert(key);
 =

-	trust =3D l_keyring_new(L_KEYRING_SIMPLE, NULL);
+	trust =3D l_keyring_new();
 	assert(trust);
-	ring =3D l_keyring_new(L_KEYRING_TRUSTED_ASYM, trust);
+	ring =3D l_keyring_new();
 	assert(ring);
+	success =3D l_keyring_restrict(ring, L_KEYRING_RESTRICT_ASYM, trust);
+	assert(success);
 =

 	success =3D l_keyring_link(ring, key);
 	assert(!success);
@@ -439,11 +441,14 @@ static void test_trust_chain(const void *data)
 	key =3D l_key_new(L_KEY_RSA, cert, certlen);
 	assert(key);
 =

-	trust =3D l_keyring_new(L_KEYRING_SIMPLE, NULL);
+	trust =3D l_keyring_new();
 	assert(trust);
-	ring =3D l_keyring_new(L_KEYRING_TRUSTED_ASYM_CHAIN, trust);
+	ring =3D l_keyring_new();
 	assert(ring);
 =

+	success =3D l_keyring_restrict(ring, L_KEYRING_RESTRICT_ASYM_CHAIN,
+					trust);
+	assert(success);
 	success =3D l_keyring_link(ring, key);
 	assert(!success);
 	success =3D l_keyring_link(ring, intkey);
-- =

2.12.2


--===============4501798025682848371==--

