Content-Type: multipart/mixed; boundary="===============4638649975649634490=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 8/9] tls: Allow user to set custom list of cipher suites
Date: Thu, 13 Dec 2018 20:57:45 +0100
Message-ID: <20181213195746.32144-8-andrew.zaborowski@intel.com>
In-Reply-To: <20181213195746.32144-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4638649975649634490==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

TLS "security profiles" define which minimum cipher suites and other
parameter values are allowed in a specific usage scenario for TLS, for
example WPA3 in theory requires a specific security profile for its
TLS-based EAP method.  This will also allow the unit tests to test
individual cipher suites.
---
 ell/ell.sym       |   1 +
 ell/tls-private.h |   2 +
 ell/tls.c         | 101 ++++++++++++++++++++++++++++++++++++++++++----
 ell/tls.h         |   3 ++
 4 files changed, 99 insertions(+), 8 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 23d2349..e4f157e 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -417,6 +417,7 @@ global:
 	l_tls_set_cacert;
 	l_tls_set_auth_data;
 	l_tls_set_version_range;
+	l_tls_set_cipher_suites;
 	l_tls_alert_to_str;
 	l_tls_set_debug;
 	/* uintset */
diff --git a/ell/tls-private.h b/ell/tls-private.h
index 3fda4b5..29ce8f9 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -147,6 +147,8 @@ struct l_tls {
 	struct l_key *priv_key;
 	size_t priv_key_size;
 =

+	struct tls_cipher_suite **cipher_suite_pref_list;
+
 	/* Record layer */
 =

 	uint8_t *record_buf;
diff --git a/ell/tls.c b/ell/tls.c
index 59d7f5a..61bcc19 100644
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
@@ -840,6 +841,7 @@ static bool tls_send_client_hello(struct l_tls *tls)
 	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
 	uint8_t *len_ptr;
 	int i;
+	struct tls_cipher_suite **suite;
 =

 	/* Fill in the Client Hello body */
 =

@@ -855,14 +857,16 @@ static bool tls_send_client_hello(struct l_tls *tls)
 	len_ptr =3D ptr;
 	ptr +=3D 2;
 =

-	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_cipher_suite_pref); i++) {
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
@@ -1524,6 +1528,7 @@ static void tls_handle_client_hello(struct l_tls *tls,
 	const uint8_t *cipher_suites;
 	const uint8_t *compression_methods;
 	int i;
+	enum l_tls_alert_desc alert_desc =3D TLS_ALERT_HANDSHAKE_FAIL;
 =

 	/* Do we have enough for ProtocolVersion + Random + SessionID size? */
 	if (len < 2 + 32 + 1)
@@ -1618,12 +1623,39 @@ static void tls_handle_client_hello(struct l_tls *t=
ls,
 	TLS_DEBUG("Negotiated TLS " TLS_VER_FMT,
 			TLS_VER_ARGS(tls->negotiated_version));
 =

+	if (!tls->cipher_suite_pref_list[0]) {
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
+
+		for (iter =3D tls->cipher_suite_pref_list; *iter; iter++)
+			if (*iter =3D=3D suite)
+				break;
 =

-		if (suite && tls_cipher_suite_is_compatible(tls, suite, NULL)) {
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
@@ -1633,7 +1665,7 @@ static void tls_handle_client_hello(struct l_tls *tls,
 	}
 =

 	if (!cipher_suites_size) {
-		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+		TLS_DISCONNECT(alert_desc, 0,
 				"No common cipher suites matching negotiated "
 				"TLS version and our certificate's key type");
 		return;
@@ -1701,6 +1733,7 @@ static void tls_handle_server_hello(struct l_tls *tls,
 {
 	uint8_t session_id_size, cipher_suite_id[2], compression_method_id;
 	const char *error;
+	struct tls_cipher_suite **iter;
 	int i;
 =

 	/* Do we have enough for ProtocolVersion + Random + SessionID len ? */
@@ -1756,6 +1789,16 @@ static void tls_handle_server_hello(struct l_tls *tl=
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
@@ -2485,6 +2528,7 @@ LIB_EXPORT struct l_tls *l_tls_new(bool server,
 	tls->user_data =3D user_data;
 	tls->min_version =3D TLS_MIN_VERSION;
 	tls->max_version =3D TLS_MAX_VERSION;
+	l_tls_set_cipher_suites(tls, NULL);
 =

 	tls->signature_hash =3D HANDSHAKE_HASH_SHA256;
 =

@@ -2525,6 +2569,8 @@ LIB_EXPORT void l_tls_free(struct l_tls *tls)
 	if (tls->debug_destroy)
 		tls->debug_destroy(tls->debug_data);
 =

+	l_free(tls->cipher_suite_pref_list);
+
 	l_free(tls);
 }
 =

@@ -2790,6 +2836,45 @@ LIB_EXPORT void l_tls_set_version_range(struct l_tls=
 *tls,
 		max_version : TLS_MAX_VERSION;
 }
 =

+LIB_EXPORT void l_tls_set_cipher_suites(struct l_tls *tls,
+					const char **suite_list)
+{
+	unsigned int i, len;
+	struct tls_cipher_suite **suite;
+
+	l_free(tls->cipher_suite_pref_list);
+
+	if (suite_list)
+		len =3D l_strv_length((char **) suite_list);
+	else
+		len =3D L_ARRAY_SIZE(tls_cipher_suite_pref);
+
+	tls->cipher_suite_pref_list =3D l_new(struct tls_cipher_suite *, len + 1);
+
+	if (!suite_list) {
+		/* Use our default cipher suite preference list */
+		for (i =3D 0; i < L_ARRAY_SIZE(tls_cipher_suite_pref); i++)
+			tls->cipher_suite_pref_list[i] =3D
+				&tls_cipher_suite_pref[i];
+
+		return;
+	}
+
+	suite =3D tls->cipher_suite_pref_list;
+
+	for (; *suite_list; suite_list++) {
+		for (i =3D 0; i < L_ARRAY_SIZE(tls_cipher_suite_pref); i++)
+			if (!strcmp(tls_cipher_suite_pref[i].name, *suite_list))
+				break;
+
+		if (i < L_ARRAY_SIZE(tls_cipher_suite_pref))
+			*suite++ =3D &tls_cipher_suite_pref[i];
+		else
+			TLS_DEBUG("Cipher suite %s is not supported",
+					*suite_list);
+	}
+}
+
 LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls_alert_desc desc)
 {
 	switch (desc) {
diff --git a/ell/tls.h b/ell/tls.h
index 5b2f398..c684dc2 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -113,6 +113,9 @@ bool l_tls_set_auth_data(struct l_tls *tls, const char =
*cert_path,
 void l_tls_set_version_range(struct l_tls *tls,
 				uint16_t min_version, uint16_t max_version);
 =

+/* Optionally limit allowed cipher suites to a custom set */
+void l_tls_set_cipher_suites(struct l_tls *tls, const char **suite_list);
+
 const char *l_tls_alert_to_str(enum l_tls_alert_desc desc);
 =

 enum l_checksum_type;
-- =

2.19.1


--===============4638649975649634490==--

