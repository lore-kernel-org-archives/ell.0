Content-Type: multipart/mixed; boundary="===============0146305935547115769=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 6/9] unit: Move tls_cert_load_file to relevant unit tests
Date: Thu, 13 Dec 2018 20:57:43 +0100
Message-ID: <20181213195746.32144-6-andrew.zaborowski@intel.com>
In-Reply-To: <20181213195746.32144-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0146305935547115769==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

tls_cert_load_file and l_pem_load_certificate have no users other than
the two unit tests and have little to do with TLS.
---
 unit/test-key.c | 26 ++++++++++++++++++++------
 unit/test-tls.c | 28 +++++++++++++++++++++-------
 2 files changed, 41 insertions(+), 13 deletions(-)

diff --git a/unit/test-key.c b/unit/test-key.c
index 53fb394..6b519f5 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -392,6 +392,20 @@ static void test_simple_keyring(const void *data)
 	l_key_free(key2);
 }
 =

+static struct l_cert *load_cert_file(const char *filename)
+{
+	const uint8_t *der;
+	size_t len;
+	char *label;
+
+	der =3D l_pem_load_file(filename, 0, &label, &len);
+	if (!der)
+		return NULL;
+
+	l_free(label);
+	return l_cert_new_from_der(der, len);
+}
+
 static void test_trusted_keyring(const void *data)
 {
 	struct l_keyring *ring;
@@ -402,9 +416,9 @@ static void test_trusted_keyring(const void *data)
 	struct l_key *key;
 	bool success;
 =

-	cacert =3D tls_cert_load_file(CERTDIR "cert-ca.pem");
+	cacert =3D load_cert_file(CERTDIR "cert-ca.pem");
 	assert(cacert);
-	cert =3D tls_cert_load_file(CERTDIR "cert-server.pem");
+	cert =3D load_cert_file(CERTDIR "cert-server.pem");
 	assert(cert);
 =

 	cakey =3D l_cert_get_pubkey(cacert);
@@ -447,11 +461,11 @@ static void test_trust_chain(const void *data)
 	struct l_key *key;
 	bool success;
 =

-	cacert =3D tls_cert_load_file(CERTDIR "cert-ca.pem");
+	cacert =3D load_cert_file(CERTDIR "cert-ca.pem");
 	assert(cacert);
-	intcert =3D tls_cert_load_file(CERTDIR "cert-intca.pem");
+	intcert =3D load_cert_file(CERTDIR "cert-intca.pem");
 	assert(intcert);
-	cert =3D tls_cert_load_file(CERTDIR "cert-entity-int.pem");
+	cert =3D load_cert_file(CERTDIR "cert-entity-int.pem");
 	assert(cert);
 =

 	cakey =3D l_cert_get_pubkey(cacert);
@@ -543,7 +557,7 @@ static void test_key_crypto(const void *data)
 	int hash =3D L_CHECKSUM_NONE;
 	int rsa =3D L_KEY_RSA_PKCS1_V1_5;
 =

-	cert =3D tls_cert_load_file(CERTDIR "cert-client.pem");
+	cert =3D load_cert_file(CERTDIR "cert-client.pem");
 	assert(cert);
 	pubkey =3D l_cert_get_pubkey(cert);
 	assert(pubkey);
diff --git a/unit/test-tls.c b/unit/test-tls.c
index f39d95a..2b5d16b 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -210,6 +210,20 @@ static void test_tls12_prf(const void *data)
 	assert(!memcmp(out_buf, test->expected, test->out_len));
 }
 =

+static struct l_cert *load_cert_file(const char *filename)
+{
+	const uint8_t *der;
+	size_t len;
+	char *label;
+
+	der =3D l_pem_load_file(filename, 0, &label, &len);
+	if (!der)
+		return NULL;
+
+	l_free(label);
+	return l_cert_new_from_der(der, len);
+}
+
 static void test_certificates(const void *data)
 {
 	struct l_queue *cacert;
@@ -246,13 +260,13 @@ static void test_certificates(const void *data)
 	assert(l_certchain_verify(chain2, twocas, NULL));
 =

 	chain3 =3D certchain_new_from_leaf(
-			tls_cert_load_file(CERTDIR "cert-server.pem"));
+			load_cert_file(CERTDIR "cert-server.pem"));
 	certchain_link_issuer(chain3,
-			tls_cert_load_file(CERTDIR "cert-entity-int.pem"));
+			load_cert_file(CERTDIR "cert-entity-int.pem"));
 	certchain_link_issuer(chain3,
-			tls_cert_load_file(CERTDIR "cert-intca.pem"));
+			load_cert_file(CERTDIR "cert-intca.pem"));
 	certchain_link_issuer(chain3,
-			tls_cert_load_file(CERTDIR "cert-ca.pem"));
+			load_cert_file(CERTDIR "cert-ca.pem"));
 	assert(chain3);
 =

 	assert(!l_certchain_verify(chain3, wrongca, NULL));
@@ -261,11 +275,11 @@ static void test_certificates(const void *data)
 	assert(!l_certchain_verify(chain3, twocas, NULL));
 =

 	chain4 =3D certchain_new_from_leaf(
-			tls_cert_load_file(CERTDIR "cert-entity-int.pem"));
+			load_cert_file(CERTDIR "cert-entity-int.pem"));
 	certchain_link_issuer(chain4,
-			tls_cert_load_file(CERTDIR "cert-intca.pem"));
+			load_cert_file(CERTDIR "cert-intca.pem"));
 	certchain_link_issuer(chain4,
-			tls_cert_load_file(CERTDIR "cert-ca.pem"));
+			load_cert_file(CERTDIR "cert-ca.pem"));
 	assert(chain4);
 =

 	assert(!l_certchain_verify(chain4, wrongca, NULL));
-- =

2.19.1


--===============0146305935547115769==--

