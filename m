Content-Type: multipart/mixed; boundary="===============5817223342591095798=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/3] tls: Implement l_tls_set_version_range
Date: Fri, 11 Jan 2019 15:11:46 +0100
Message-ID: <20190111141148.17379-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5817223342591095798==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Allow user to set custom min and max TLS version limits, this can be
used to ensure we comply with a specific security profile.
---
Last message in the previous discussion about this was here:
https://lists.01.org/pipermail/ell/2018-December/001625.html
---
 ell/ell.sym       |  1 +
 ell/tls-private.h | 11 +++-----
 ell/tls-record.c  |  2 +-
 ell/tls-suites.c  |  4 +--
 ell/tls.c         | 66 +++++++++++++++++++++++++++++++++--------------
 ell/tls.h         | 12 ++++++++-
 6 files changed, 65 insertions(+), 31 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 95e1a3b..fdfbe6d 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -421,6 +421,7 @@ global:
 	l_tls_close;
 	l_tls_set_cacert;
 	l_tls_set_auth_data;
+	l_tls_set_version_range;
 	l_tls_alert_to_str;
 	l_tls_set_debug;
 	/* uintset */
diff --git a/ell/tls-private.h b/ell/tls-private.h
index 10f25c5..bd2f66d 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -20,14 +20,7 @@
  *
  */
 =

-enum l_tls_version {
-	L_TLS_V10 =3D ((3 << 8) | 1),
-	L_TLS_V11 =3D ((3 << 8) | 2),
-	L_TLS_V12 =3D ((3 << 8) | 3),
-	L_TLS_V13 =3D ((3 << 8) | 4),	/* Not supported */
-};
-
-#define TLS_VERSION	L_TLS_V12
+#define TLS_MAX_VERSION	L_TLS_V12
 #define TLS_MIN_VERSION	L_TLS_V10
 =

 enum tls_cipher_type {
@@ -217,6 +210,8 @@ struct l_tls {
 	l_tls_debug_cb_t debug_handler;
 	l_tls_destroy_cb_t debug_destroy;
 	void *debug_data;
+	enum l_tls_version min_version;
+	enum l_tls_version max_version;
 =

 	struct l_queue *ca_certs;
 	struct l_certchain *cert;
diff --git a/ell/tls-record.c b/ell/tls-record.c
index 8cb7e57..505263d 100644
--- a/ell/tls-record.c
+++ b/ell/tls-record.c
@@ -223,7 +223,7 @@ void tls_tx_record(struct l_tls *tls, enum tls_content_=
type type,
 				TX_RECORD_TAILROOM];
 	uint8_t *fragment, *plaintext;
 	uint16_t fragment_len;
-	uint16_t version =3D tls->negotiated_version ?: TLS_MIN_VERSION;
+	uint16_t version =3D tls->negotiated_version ?: tls->min_version;
 =

 	if (type =3D=3D TLS_CT_ALERT)
 		tls->record_flush =3D true;
diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index 56d8795..0f5a075 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -227,8 +227,8 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls *=
tls)
 	}
 =

 	/* Must match the version in tls_send_client_hello */
-	pre_master_secret[0] =3D (uint8_t) (TLS_VERSION >> 8);
-	pre_master_secret[1] =3D (uint8_t) (TLS_VERSION >> 0);
+	pre_master_secret[0] =3D (uint8_t) (tls->max_version >> 8);
+	pre_master_secret[1] =3D (uint8_t) (tls->max_version >> 0);
 =

 	l_getrandom(pre_master_secret + 2, 46);
 =

diff --git a/ell/tls.c b/ell/tls.c
index f7d1d73..9d39ba4 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -389,20 +389,23 @@ static bool tls_cipher_suite_is_compatible(struct l_t=
ls *tls,
 {
 	static char error_buf[200];
 	struct l_cert *leaf;
+	enum l_tls_version min_version =3D
+		tls->negotiated_version ?: tls->min_version;
+	enum l_tls_version max_version =3D
+		tls->negotiated_version ?: tls->max_version;
 =

 	if (suite->encryption &&
 			suite->encryption->cipher_type =3D=3D TLS_CIPHER_AEAD) {
-		enum l_tls_version negotiated =3D tls->negotiated_version;
-
-		if (negotiated && negotiated < L_TLS_V12) {
+		if (max_version < L_TLS_V12) {
 			if (error) {
 				*error =3D error_buf;
 				snprintf(error_buf, sizeof(error_buf),
 						"Cipher suite %s uses an AEAD "
 						"cipher (TLS 1.2+) but "
-						TLS_VER_FMT " was negotiated",
-						suite->name,
-						TLS_VER_ARGS(negotiated));
+						TLS_VER_FMT
+						" was negotiated or is the max "
+						"version allowed", suite->name,
+						TLS_VER_ARGS(tls->max_version));
 			}
 =

 			return false;
@@ -446,10 +449,11 @@ static bool tls_cipher_suite_is_compatible(struct l_t=
ls *tls,
 		return false;
 	}
 =

-	if ((tls->negotiated_version && tls->negotiated_version < L_TLS_V12 &&
-			(!l_checksum_is_supported(L_CHECKSUM_MD5, true) ||
-			 !l_checksum_is_supported(L_CHECKSUM_SHA1, true))) ||
-			(tls->negotiated_version >=3D L_TLS_V12 &&
+	if (
+			(max_version < L_TLS_V12 &&
+			 (!l_checksum_is_supported(L_CHECKSUM_MD5, true) ||
+			  !l_checksum_is_supported(L_CHECKSUM_SHA1, true))) ||
+			(min_version >=3D L_TLS_V12 &&
 			 !l_checksum_is_supported(
 					suite->prf_hmac !=3D L_CHECKSUM_NONE ?
 					suite->prf_hmac : L_CHECKSUM_SHA256,
@@ -572,8 +576,14 @@ const struct tls_hash_algorithm tls_handshake_hash_dat=
a[] =3D {
 static bool tls_init_handshake_hash(struct l_tls *tls)
 {
 	enum handshake_hash_type hash;
+	bool tls10 =3D tls->max_version < L_TLS_V12;
 =

 	for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++) {
+		/* Skip hash types we already know we won't need */
+		if (tls10 && hash !=3D HANDSHAKE_HASH_SHA1 &&
+				hash !=3D HANDSHAKE_HASH_MD5)
+			continue;
+
 		if (tls->handshake_hash[hash]) {
 			TLS_DEBUG("Handshake hash %s already exists",
 					tls_handshake_hash_data[hash].name);
@@ -800,8 +810,8 @@ static bool tls_send_client_hello(struct l_tls *tls)
 =

 	/* Fill in the Client Hello body */
 =

-	*ptr++ =3D (uint8_t) (TLS_VERSION >> 8);
-	*ptr++ =3D (uint8_t) (TLS_VERSION >> 0);
+	*ptr++ =3D (uint8_t) (tls->max_version >> 8);
+	*ptr++ =3D (uint8_t) (tls->max_version >> 0);
 =

 	tls_write_random(tls->pending.client_random);
 	memcpy(ptr, tls->pending.client_random, 32);
@@ -825,7 +835,8 @@ static bool tls_send_client_hello(struct l_tls *tls)
 	}
 =

 	if (ptr =3D=3D len_ptr + 2) {
-		TLS_DEBUG("No compatible cipher suites, check kernel config");
+		TLS_DEBUG("No compatible cipher suites, check kernel config, "
+				"certificate's key type and TLS version range");
 		return false;
 	}
 =

@@ -1496,15 +1507,15 @@ static void tls_handle_client_hello(struct l_tls *t=
ls,
 	/* Save client_version for Premaster Secret verification */
 	tls->client_version =3D l_get_be16(buf);
 =

-	if (tls->client_version < TLS_MIN_VERSION) {
+	if (tls->client_version < tls->min_version) {
 		TLS_DISCONNECT(TLS_ALERT_PROTOCOL_VERSION, 0,
 				"Client version too low: %02x",
 				tls->client_version);
 		goto cleanup;
 	}
 =

-	tls->negotiated_version =3D TLS_VERSION < tls->client_version ?
-		TLS_VERSION : tls->client_version;
+	tls->negotiated_version =3D tls->client_version > tls->max_version ?
+		tls->max_version : tls->client_version;
 =

 	/* Stop maintaining handshake message hashes other than MD1 and SHA. */
 	if (tls->negotiated_version < L_TLS_V12)
@@ -1666,9 +1677,9 @@ static void tls_handle_server_hello(struct l_tls *tls,
 =

 	tls->negotiated_version =3D l_get_be16(buf);
 =

-	if (tls->negotiated_version < TLS_MIN_VERSION ||
-			tls->negotiated_version > TLS_VERSION) {
-		TLS_DISCONNECT(tls->negotiated_version < TLS_MIN_VERSION ?
+	if (tls->negotiated_version < tls->min_version ||
+			tls->negotiated_version > tls->max_version) {
+		TLS_DISCONNECT(tls->negotiated_version < tls->min_version ?
 				TLS_ALERT_PROTOCOL_VERSION :
 				TLS_ALERT_ILLEGAL_PARAM, 0,
 				"Unsupported version %02x",
@@ -2415,6 +2426,8 @@ LIB_EXPORT struct l_tls *l_tls_new(bool server,
 	tls->user_data =3D user_data;
 	tls->cipher_suite_pref_list =3D tls_cipher_suite_pref;
 	tls->signature_hash =3D HANDSHAKE_HASH_SHA256;
+	tls->min_version =3D TLS_MIN_VERSION;
+	tls->max_version =3D TLS_MAX_VERSION;
 =

 	/* If we're the server wait for the Client Hello already */
 	if (tls->server)
@@ -2604,6 +2617,9 @@ bool tls_handle_message(struct l_tls *tls, const uint=
8_t *message,
 =

 LIB_EXPORT bool l_tls_start(struct l_tls *tls)
 {
+	if (tls->max_version < tls->min_version)
+		return false;
+
 	if (!tls->cipher_suite_pref_list)
 		return false;
 =

@@ -2753,6 +2769,18 @@ bool tls_set_cipher_suites(struct l_tls *tls, const =
char **suite_list)
 	return false;
 }
 =

+LIB_EXPORT void l_tls_set_version_range(struct l_tls *tls,
+					enum l_tls_version min_version,
+					enum l_tls_version max_version)
+{
+	tls->min_version =3D
+		(min_version && min_version > TLS_MIN_VERSION) ?
+		min_version : TLS_MIN_VERSION;
+	tls->max_version =3D
+		(max_version && max_version < TLS_MAX_VERSION) ?
+		max_version : TLS_MAX_VERSION;
+}
+
 LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls_alert_desc desc)
 {
 	switch (desc) {
diff --git a/ell/tls.h b/ell/tls.h
index fb33404..b0db34f 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -25,6 +25,13 @@
 extern "C" {
 #endif
 =

+enum l_tls_version {
+	L_TLS_V10 =3D ((3 << 8) | 1),
+	L_TLS_V11 =3D ((3 << 8) | 2),
+	L_TLS_V12 =3D ((3 << 8) | 3),
+	L_TLS_V13 =3D ((3 << 8) | 4),	/* Not supported */
+};
+
 struct l_tls;
 =

 enum l_tls_alert_desc {
@@ -63,7 +70,6 @@ typedef void (*l_tls_disconnect_cb_t)(enum l_tls_alert_de=
sc reason,
 typedef void (*l_tls_debug_cb_t)(const char *str, void *user_data);
 typedef void (*l_tls_destroy_cb_t)(void *user_data);
 =

-
 /*
  * app_data_handler gets called with newly received decrypted data.
  * tx_handler gets called to send TLS payloads off to remote end.
@@ -107,6 +113,10 @@ bool l_tls_set_auth_data(struct l_tls *tls, const char=
 *cert_path,
 				const char *priv_key_path,
 				const char *priv_key_passphrase);
 =

+void l_tls_set_version_range(struct l_tls *tls,
+				enum l_tls_version min_version,
+				enum l_tls_version max_version);
+
 const char *l_tls_alert_to_str(enum l_tls_alert_desc desc);
 =

 enum l_checksum_type;
-- =

2.19.1


--===============5817223342591095798==--

