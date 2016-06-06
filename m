Content-Type: multipart/mixed; boundary="===============3211619355062968005=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 07/11] unit: Keyring tests
Date: Mon, 06 Jun 2016 13:54:46 -0700
Message-ID: <20160606205450.23615-7-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160606205450.23615-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3211619355062968005==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 71 +++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 71 insertions(+)

diff --git a/unit/test-key.c b/unit/test-key.c
index 53232da..df1e13b 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -332,6 +332,74 @@ static void test_dh(const void *data)
 	l_free(buffer);
 }
 =

+static void test_simple_keyring(const void *data)
+{
+	struct l_keyring *ring;
+	struct l_key *key1;
+	struct l_key *key2;
+	bool success;
+
+	ring =3D l_keyring_new(L_KEYRING_SIMPLE, NULL);
+	assert(ring);
+
+	key1 =3D l_key_new(L_KEY_RAW, "1", 1);
+	key2 =3D l_key_new(L_KEY_RAW, "2", 1);
+
+	success =3D l_keyring_link(ring, key1);
+	assert(success);
+	success =3D l_keyring_link(ring, key2);
+	assert(success);
+
+	l_key_free(key1);
+	success =3D l_keyring_unlink(ring, key2);
+	assert(success);
+	l_keyring_free(ring);
+	l_key_free(key2);
+}
+
+static void test_trusted_keyring(const void *data)
+{
+	struct l_keyring *ring;
+	struct l_keyring *trust;
+	uint8_t *cacert;
+	size_t cacertlen;
+	uint8_t *cert;
+	size_t certlen;
+	struct l_key *cakey;
+	struct l_key *key;
+	bool success;
+
+	cacert =3D l_pem_load_certificate(TESTDATADIR "/cert-ca.pem", &cacertlen);
+	assert(cacert);
+	cert =3D l_pem_load_certificate(TESTDATADIR "/cert-server.pem",
+					&certlen);
+	assert(cert);
+
+	cakey =3D l_key_new(L_KEY_ASYMMETRIC, cacert, cacertlen);
+	assert(cakey);
+	key =3D l_key_new(L_KEY_ASYMMETRIC, cert, certlen);
+	assert(key);
+
+	trust =3D l_keyring_new(L_KEYRING_SIMPLE, NULL);
+	assert(trust);
+	ring =3D l_keyring_new(L_KEYRING_TRUSTED_ASYM, trust);
+	assert(ring);
+
+	success =3D l_keyring_link(ring, key);
+	assert(!success);
+	success =3D l_keyring_link(trust, cakey);
+	assert(success);
+	success =3D l_keyring_link(ring, key);
+	assert(success);
+
+	l_keyring_free(trust);
+	l_keyring_free(ring);
+	l_key_free(cakey);
+	l_key_free(key);
+	l_free(cacert);
+	l_free(cert);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -343,5 +411,8 @@ int main(int argc, char *argv[])
 	l_test_add("Diffie-Hellman 1", test_dh, &dh_valid1);
 	l_test_add("Diffie-Hellman 2", test_dh, &dh_valid2);
 =

+	l_test_add("simple keyring", test_simple_keyring, NULL);
+	l_test_add("trusted keyring", test_trusted_keyring, NULL);
+
 	return l_test_run();
 }
-- =

2.8.3


--===============3211619355062968005==--

