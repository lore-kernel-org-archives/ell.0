Content-Type: multipart/mixed; boundary="===============5769589105695508680=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 7/9] cert: Optionally return error string from
 l_certchain_verify
Date: Wed, 28 Nov 2018 03:38:33 +0100
Message-ID: <20181128023835.2081-7-andrew.zaborowski@intel.com>
In-Reply-To: <20181128023835.2081-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5769589105695508680==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Return a basic error string to the l_certchain_verify caller so it can
be included in debug logs.
---
 ell/cert.c | 60 +++++++++++++++++++++++++++++++++++++++++++-----------
 ell/cert.h |  3 ++-
 ell/tls.c  |  7 ++++---
 3 files changed, 54 insertions(+), 16 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index 0ecdfbb..bd49831 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -23,6 +23,7 @@
 #endif
 =

 #include <string.h>
+#include <stdio.h>
 =

 #include "private.h"
 #include "key.h"
@@ -309,17 +310,18 @@ LIB_EXPORT bool l_certchain_find(struct l_certchain *=
chain,
 	 * Also nothing to do if the user already supplied a working
 	 * certificate chain.
 	 */
-	if (l_certchain_verify(chain, ca_certs))
+	if (l_certchain_verify(chain, ca_certs, NULL))
 		return true;
 =

 	/* Actual search for a chain to the CA cert is unimplemented, fail */
 	return false;
 }
 =

-static struct l_keyring *cert_set_to_keyring(struct l_queue *certs)
+static struct l_keyring *cert_set_to_keyring(struct l_queue *certs, char *=
error)
 {
 	struct l_keyring *ring;
 	const struct l_queue_entry *entry;
+	int i =3D 1;
 =

 	ring =3D l_keyring_new();
 	if (!ring)
@@ -329,15 +331,23 @@ static struct l_keyring *cert_set_to_keyring(struct l=
_queue *certs)
 		struct l_cert *cert =3D entry->data;
 		struct l_key *key =3D l_cert_get_pubkey(cert);
 =

-		if (!key)
+		if (!key) {
+			sprintf(error, "Can't get public key from certificate "
+				"%i / %i in certificate set", i,
+				l_queue_length(certs));
 			goto cleanup;
+		}
 =

 		if (!l_keyring_link(ring, key)) {
 			l_key_free(key);
+			sprintf(error, "Can't link the public key from "
+				"certificate %i / %i to target keyring",
+				i, l_queue_length(certs));
 			goto cleanup;
 		}
 =

 		l_key_free_norevoke(key);
+		i++;
 	}
 =

 	return ring;
@@ -386,21 +396,33 @@ static void cert_keyring_cleanup(struct l_keyring **p)
 	l_keyring_free(*p);
 }
 =

+#define RETURN_ERROR(msg, args...)	\
+	do {	\
+		if (error) {	\
+			*error =3D error_buf;	\
+			snprintf(error_buf, sizeof(error_buf), msg, ## args); \
+		}	\
+		return false;	\
+	} while (0)
+
 LIB_EXPORT bool l_certchain_verify(struct l_certchain *chain,
-					struct l_queue *ca_certs)
+					struct l_queue *ca_certs,
+					const char **error)
 {
 	struct l_keyring *ca_ring =3D NULL;
 	L_AUTO_CLEANUP_VAR(struct l_keyring *, verify_ring,
 				cert_keyring_cleanup) =3D NULL;
 	struct l_cert *cert;
 	struct l_key *prev_key =3D NULL;
+	int verified =3D 0;
+	static char error_buf[200];
 =

 	if (unlikely(!chain || !chain->leaf))
-		return false;
+		RETURN_ERROR("Chain empty");
 =

 	verify_ring =3D l_keyring_new();
 	if (!verify_ring)
-		return false;
+		RETURN_ERROR("Can't create verify keyring");
 =

 	cert =3D chain->ca;
 =

@@ -422,19 +444,23 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain=
 *chain,
 	 * extension from being linked to a keyring.
 	 */
 	if (cert_is_in_set(cert, ca_certs)) {
+		verified++;
 		cert =3D cert->issued;
 		if (!cert)
 			return true;
 =

 		prev_key =3D cert_try_link(cert, verify_ring);
 	} else if (ca_certs) {
-		ca_ring =3D cert_set_to_keyring(ca_certs);
-		if (!ca_ring)
+		ca_ring =3D cert_set_to_keyring(ca_certs, error_buf);
+		if (!ca_ring) {
+			if (error)
+				*error =3D error_buf;
 			return false;
+		}
 =

 		if (!l_keyring_link_nested(verify_ring, ca_ring)) {
 			l_keyring_free(ca_ring);
-			return false;
+			RETURN_ERROR("Can't link CA ring to verify ring");
 		}
 	} else
 		prev_key =3D cert_try_link(cert, verify_ring);
@@ -447,7 +473,7 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain *=
chain,
 				NULL)) {
 		l_key_free(prev_key);
 		l_keyring_free(ca_ring);
-		return false;
+		RETURN_ERROR("Can't restrict verify keyring");
 	}
 =

 	if (ca_ring) {
@@ -474,10 +500,20 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain=
 *chain,
 		l_key_free(prev_key);
 		prev_key =3D new_key;
 		cert =3D cert->issued;
+		verified++;
 	}
 =

-	if (!prev_key)
-		return false;
+	if (!prev_key) {
+		int total =3D 0;
+
+		for (cert =3D chain->ca; cert; cert =3D cert->issued, total++);
+		RETURN_ERROR("Linking certificate %i / %i failed, root %s"
+				"verified against trusted CA(s) and the "
+				"following %i top certificates verified ok",
+				verified + 1, total,
+				ca_certs && verified ? "" : "not ",
+				verified ? verified - 1 : 0);
+	}
 =

 	l_key_free(prev_key);
 	return true;
diff --git a/ell/cert.h b/ell/cert.h
index 5205fa8..393b3a7 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -57,7 +57,8 @@ bool l_certchain_walk_from_ca(struct l_certchain *chain,
 				l_cert_walk_cb_t cb, void *user_data);
 =

 bool l_certchain_find(struct l_certchain *chain, struct l_queue *ca_certs);
-bool l_certchain_verify(struct l_certchain *chain, struct l_queue *ca_cert=
s);
+bool l_certchain_verify(struct l_certchain *chain, struct l_queue *ca_cert=
s,
+			const char **error);
 =

 #ifdef __cplusplus
 }
diff --git a/ell/tls.c b/ell/tls.c
index ebf4b0c..ade43d8 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1780,6 +1780,7 @@ static void tls_handle_certificate(struct l_tls *tls,
 	size_t der_len;
 	const uint8_t *der;
 	bool dummy;
+	const char *error_str;
 =

 	if (len < 3)
 		goto decode_error;
@@ -1823,11 +1824,11 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
 	 * Validate the certificate chain's consistency and validate it
 	 * against our CAs if we have any.
 	 */
-	if (!l_certchain_verify(certchain, tls->ca_certs)) {
+	if (!l_certchain_verify(certchain, tls->ca_certs, &error_str)) {
 		TLS_DISCONNECT(TLS_ALERT_BAD_CERT, 0,
 				"Peer certchain verification failed "
-				"consistency check%s", tls->ca_certs ?
-				" or against local CA certs" : "");
+				"consistency check%s: %s", tls->ca_certs ?
+				" or against local CA certs" : "", error_str);
 =

 		goto done;
 	}
-- =

2.19.1


--===============5769589105695508680==--

