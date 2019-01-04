Content-Type: multipart/mixed; boundary="===============7065215494698982048=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 05/12] tls: Allow user to set custom list of cipher suites
Date: Fri, 04 Jan 2019 02:26:33 +0100
Message-ID: <20190104012640.4022-5-andrew.zaborowski@intel.com>
In-Reply-To: <20190104012640.4022-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7065215494698982048==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

TLS "security profiles" define which minimum cipher suites and other
parameter values are allowed in a specific usage scenario for TLS, for
example WPA3 in theory requires a specific security profile for its
TLS-based EAP method.  This will also allow the unit tests to test
individual cipher suites.
---
 ell/tls-private.h |   5 +
 ell/tls.c         | 260 +++++++++++++++++++++++++++++++---------------
 2 files changed, 181 insertions(+), 84 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index d1cfcac..938c358 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -180,6 +180,8 @@ struct l_tls {
 	struct l_key *priv_key;
 	size_t priv_key_size;
 =

+	struct tls_cipher_suite **cipher_suite_pref_list;
+
 	/* Record layer */
 =

 	uint8_t *record_buf;
@@ -267,6 +269,9 @@ void tls_tx_record(struct l_tls *tls, enum tls_content_=
type type,
 bool tls_handle_message(struct l_tls *tls, const uint8_t *message,
 			int len, enum tls_content_type type, uint16_t version);
 =

+/* Optionally limit allowed cipher suites to a custom set */
+bool tls_set_cipher_suites(struct l_tls *tls, const char **suite_list);
+
 int tls_parse_certificate_list(const void *data, size_t len,
 				struct l_certchain **out_certchain);
 =

diff --git a/ell/tls.c b/ell/tls.c
index 3ef76f8..413d80c 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -41,6 +41,7 @@
 #include "tls-private.h"
 #include "key.h"
 #include "asn1-private.h"
+#include "strv.h"
 =

 bool tls10_prf(const void *secret, size_t secret_len,
 		const char *label,
@@ -453,78 +454,80 @@ static struct tls_mac_algorithm tls_md5 =3D {
 	.mac_length =3D 32,
 };
 =

-static struct tls_cipher_suite tls_cipher_suite_pref[] =3D {
-	{
-		.id =3D { 0x00, 0x35 },
-		.name =3D "TLS_RSA_WITH_AES_256_CBC_SHA",
-		.verify_data_length =3D 12,
-		.encryption =3D &tls_aes256,
-		.mac =3D &tls_sha,
-		.key_xchg =3D &tls_rsa,
-	},
-	{
-		.id =3D { 0x00, 0x2f },
-		.name =3D "TLS_RSA_WITH_AES_128_CBC_SHA",
-		.verify_data_length =3D 12,
-		.encryption =3D &tls_aes128,
-		.mac =3D &tls_sha,
-		.key_xchg =3D &tls_rsa,
-	},
-	{
-		.id =3D { 0x00, 0x3d },
-		.name =3D "TLS_RSA_WITH_AES_256_CBC_SHA256",
-		.verify_data_length =3D 12,
-		.encryption =3D &tls_aes256,
-		.mac =3D &tls_sha256,
-		.key_xchg =3D &tls_rsa,
-	},
-	{
-		.id =3D { 0x00, 0x3c },
-		.name =3D "TLS_RSA_WITH_AES_128_CBC_SHA256",
-		.verify_data_length =3D 12,
-		.encryption =3D &tls_aes128,
-		.mac =3D &tls_sha256,
-		.key_xchg =3D &tls_rsa,
-	},
-	{
-		.id =3D { 0x00, 0x9d },
-		.name =3D "TLS_RSA_WITH_AES_256_GCM_SHA384",
-		.verify_data_length =3D 12,
-		.encryption =3D &tls_aes256_gcm,
-		.prf_hmac =3D L_CHECKSUM_SHA384,
-		.key_xchg =3D &tls_rsa,
-	},
-	{
-		.id =3D { 0x00, 0x9c },
-		.name =3D "TLS_RSA_WITH_AES_128_GCM_SHA256",
-		.verify_data_length =3D 12,
-		.encryption =3D &tls_aes128_gcm,
-		.key_xchg =3D &tls_rsa,
-	},
-	{
-		.id =3D { 0x00, 0x0a },
-		.name =3D "TLS_RSA_WITH_3DES_EDE_CBC_SHA",
-		.verify_data_length =3D 12,
-		.encryption =3D &tls_3des_ede,
-		.mac =3D &tls_sha,
-		.key_xchg =3D &tls_rsa,
-	},
-	{
-		.id =3D { 0x00, 0x05 },
-		.name =3D "TLS_RSA_WITH_RC4_128_SHA",
-		.verify_data_length =3D 12,
-		.encryption =3D &tls_rc4,
-		.mac =3D &tls_sha,
-		.key_xchg =3D &tls_rsa,
-	},
-	{
-		.id =3D { 0x00, 0x04 },
-		.name =3D "TLS_RSA_WITH_RC4_128_MD5",
-		.verify_data_length =3D 12,
-		.encryption =3D &tls_rc4,
-		.mac =3D &tls_md5,
-		.key_xchg =3D &tls_rsa,
-	},
+static struct tls_cipher_suite tls_rsa_with_rc4_128_md5 =3D {
+	.id =3D { 0x00, 0x04 },
+	.name =3D "TLS_RSA_WITH_RC4_128_MD5",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_rc4,
+	.mac =3D &tls_md5,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_rc4_128_sha =3D {
+	.id =3D { 0x00, 0x05 },
+	.name =3D "TLS_RSA_WITH_RC4_128_SHA",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_rc4,
+	.mac =3D &tls_sha,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_3des_ede_cbc_sha =3D {
+	.id =3D { 0x00, 0x0a },
+	.name =3D "TLS_RSA_WITH_3DES_EDE_CBC_SHA",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_3des_ede,
+	.mac =3D &tls_sha,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_aes_128_cbc_sha =3D {
+	.id =3D { 0x00, 0x2f },
+	.name =3D "TLS_RSA_WITH_AES_128_CBC_SHA",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes128,
+	.mac =3D &tls_sha,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_aes_256_cbc_sha =3D {
+	.id =3D { 0x00, 0x35 },
+	.name =3D "TLS_RSA_WITH_AES_256_CBC_SHA",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes256,
+	.mac =3D &tls_sha,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_aes_128_cbc_sha256 =3D {
+	.id =3D { 0x00, 0x3c },
+	.name =3D "TLS_RSA_WITH_AES_128_CBC_SHA256",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes128,
+	.mac =3D &tls_sha256,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_aes_256_cbc_sha256 =3D {
+	.id =3D { 0x00, 0x3d },
+	.name =3D "TLS_RSA_WITH_AES_256_CBC_SHA256",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes256,
+	.mac =3D &tls_sha256,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_aes_128_gcm_sha256 =3D {
+	.id =3D { 0x00, 0x9c },
+	.name =3D "TLS_RSA_WITH_AES_128_GCM_SHA256",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes128_gcm,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_aes_256_gcm_sha384 =3D {
+	.id =3D { 0x00, 0x9d },
+	.name =3D "TLS_RSA_WITH_AES_256_GCM_SHA384",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes256_gcm,
+	.prf_hmac =3D L_CHECKSUM_SHA384,
+	.key_xchg =3D &tls_rsa,
+};
+
+static struct tls_cipher_suite *tls_cipher_suite_pref[] =3D {
+	&tls_rsa_with_aes_256_cbc_sha,
+	&tls_rsa_with_aes_128_cbc_sha,
+	&tls_rsa_with_aes_256_cbc_sha256,
+	&tls_rsa_with_aes_128_cbc_sha256,
+	&tls_rsa_with_aes_256_gcm_sha384,
+	&tls_rsa_with_aes_128_gcm_sha256,
+	&tls_rsa_with_3des_ede_cbc_sha,
+	&tls_rsa_with_rc4_128_sha,
+	&tls_rsa_with_rc4_128_md5,
 };
 =

 static bool tls_cipher_suite_is_compatible(struct l_tls *tls,
@@ -629,9 +632,9 @@ static struct tls_cipher_suite *tls_find_cipher_suite(c=
onst uint8_t *id)
 	int i;
 =

 	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_cipher_suite_pref); i++)
-		if (tls_cipher_suite_pref[i].id[0] =3D=3D id[0] &&
-				tls_cipher_suite_pref[i].id[1] =3D=3D id[1])
-			return &tls_cipher_suite_pref[i];
+		if (tls_cipher_suite_pref[i]->id[0] =3D=3D id[0] &&
+				tls_cipher_suite_pref[i]->id[1] =3D=3D id[1])
+			return tls_cipher_suite_pref[i];
 =

 	return NULL;
 }
@@ -906,6 +909,7 @@ static bool tls_send_client_hello(struct l_tls *tls)
 	uint8_t *len_ptr;
 	unsigned int i;
 	ssize_t r;
+	struct tls_cipher_suite **suite;
 =

 	/* Fill in the Client Hello body */
 =

@@ -921,14 +925,16 @@ static bool tls_send_client_hello(struct l_tls *tls)
 	len_ptr =3D ptr;
 	ptr +=3D 2;
 =

-	for (i =3D 0; i < L_ARRAY_SIZE(tls_cipher_suite_pref); i++) {
-		if (!tls_cipher_suite_is_compatible(tls,
-						&tls_cipher_suite_pref[i],
-						NULL))
+	for (suite =3D tls->cipher_suite_pref_list; *suite; suite++) {
+		const char *error;
+
+		if (!tls_cipher_suite_is_compatible(tls, *suite, &error)) {
+			TLS_DEBUG("non-fatal: %s", error);
 			continue;
+		}
 =

-		*ptr++ =3D tls_cipher_suite_pref[i].id[0];
-		*ptr++ =3D tls_cipher_suite_pref[i].id[1];
+		*ptr++ =3D (*suite)->id[0];
+		*ptr++ =3D (*suite)->id[1];
 	}
 =

 	if (ptr =3D=3D len_ptr + 2) {
@@ -1738,6 +1744,7 @@ static void tls_handle_client_hello(struct l_tls *tls,
 	const uint8_t *compression_methods;
 	int i;
 	struct l_queue *extensions_offered =3D NULL;
+	enum l_tls_alert_desc alert_desc =3D TLS_ALERT_HANDSHAKE_FAIL;
 =

 	/* Do we have enough for ProtocolVersion + Random + SessionID size? */
 	if (len < 2 + 32 + 1)
@@ -1822,12 +1829,39 @@ static void tls_handle_client_hello(struct l_tls *t=
ls,
 	TLS_DEBUG("Negotiated TLS " TLS_VER_FMT,
 			TLS_VER_ARGS(tls->negotiated_version));
 =

+	if (!tls->cipher_suite_pref_list) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"No usable cipher suites");
+		return;
+	}
+
 	/* Select a cipher suite according to client's preference list */
 	while (cipher_suites_size) {
 		struct tls_cipher_suite *suite =3D
 			tls_find_cipher_suite(cipher_suites);
+		struct tls_cipher_suite **iter;
+		const char *error;
 =

-		if (suite && tls_cipher_suite_is_compatible(tls, suite, NULL)) {
+		for (iter =3D tls->cipher_suite_pref_list; *iter; iter++)
+			if (*iter =3D=3D suite)
+				break;
+
+		if (!suite)
+			TLS_DEBUG("non-fatal: Cipher suite %04x unknown",
+					l_get_be16(cipher_suites));
+		else if (!tls_cipher_suite_is_compatible(tls, suite, &error))
+			TLS_DEBUG("non-fatal: %s", error);
+		else if (!*iter) {
+			/*
+			 * We have at least one matching compatible suite but
+			 * it is not allowed in this security profile.  If the
+			 * handshake ends up failing then we blame the security
+			 * profile.
+			 */
+			alert_desc =3D TLS_ALERT_INSUFFICIENT_SECURITY;
+			TLS_DEBUG("non-fatal: Cipher suite %s disallowed "
+					"by config", suite->name);
+		} else {
 			tls->pending.cipher_suite =3D suite;
 			break;
 		}
@@ -1837,7 +1871,7 @@ static void tls_handle_client_hello(struct l_tls *tls,
 	}
 =

 	if (!cipher_suites_size) {
-		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+		TLS_DISCONNECT(alert_desc, 0,
 				"No common cipher suites matching negotiated "
 				"TLS version and our certificate's key type");
 		goto cleanup;
@@ -1911,6 +1945,7 @@ static void tls_handle_server_hello(struct l_tls *tls,
 {
 	uint8_t session_id_size, cipher_suite_id[2], compression_method_id;
 	const char *error;
+	struct tls_cipher_suite **iter;
 	int i;
 	struct l_queue *extensions_seen;
 	bool result;
@@ -1970,6 +2005,16 @@ static void tls_handle_server_hello(struct l_tls *tl=
s,
 		return;
 	}
 =

+	for (iter =3D tls->cipher_suite_pref_list; *iter; iter++)
+		if (*iter =3D=3D tls->pending.cipher_suite)
+			break;
+	if (!*iter) {
+		TLS_DISCONNECT(TLS_ALERT_INSUFFICIENT_SECURITY, 0,
+				"Selected cipher suite %s disallowed by config",
+				tls->pending.cipher_suite->name);
+		return;
+	}
+
 	if (!tls_cipher_suite_is_compatible(tls, tls->pending.cipher_suite,
 						&error)) {
 		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
@@ -2703,7 +2748,7 @@ LIB_EXPORT struct l_tls *l_tls_new(bool server,
 	tls->ready_handle =3D ready_handler;
 	tls->disconnected =3D disconnect_handler;
 	tls->user_data =3D user_data;
-
+	tls->cipher_suite_pref_list =3D tls_cipher_suite_pref;
 	tls->signature_hash =3D HANDSHAKE_HASH_SHA256;
 =

 	/* If we're the server wait for the Client Hello already */
@@ -2743,6 +2788,9 @@ LIB_EXPORT void l_tls_free(struct l_tls *tls)
 	if (tls->debug_destroy)
 		tls->debug_destroy(tls->debug_data);
 =

+	if (tls->cipher_suite_pref_list !=3D tls_cipher_suite_pref)
+		l_free(tls->cipher_suite_pref_list);
+
 	l_free(tls);
 }
 =

@@ -2891,6 +2939,9 @@ bool tls_handle_message(struct l_tls *tls, const uint=
8_t *message,
 =

 LIB_EXPORT bool l_tls_start(struct l_tls *tls)
 {
+	if (!tls->cipher_suite_pref_list)
+		return false;
+
 	/* This is a nop in server mode */
 	if (tls->server)
 		return true;
@@ -2996,6 +3047,47 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tl=
s, const char *cert_path,
 	return true;
 }
 =

+bool tls_set_cipher_suites(struct l_tls *tls, const char **suite_list)
+{
+	struct tls_cipher_suite **suite;
+
+	if (tls->cipher_suite_pref_list !=3D tls_cipher_suite_pref)
+		l_free(tls->cipher_suite_pref_list);
+
+	if (!suite_list) {
+		/* Use our default cipher suite preference list */
+		tls->cipher_suite_pref_list =3D tls_cipher_suite_pref;
+		return true;
+	}
+
+	tls->cipher_suite_pref_list =3D l_new(struct tls_cipher_suite *,
+				l_strv_length((char **) suite_list) + 1);
+	suite =3D tls->cipher_suite_pref_list;
+
+	for (; *suite_list; suite_list++) {
+		unsigned int i;
+
+		for (i =3D 0; i < L_ARRAY_SIZE(tls_cipher_suite_pref); i++)
+			if (!strcmp(tls_cipher_suite_pref[i]->name,
+						*suite_list))
+				break;
+
+		if (i < L_ARRAY_SIZE(tls_cipher_suite_pref))
+			*suite++ =3D tls_cipher_suite_pref[i];
+		else
+			TLS_DEBUG("Cipher suite %s is not supported",
+					*suite_list);
+	}
+
+	if (suite > tls->cipher_suite_pref_list)
+		return true;
+
+	TLS_DEBUG("None of the supplied suite names is supported");
+	l_free(suite);
+	tls->cipher_suite_pref_list =3D NULL;
+	return false;
+}
+
 LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls_alert_desc desc)
 {
 	switch (desc) {
-- =

2.19.1


--===============7065215494698982048==--

