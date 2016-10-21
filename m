Content-Type: multipart/mixed; boundary="===============5300676571134642053=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 4/4] unit: Add L_KEYRING_TRUSTED_ASYM_CHAIN test
Date: Fri, 21 Oct 2016 13:52:26 -0700
Message-ID: <20161021205226.419-4-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20161021205226.419-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5300676571134642053==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 58 +++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 58 insertions(+)

diff --git a/unit/test-key.c b/unit/test-key.c
index 80a1916..1195da4 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -408,6 +408,63 @@ static void test_trusted_keyring(const void *data)
 	l_free(cert);
 }
 =

+static void test_trust_chain(const void *data)
+{
+	struct l_keyring *ring;
+	struct l_keyring *trust;
+	uint8_t *cacert;
+	size_t cacertlen;
+	uint8_t *intcert;
+	size_t intcertlen;
+	uint8_t *cert;
+	size_t certlen;
+	struct l_key *cakey;
+	struct l_key *intkey;
+	struct l_key *key;
+	bool success;
+
+	cacert =3D l_pem_load_certificate(TESTDATADIR "/cert-ca.pem", &cacertlen);
+	assert(cacert);
+	intcert =3D l_pem_load_certificate(TESTDATADIR "/cert-intca.pem",
+						&intcertlen);
+	assert(intcert);
+	cert =3D l_pem_load_certificate(TESTDATADIR "/cert-entity-int.pem",
+					&certlen);
+	assert(cert);
+
+	cakey =3D l_key_new(L_KEY_RSA, cacert, cacertlen);
+	assert(cakey);
+	intkey =3D l_key_new(L_KEY_RSA, intcert, intcertlen);
+	assert(intkey);
+	key =3D l_key_new(L_KEY_RSA, cert, certlen);
+	assert(key);
+
+	trust =3D l_keyring_new(L_KEYRING_SIMPLE, NULL);
+	assert(trust);
+	ring =3D l_keyring_new(L_KEYRING_TRUSTED_ASYM_CHAIN, trust);
+	assert(ring);
+
+	success =3D l_keyring_link(ring, key);
+	assert(!success);
+	success =3D l_keyring_link(ring, intkey);
+	assert(!success);
+	success =3D l_keyring_link(trust, cakey);
+	assert(success);
+	success =3D l_keyring_link(ring, key);
+	assert(!success);
+	success =3D l_keyring_link(ring, intkey);
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
 /* Reference ciphertext:
  * $ openssl rsautl -in reference_plaintext -inkey cert-client.pem -encryp=
t \
  * > -pkcs -out reference_ciphertext
@@ -600,6 +657,7 @@ int main(int argc, char *argv[])
 =

 	l_test_add("simple keyring", test_simple_keyring, NULL);
 	l_test_add("trusted keyring", test_trusted_keyring, NULL);
+	l_test_add("trust chain", test_trust_chain, NULL);
 =

 	l_test_add("key crypto", test_key_crypto, NULL);
 =

-- =

2.10.1


--===============5300676571134642053==--

