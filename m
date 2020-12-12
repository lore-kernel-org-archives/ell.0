Content-Type: multipart/mixed; boundary="===============7222601954530737300=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/5] unit: Add l_pem_load_container_file tests
Date: Sat, 12 Dec 2020 01:51:00 +0100
Message-ID: <20201212005100.578174-5-andrew.zaborowski@intel.com>
In-Reply-To: <20201212005100.578174-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7222601954530737300==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-pem.c | 118 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 118 insertions(+)

diff --git a/unit/test-pem.c b/unit/test-pem.c
index f875adc..eddb6c6 100644
--- a/unit/test-pem.c
+++ b/unit/test-pem.c
@@ -337,6 +337,74 @@ static void test_encrypted_pkey(const void *data)
 	l_key_free(pkey2);
 }
 =

+static bool test_cert_count(struct l_cert *cert, void *user_data)
+{
+	int *count =3D user_data;
+
+	(*count)++;
+	return false;
+}
+
+struct test_load_file_params {
+	const char *path;
+	bool expect_cert;
+	bool expect_certchain;
+	bool expect_privkey;
+	bool expect_encrypted;
+};
+
+#define TEST_LOAD_PARAMS(fn, cert, certchain, privkey, encrypted)	\
+	(&(struct test_load_file_params) {				\
+		CERTDIR fn, (cert), (certchain), (privkey), (encrypted) })
+
+static void test_load_file(const void *data)
+{
+	const struct test_load_file_params *params =3D data;
+	struct l_certchain *certchain;
+	struct l_key *privkey;
+	bool encrypted;
+
+	l_pem_load_container_file(params->path, false, &certchain,
+					&privkey, &encrypted);
+	assert(encrypted =3D=3D params->expect_encrypted);
+
+	if (encrypted) {
+		/*
+		 * Depending on the format the certificates may be encrypted
+		 * or unencrypted even when the private key was encrypted.
+		 */
+		if (certchain) {
+			assert(params->expect_privkey);
+			l_certchain_free(certchain);
+			certchain =3D NULL;
+		}
+
+		assert(!privkey);
+
+		l_pem_load_container_file(params->path, "abc", &certchain,
+						&privkey, &encrypted);
+	}
+
+	assert(!!certchain =3D=3D params->expect_cert);
+	assert(!!privkey =3D=3D params->expect_privkey);
+
+	if (certchain) {
+		int count =3D 0;
+
+		l_certchain_walk_from_leaf(certchain, test_cert_count, &count);
+		assert(count =3D=3D (params->expect_certchain ? 3 : 1));
+
+		if (params->expect_certchain)
+			assert(l_certchain_verify(certchain, NULL, NULL));
+	}
+
+	if (certchain)
+		l_certchain_free(certchain);
+
+	if (privkey)
+		l_key_free(privkey);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -409,6 +477,56 @@ int main(int argc, char *argv[])
 				CERTDIR "cert-client-key-pkcs1-aes256.pem");
 	}
 =

+	l_test_add("detect-format/PEM PKCS#1 unencrypted private key",
+			test_load_file,
+			TEST_LOAD_PARAMS("cert-client-key-pkcs1.pem",
+						false, false, true, false));
+	l_test_add("detect-format/PEM PKCS#1 encrypted private key",
+			test_load_file,
+			TEST_LOAD_PARAMS("cert-client-key-pkcs1-des.pem",
+						false, false, true, true));
+	l_test_add("detect-format/PEM PKCS#8 unencrypted private key",
+			test_load_file,
+			TEST_LOAD_PARAMS("cert-client-key-pkcs8.pem",
+						false, false, true, false));
+	l_test_add("detect-format/PEM PKCS#8 encrypted private key",
+			test_load_file,
+			TEST_LOAD_PARAMS("cert-client-key-pkcs8-sha1-des.pem",
+						false, false, true, true));
+	l_test_add("detect-format/PEM X.509 certificate",
+			test_load_file,
+			TEST_LOAD_PARAMS("cert-client.pem",
+						true, false, false, false));
+	l_test_add("detect-format/DER X.509 certificate",
+			test_load_file,
+			TEST_LOAD_PARAMS("cert-client.crt",
+						true, false, false, false));
+	l_test_add("detect-format/PEM combined",
+			test_load_file,
+			TEST_LOAD_PARAMS("cert-entity-combined.pem",
+						true, true, true, true));
+	l_test_add("detect-format/DER PKCS#12 combined",
+			test_load_file,
+			TEST_LOAD_PARAMS("cert-entity-pkcs12-nomac.p12",
+						true, false, true, true));
+
+	l_test_add("pkcs#12/Combined RC2-based ciphers + SHA1",
+			test_load_file,
+			TEST_LOAD_PARAMS("cert-entity-pkcs12-rc2-sha1.p12",
+						true, true, true, true));
+	l_test_add("pkcs#12/Combined DES-based ciphers + SHA256",
+			test_load_file,
+			TEST_LOAD_PARAMS("cert-entity-pkcs12-des-sha256.p12",
+						true, true, true, true));
+	l_test_add("pkcs#12/Combined RC4-based ciphers + SHA384",
+			test_load_file,
+			TEST_LOAD_PARAMS("cert-entity-pkcs12-rc4-sha384.p12",
+						true, true, true, true));
+	l_test_add("pkcs#12/Combined PKCS#5 ciphers + SHA512",
+			test_load_file,
+			TEST_LOAD_PARAMS("cert-entity-pkcs12-pkcs5-sha512.p12",
+						true, true, true, true));
+
 done:
 	return l_test_run();
 }
-- =

2.27.0

--===============7222601954530737300==--

