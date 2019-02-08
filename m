Content-Type: multipart/mixed; boundary="===============5370739100149218171=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/4] tls: Implement the Signature Algorithms extension
Date: Fri, 08 Feb 2019 16:31:44 +0100
Message-ID: <20190208153147.30969-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5370739100149218171==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls-extensions.c | 279 +++++++++++++++++++++++++++++++++++++++++++
 ell/tls-private.h    |   4 +
 ell/tls.c            |  10 +-
 3 files changed, 284 insertions(+), 9 deletions(-)

diff --git a/ell/tls-extensions.c b/ell/tls-extensions.c
index d179e67..7b20e17 100644
--- a/ell/tls-extensions.c
+++ b/ell/tls-extensions.c
@@ -568,6 +568,278 @@ static ssize_t tls_ec_point_formats_server_write(stru=
ct l_tls *tls,
 	return 2;
 }
 =

+/*
+ * This is used to append the list of signature algorithm and hash type
+ * combinations we support to the Signature Algorithms client hello
+ * extension (on the client) and the Certificate Request message (on the
+ * server).  In both cases we need to list the algorithms we support for
+ * two use cases: certificate chain verification and signing/verifying
+ * Server Key Exchange params (server->client) or Certificate Verify
+ * data (client->server).
+ *
+ * For the server side RFC 5462, Section 7.4.1.4.1 says:
+ * "If the client [...] is willing to use them for verifying
+ * messages sent by the server, i.e., server certificates and
+ * server key exchange [...] it MUST send the
+ * signature_algorithms extension, listing the algorithms it
+ * is willing to accept."
+ *
+ * As for the certificate chains we mostly rely on the kernel to do
+ * this so when we receive the list we do not currently verify the
+ * that the whole chain uses only algorithms from the list on either
+ * side (TODO). But we know that the chain verification in the kernel
+ * can use a superset of the hash algorithms l_checksum supports.
+ * For the Server Key Exchange and Certificate Verify signatures we
+ * use l_checksum but we need to map the TLS-specific hash IDs to
+ * enum l_checksum_type using the tls_handshake_hash_data list in
+ * signature->sign() and signature->verify(), so we use
+ * tls_handshake_hash_data as the definitive list of allowed hash
+ * algorithms.
+ *
+ * Our supported signature algorithms can work with any hash type so we
+ * basically have to send all possible combinations of the signature
+ * algorithm IDs from the supported cipher suites (except anonymous)
+ * with the hash algorithms we can use for signature verification,
+ * i.e. those in the tls_handshake_hash_data table.
+ */
+static ssize_t tls_write_signature_algorithms(struct l_tls *tls,
+						uint8_t *buf, size_t len)
+{
+	uint8_t *ptr =3D buf;
+	unsigned int i, j;
+	struct tls_cipher_suite **suite;
+	uint8_t sig_alg_ids[16];
+	uint8_t hash_ids[16];
+	unsigned int sig_alg_cnt =3D 0;
+	unsigned int hash_cnt =3D 0;
+
+	for (suite =3D tls->cipher_suite_pref_list; *suite; suite++) {
+		uint8_t id;
+
+		if (!(*suite)->signature)
+			continue;
+
+		id =3D (*suite)->signature->id;
+
+		if (memchr(sig_alg_ids, id, sig_alg_cnt))
+			continue;
+
+		if (!tls_cipher_suite_is_compatible(tls, *suite, NULL))
+			continue;
+
+		if (sig_alg_cnt >=3D sizeof(sig_alg_ids))
+			return -ENOMEM;
+
+		sig_alg_ids[sig_alg_cnt++] =3D id;
+	}
+
+	for (i =3D 0; i < __HANDSHAKE_HASH_COUNT; i++) {
+		const struct tls_hash_algorithm *hash =3D
+			&tls_handshake_hash_data[i];
+		bool supported;
+
+		/*
+		 * The hash types in the Signature Algorithms extension are
+		 * all supported hashes but the ones in the Certificate
+		 * Request (server->client) must be in the set for which we
+		 * maintain handshake message hashes because that is going
+		 * to be used in Certificate Verify.
+		 */
+		if (tls->server)
+			supported =3D !!tls->handshake_hash[i];
+		else
+			supported =3D l_checksum_is_supported(hash->l_id, false);
+
+		if (supported)
+			hash_ids[hash_cnt++] =3D hash->tls_id;
+	}
+
+	if (len < 2 + sig_alg_cnt * hash_cnt * 2)
+		return -ENOMEM;
+
+	l_put_be16(sig_alg_cnt * hash_cnt * 2, ptr);
+	ptr +=3D 2;
+
+	for (i =3D 0; i < sig_alg_cnt; i++)
+		for (j =3D 0; j < hash_cnt; j++) {
+			*ptr++ =3D hash_ids[j];
+			*ptr++ =3D sig_alg_ids[i];
+		}
+
+	return ptr - buf;
+}
+
+static ssize_t tls_parse_signature_algorithms(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	const uint8_t *ptr =3D buf;
+	enum handshake_hash_type first_supported, hash;
+	const struct tls_hash_algorithm *preferred;
+	struct tls_cipher_suite **suite;
+	uint8_t sig_alg_ids[16];
+	unsigned int sig_alg_cnt =3D 0;
+
+	/*
+	 * This only makes sense as a variable-length field, assume
+	 * there's a typo in RFC5246 7.4.4 here.
+	 */
+	if (len < 4)
+		return -EINVAL;
+
+	if (l_get_be16(ptr) > len - 2)
+		return -EINVAL;
+
+	len =3D l_get_be16(ptr);
+	ptr +=3D 2;
+
+	if (len & 1)
+		return -EINVAL;
+
+	for (suite =3D tls->cipher_suite_pref_list; *suite; suite++) {
+		uint8_t id;
+
+		if (!(*suite)->signature)
+			continue;
+
+		id =3D (*suite)->signature->id;
+
+		if (memchr(sig_alg_ids, id, sig_alg_cnt))
+			continue;
+
+		if (!tls_cipher_suite_is_compatible(tls, *suite, NULL))
+			continue;
+
+		if (sig_alg_cnt >=3D sizeof(sig_alg_ids))
+			return -ENOMEM;
+
+		sig_alg_ids[sig_alg_cnt++] =3D id;
+	}
+
+	/*
+	 * In 1.2 we force our preference for SHA256/SHA384 (depending on
+	 * cipher suite's PRF hmac) if it is supported by the peer because
+	 * that must be supported anyway for the PRF and the Finished hash
+	 * meaning that we only need to keep one hash instead of two.
+	 * If not available fall back to the first common hash algorithm.
+	 */
+	first_supported =3D -1;
+
+	if (tls->prf_hmac)
+		preferred =3D tls->prf_hmac;
+	else
+		preferred =3D &tls_handshake_hash_data[HANDSHAKE_HASH_SHA256];
+
+	while (len) {
+		uint8_t hash_id =3D *ptr++;
+		uint8_t sig_alg_id =3D *ptr++;
+		bool supported;
+
+		len -=3D 2;
+
+		/* Ignore hash types for signatures other than ours */
+		if (tls->pending.cipher_suite &&
+				(!tls->pending.cipher_suite->signature ||
+				 tls->pending.cipher_suite->signature->id !=3D
+				 sig_alg_id))
+			continue;
+		else if (!tls->pending.cipher_suite &&
+				!memchr(sig_alg_ids, sig_alg_id, sig_alg_cnt))
+			continue;
+
+		if (hash_id =3D=3D preferred->tls_id) {
+			for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
+				if (&tls_handshake_hash_data[hash] =3D=3D preferred)
+					break;
+			break;
+		}
+
+		if ((int) first_supported !=3D -1)
+			continue;
+
+		for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
+			if (hash_id =3D=3D tls_handshake_hash_data[hash].tls_id)
+				break;
+
+		if (hash =3D=3D __HANDSHAKE_HASH_COUNT)
+			continue;
+
+		if (tls->server)
+			supported =3D l_checksum_is_supported(
+					tls_handshake_hash_data[hash].l_id,
+					false);
+		else
+			supported =3D !!tls->handshake_hash[hash];
+
+		if (supported)
+			first_supported =3D hash;
+	}
+
+	if (len)
+		tls->signature_hash =3D hash;
+	else if ((int) first_supported !=3D -1)
+		tls->signature_hash =3D first_supported;
+	else
+		return -ENOTSUP;
+
+	return ptr + len - buf;
+}
+
+/* RFC 5462, Section 7.4.1.4.1 */
+static ssize_t tls_signature_algorithms_client_write(struct l_tls *tls,
+						uint8_t *buf, size_t len)
+{
+	/*
+	 * "Note: this extension is not meaningful for TLS versions
+	 * prior to 1.2.  Clients MUST NOT offer it if they are offering
+	 * prior versions."
+	 */
+	if (tls->max_version < L_TLS_V12)
+		return -ENOMSG;
+
+	return tls_write_signature_algorithms(tls, buf, len);
+}
+
+static bool tls_signature_algorithms_client_handle(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	ssize_t ret;
+
+	/*
+	 * "However, even if clients do offer it, the rules specified in
+	 * [TLSEXT] require servers to ignore extensions they do not
+	 * understand."
+	 */
+	if (tls->max_version < L_TLS_V12)
+		return true;
+
+	ret =3D tls_parse_signature_algorithms(tls, buf, len);
+
+	if (ret =3D=3D -ENOTSUP)
+		TLS_DEBUG("No common signature algorithms");
+
+	/*
+	 * TODO: also check our certificate chain against the parsed
+	 * signature algorithms.
+	 */
+
+	return ret =3D=3D (ssize_t) len;
+}
+
+static bool tls_signature_algorithms_client_absent(struct l_tls *tls)
+{
+	/*
+	 * "If the client does not send the signature_algorithms extension,
+	 * the server MUST do the following:
+	 *    - [...] behave as if client had sent the value {sha1,rsa}.
+	 *    - [...] behave as if client had sent the value {sha1,dsa}.
+	 *    - [...] behave as if client had sent the value {sha1,ecdsa}.
+	 */
+	if (tls->max_version >=3D L_TLS_V12)
+		tls->signature_hash =3D HANDSHAKE_HASH_SHA1;
+
+	return true;
+}
+
 const struct tls_hello_extension tls_extensions[] =3D {
 	{
 		"Supported Groups", "elliptic_curves", 10,
@@ -584,6 +856,13 @@ const struct tls_hello_extension tls_extensions[] =3D {
 		tls_ec_point_formats_server_write,
 		NULL, NULL,
 	},
+	{
+		"Signature Algorithms", "signature_algoritms", 13,
+		tls_signature_algorithms_client_write,
+		tls_signature_algorithms_client_handle,
+		tls_signature_algorithms_client_absent,
+		NULL, NULL, NULL,
+	},
 	{}
 };
 =

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 03ad07c..2d1424e 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -308,6 +308,10 @@ bool tls_handle_message(struct l_tls *tls, const uint8=
_t *message,
 =

 void tls_tx_handshake(struct l_tls *tls, int type, uint8_t *buf, size_t le=
ngth);
 =

+bool tls_cipher_suite_is_compatible(struct l_tls *tls,
+					const struct tls_cipher_suite *suite,
+					const char **error);
+
 /* Optionally limit allowed cipher suites to a custom set */
 bool tls_set_cipher_suites(struct l_tls *tls, const char **suite_list);
 =

diff --git a/ell/tls.c b/ell/tls.c
index 02e49f9..fd898f6 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -379,7 +379,7 @@ static void tls_reset_cipher_spec(struct l_tls *tls, bo=
ol txrx)
 	tls_change_cipher_spec(tls, txrx, NULL);
 }
 =

-static bool tls_cipher_suite_is_compatible(struct l_tls *tls,
+bool tls_cipher_suite_is_compatible(struct l_tls *tls,
 					const struct tls_cipher_suite *suite,
 					const char **error)
 {
@@ -1486,13 +1486,6 @@ static void tls_handle_client_hello(struct l_tls *tl=
s,
 	 * trying to connect somewhere else.  We might want to throw an error.
 	 */
 =

-	/*
-	 * TODO: Obligatory in 1.2: check for signature_algorithms extension,
-	 * store the list of algorithms for later checking in
-	 * tls_send_certificate on both server and client sides.  If not
-	 * present assume only SHA1+RSA (7.4.1.4.1).
-	 */
-
 	/* Save client_version for Premaster Secret verification */
 	tls->client_version =3D l_get_be16(buf);
 =

@@ -2407,7 +2400,6 @@ LIB_EXPORT struct l_tls *l_tls_new(bool server,
 	tls->disconnected =3D disconnect_handler;
 	tls->user_data =3D user_data;
 	tls->cipher_suite_pref_list =3D tls_cipher_suite_pref;
-	tls->signature_hash =3D HANDSHAKE_HASH_SHA256;
 	tls->min_version =3D TLS_MIN_VERSION;
 	tls->max_version =3D TLS_MAX_VERSION;
 =

-- =

2.19.1


--===============5370739100149218171==--

