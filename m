Content-Type: multipart/mixed; boundary="===============3598130918450998113=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/2] key: Use keyring restriction keyctl
Date: Fri, 14 Apr 2017 12:16:48 -0700
Message-ID: <20170414191649.3171-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3598130918450998113==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Now that the restricted keyring patches have been applied to keys-next
and are on track for the v4.12 merge window, ELL needs to be updated for
the final API.

There are two significant changes from the previous API:

1. Key restrictions are now applied in a separate step after a keyring
is created, not at creation time.

2. The first key added to an empty, "chain" restricted keyring no longer
bypasses the signature check.

The latter required a change to l_keyring_new() so that the root key
could be added to a keyring after it is created but before it is
restricted. There's a new l_keyring_restrict() function to restrict an
existing keyring.
---
 ell/key.c | 76 ++++++++++++++++++++++++++++++++++++++++-------------------=
----
 ell/key.h | 13 ++++++-----
 ell/tls.c | 20 ++++++++++++-----
 3 files changed, 69 insertions(+), 40 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index db9abb1..fba400f 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -81,6 +81,10 @@ struct keyctl_pkey_params {
 };
 #endif
 =

+#ifndef KEYCTL_RESTRICT_KEYRING
+#define KEYCTL_RESTRICT_KEYRING 29
+#endif
+
 static int32_t internal_keyring;
 =

 struct l_key {
@@ -89,7 +93,6 @@ struct l_key {
 };
 =

 struct l_keyring {
-	int type;
 	int32_t serial;
 };
 =

@@ -208,6 +211,17 @@ static long kernel_dh_compute(int32_t private, int32_t=
 prime, int32_t base,
 	return result >=3D 0 ? result : -errno;
 }
 =

+static long kernel_restrict_keyring(int32_t serial, const char *keytype,
+					const char *restriction)
+{
+	long result;
+
+	result =3D syscall(__NR_keyctl, KEYCTL_RESTRICT_KEYRING, serial, keytype,
+				restriction);
+
+	return result >=3D 0 ? result : -errno;
+}
+
 static long kernel_key_eds(int op, int32_t serial, const char *encoding,
 				const char *hash, const void *in, void *out,
 				size_t len_in, size_t len_out)
@@ -655,32 +669,47 @@ LIB_EXPORT bool l_key_verify(struct l_key *key,
 		(memcmp(data, compare_hash, hash_len) =3D=3D 0);
 }
 =

-LIB_EXPORT struct l_keyring *l_keyring_new(enum l_keyring_type type,
-						const struct l_keyring *trusted)
+LIB_EXPORT struct l_keyring *l_keyring_new(void)
 {
 	struct l_keyring *keyring;
 	char *description;
-	char *payload =3D NULL;
-	size_t payload_length =3D 0;
 =

 	if (!internal_keyring && !setup_internal_keyring())
 		return NULL;
 =

-	switch (type) {
-	case L_KEYRING_SIMPLE:
-		break;
-	case L_KEYRING_TRUSTED_ASYM:
-	case L_KEYRING_TRUSTED_ASYM_CHAIN:
+	keyring =3D l_new(struct l_keyring, 1);
+	description =3D l_strdup_printf("ell-keyring-%p", keyring);
+	keyring->serial =3D kernel_add_key("keyring", description, NULL, 0,
+						internal_keyring);
+	l_free(description);
+
+	if (keyring->serial < 0) {
+		l_free(keyring);
+		return NULL;
+	}
+
+	return keyring;
+}
+
+LIB_EXPORT bool l_keyring_restrict(struct l_keyring *keyring,
+					enum l_keyring_restriction res,
+					const struct l_keyring *trusted)
+{
+	char *restriction =3D NULL;
+	long result;
+
+	switch (res) {
+	case L_KEYRING_RESTRICT_ASYM:
+	case L_KEYRING_RESTRICT_ASYM_CHAIN:
 	{
 		char *option =3D "";
 =

-		if (type =3D=3D L_KEYRING_TRUSTED_ASYM_CHAIN)
+		if (res =3D=3D L_KEYRING_RESTRICT_ASYM_CHAIN)
 			option =3D ":chain";
 =

-		payload =3D l_strdup_printf(
-			"restrict=3Dasymmetric:key_or_keyring:%d%s",
-			trusted ? trusted->serial : 0, option);
-		payload_length =3D strlen(payload);
+		restriction =3D l_strdup_printf("key_or_keyring:%d%s",
+						trusted ? trusted->serial : 0,
+						option);
 =

 		break;
 	}
@@ -689,21 +718,12 @@ LIB_EXPORT struct l_keyring *l_keyring_new(enum l_key=
ring_type type,
 		return NULL;
 	}
 =

-	keyring =3D l_new(struct l_keyring, 1);
-	keyring->type =3D type;
-	description =3D l_strdup_printf("ell-keyring-%p", keyring);
-	keyring->serial =3D kernel_add_key("keyring", description, payload,
-						payload_length,
-						internal_keyring);
-	l_free(description);
-	l_free(payload);
+	result =3D kernel_restrict_keyring(keyring->serial, "asymmetric",
+						restriction);
 =

-	if (keyring->serial < 0) {
-		l_free(keyring);
-		keyring =3D NULL;
-	}
+	l_free(restriction);
 =

-	return keyring;
+	return result =3D=3D 0;
 }
 =

 LIB_EXPORT void l_keyring_free(struct l_keyring *keyring)
diff --git a/ell/key.h b/ell/key.h
index 35c63eb..717bd44 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -40,10 +40,9 @@ enum l_key_type {
 	L_KEY_RSA,
 };
 =

-enum l_keyring_type {
-	L_KEYRING_SIMPLE =3D 0,
-	L_KEYRING_TRUSTED_ASYM,
-	L_KEYRING_TRUSTED_ASYM_CHAIN,
+enum l_keyring_restriction {
+	L_KEYRING_RESTRICT_ASYM =3D 0,
+	L_KEYRING_RESTRICT_ASYM_CHAIN,
 };
 =

 enum l_key_cipher_type {
@@ -89,8 +88,10 @@ bool l_key_verify(struct l_key *key, enum l_key_cipher_t=
ype cipher,
 			enum l_checksum_type checksum, const void *data,
 			const void *sig, size_t len_data, size_t len_sig);
 =

-struct l_keyring *l_keyring_new(enum l_keyring_type type,
-				const struct l_keyring *trust);
+struct l_keyring *l_keyring_new(void);
+
+bool l_keyring_restrict(struct l_keyring *keyring, enum l_keyring_restrict=
ion res,
+			const struct l_keyring *trust);
 =

 void l_keyring_free(struct l_keyring *keyring);
 void l_keyring_free_norevoke(struct l_keyring *keyring);
diff --git a/ell/tls.c b/ell/tls.c
index 06e3341..cd85fad 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2471,7 +2471,8 @@ static void tls_key_cleanup(struct l_key **p)
 =

 static int tls_cert_verify_with_keyring(struct tls_cert *cert,
 						struct l_keyring *ring,
-						struct tls_cert *root)
+						struct tls_cert *root,
+						struct l_keyring *trusted)
 {
 	if (!cert)
 		return true;
@@ -2488,14 +2489,21 @@ static int tls_cert_verify_with_keyring(struct tls_=
cert *cert,
 			!memcmp(cert->asn1, root->asn1, root->size))
 		return true;
 =

-	if (tls_cert_verify_with_keyring(cert->issuer, ring, root)) {
+	if (tls_cert_verify_with_keyring(cert->issuer, ring, root, trusted)) {
+		bool result;
 		L_AUTO_CLEANUP_VAR(struct l_key *, key, tls_key_cleanup);
 =

 		key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->size);
 		if (!key)
 			return false;
 =

-		return l_keyring_link(ring, key);
+		result =3D l_keyring_link(ring, key);
+
+		if (result && !cert->issuer)
+			result =3D l_keyring_restrict(ring, L_KEYRING_RESTRICT_ASYM_CHAIN,
+							trusted);
+
+		return result;
 	}
 =

 	return false;
@@ -2520,7 +2528,7 @@ bool tls_cert_verify_certchain(struct tls_cert *certc=
hain,
 		L_AUTO_CLEANUP_VAR(struct l_key *, ca_key, tls_key_cleanup);
 		ca_key =3D NULL;
 =

-		ca_ring =3D l_keyring_new(L_KEYRING_SIMPLE, NULL);
+		ca_ring =3D l_keyring_new();
 		if (!ca_ring)
 			return false;
 =

@@ -2529,11 +2537,11 @@ bool tls_cert_verify_certchain(struct tls_cert *cer=
tchain,
 			return false;
 	}
 =

-	verify_ring =3D l_keyring_new(L_KEYRING_TRUSTED_ASYM_CHAIN, ca_ring);
+	verify_ring =3D l_keyring_new();
 	if (!verify_ring)
 		return false;
 =

-	return tls_cert_verify_with_keyring(certchain, verify_ring, ca_cert);
+	return tls_cert_verify_with_keyring(certchain, verify_ring, ca_cert, ca_r=
ing);
 }
 =

 void tls_cert_free_certchain(struct tls_cert *cert)
-- =

2.12.2


--===============3598130918450998113==--

