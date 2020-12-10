Content-Type: multipart/mixed; boundary="===============2518797230398848725=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 09/13] pem: Add PKCS#12 parsing
Date: Thu, 10 Dec 2020 20:32:02 +0100
Message-ID: <20201210193202.526451-9-andrew.zaborowski@intel.com>
In-Reply-To: <20201210193202.526451-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2518797230398848725==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add ability to load PKCS#12 files in l_pem_load_container_file().  This
has only been tested with the files produced by openssl so far.

Extend the static buffer in struct asn1_oid (asn1-private.h) so we can
handle some 11-byte OIDs used in PKCS#12 files.
---
 ell/asn1-private.h |   2 +-
 ell/pem.c          | 612 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 613 insertions(+), 1 deletion(-)

diff --git a/ell/asn1-private.h b/ell/asn1-private.h
index 2a31241..079570b 100644
--- a/ell/asn1-private.h
+++ b/ell/asn1-private.h
@@ -37,7 +37,7 @@
 =

 struct asn1_oid {
 	uint8_t asn1_len;
-	uint8_t asn1[10];
+	uint8_t asn1[11];
 };
 =

 #define asn1_oid_eq(oid1, oid2_len, oid2_string) \
diff --git a/ell/pem.c b/ell/pem.c
index 90d06fb..e9a4ae3 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -935,6 +935,582 @@ LIB_EXPORT struct l_key *l_pem_load_private_key(const=
 char *filename,
 					encrypted);
 }
 =

+static const uint8_t *pkcs7_unpack_content_info(const uint8_t *container,
+					size_t container_len, int pos,
+					const struct asn1_oid *expected_oid,
+					struct asn1_oid *out_oid,
+					uint8_t *out_tag, size_t *out_len)
+{
+	const uint8_t *content_info;
+	size_t content_info_len;
+	const uint8_t *type;
+	size_t type_len;
+	const uint8_t *ret;
+	uint8_t tag;
+
+	if (!(content_info =3D asn1_der_find_elem(container, container_len, pos,
+						&tag, &content_info_len)) ||
+			tag !=3D ASN1_ID_SEQUENCE)
+		return NULL;
+
+	if (!(type =3D asn1_der_find_elem(content_info, content_info_len, 0,
+					&tag, &type_len)) ||
+			tag !=3D ASN1_ID_OID ||
+			type_len > sizeof(out_oid->asn1))
+		return NULL;
+
+	if (expected_oid && !asn1_oid_eq(expected_oid, type_len, type))
+		return NULL;
+
+	if (!(ret =3D asn1_der_find_elem(content_info, content_info_len,
+					ASN1_CONTEXT_EXPLICIT(0),
+					out_tag, out_len)) ||
+			ret + *out_len !=3D content_info + content_info_len)
+		return NULL;
+
+	if (out_oid) {
+		out_oid->asn1_len =3D type_len;
+		memcpy(out_oid->asn1, type, type_len);
+	}
+
+	return ret;
+}
+
+/* RFC5652 Section 8 */
+static uint8_t *pkcs7_decrypt_encrypted_data(const uint8_t *data, size_t d=
ata_len,
+						const char *password,
+						struct asn1_oid *out_oid,
+						size_t *out_len)
+{
+	const uint8_t *version;
+	size_t version_len;
+	const uint8_t *encrypted_info;
+	size_t encrypted_info_len;
+	const uint8_t *type;
+	size_t type_len;
+	const uint8_t *alg_id;
+	size_t alg_id_len;
+	const uint8_t *encrypted;
+	size_t encrypted_len;
+	uint8_t tag;
+	struct l_cipher *alg;
+	uint8_t *plaintext;
+	int i;
+	bool ok;
+	bool is_block;
+
+	if (!(version =3D asn1_der_find_elem(data, data_len, 0, &tag,
+						&version_len)) ||
+			tag !=3D ASN1_ID_INTEGER || version_len !=3D 1 ||
+			(version[0] !=3D 0 && version[0] !=3D 2))
+		return NULL;
+
+	if (!(encrypted_info =3D asn1_der_find_elem(data, data_len, 1, &tag,
+							&encrypted_info_len)) ||
+			tag !=3D ASN1_ID_SEQUENCE)
+		return NULL;
+
+	if (!(type =3D asn1_der_find_elem(encrypted_info, encrypted_info_len, 0,
+					&tag, &type_len)) ||
+			tag !=3D ASN1_ID_OID ||
+			type_len > sizeof(out_oid->asn1))
+		return NULL;
+
+	if (!(alg_id =3D asn1_der_find_elem(encrypted_info, encrypted_info_len, 1,
+					&tag, &alg_id_len)) ||
+			tag !=3D ASN1_ID_SEQUENCE)
+		return NULL;
+
+	/* Not optional in our case, defined [0] IMPLICIT OCTET STRING */
+	if (!(encrypted =3D asn1_der_find_elem(encrypted_info, encrypted_info_len,
+						ASN1_CONTEXT_IMPLICIT(0),
+						&tag, &encrypted_len)) ||
+			tag !=3D ASN1_ID(ASN1_CLASS_CONTEXT, 0, 0) ||
+			encrypted_len < 8)
+		return NULL;
+
+	if (!(alg =3D pkcs5_cipher_from_alg_id(alg_id, alg_id_len, password,
+						&is_block)))
+		return NULL;
+
+	plaintext =3D l_malloc(encrypted_len);
+	ok =3D l_cipher_decrypt(alg, encrypted, plaintext, encrypted_len);
+	l_cipher_free(alg);
+
+	if (!ok)
+		return NULL;
+
+	if (is_block) {
+		/* Also validate the padding */
+		if (encrypted_len < plaintext[encrypted_len - 1] ||
+				plaintext[encrypted_len - 1] > 16)
+			return NULL;
+
+		for (i =3D 1; i < plaintext[encrypted_len - 1]; i++)
+			if (plaintext[encrypted_len - 1 - i] !=3D
+					plaintext[encrypted_len - 1]) {
+				explicit_bzero(plaintext, encrypted_len);
+				l_free(plaintext);
+				return NULL;
+			}
+
+		encrypted_len -=3D plaintext[encrypted_len - 1];
+	}
+
+	if (out_oid) {
+		out_oid->asn1_len =3D type_len;
+		memcpy(out_oid->asn1, type, type_len);
+	}
+
+	*out_len =3D encrypted_len;
+	return plaintext;
+}
+
+/* RFC7292 Appendix A. */
+static struct pkcs12_hash pkcs12_mac_algs[] =3D {
+	{
+		L_CHECKSUM_MD5,    16, 16, 64,
+		{ 8, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0f, 0x02, 0x05 } }
+	},
+	{
+		L_CHECKSUM_SHA1,   20, 20, 64,
+		{ 5, { 0x2b, 0x0e, 0x03, 0x02, 0x1a } }
+	},
+	{
+		L_CHECKSUM_SHA224, 28, 28, 64,
+		{ 9, { 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x02, 0x04 } }
+	},
+	{
+		L_CHECKSUM_SHA256, 32, 32, 64,
+		{ 9, { 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x02, 0x01 } }
+	},
+	{
+		L_CHECKSUM_SHA384, 48, 48, 128,
+		{ 9, { 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x02, 0x02 } }
+	},
+	{
+		L_CHECKSUM_SHA512, 64, 64, 128,
+		{ 9, { 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x02, 0x03 } }
+	},
+	{
+		L_CHECKSUM_SHA512, 64, 28, 128,
+		{ 9, { 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x02, 0x05 } }
+	},
+	{
+		L_CHECKSUM_SHA512, 64, 32, 128,
+		{ 9, { 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x02, 0x06 } }
+	},
+};
+
+static const struct asn1_oid pkcs12_key_bag_oid =3D {
+	11, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x0c, 0x0a, 0x01, 0x01 }
+};
+
+static const struct asn1_oid pkcs12_pkcs8_shrouded_key_bag_oid =3D {
+	11, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x0c, 0x0a, 0x01, 0x02 }
+};
+
+static const struct asn1_oid pkcs12_cert_bag_oid =3D {
+	11, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x0c, 0x0a, 0x01, 0x03 }
+};
+
+static const struct asn1_oid pkcs12_safe_contents_bag_oid =3D {
+	11, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x0c, 0x0a, 0x01, 0x06 }
+};
+
+static const struct asn1_oid pkcs9_x509_certificate_oid =3D {
+	10, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x09, 0x16, 0x01 }
+};
+
+/* RFC7292 Section 4.2.3 */
+static bool pkcs12_parse_cert_bag(const uint8_t *data, size_t data_len,
+					struct l_certchain **out_certchain)
+{
+	const uint8_t *cert_bag;
+	size_t cert_bag_len;
+	const uint8_t *cert_id;
+	size_t cert_id_len;
+	const uint8_t *cert_value;
+	size_t cert_value_len;
+	uint8_t tag;
+	struct l_cert *cert;
+
+	if (!(cert_bag =3D asn1_der_find_elem(data, data_len, 0,
+						&tag, &cert_bag_len)) ||
+			tag !=3D ASN1_ID_SEQUENCE)
+		return false;
+
+	if (!(cert_id =3D asn1_der_find_elem(cert_bag, cert_bag_len, 0,
+						&tag, &cert_id_len)) ||
+			tag !=3D ASN1_ID_OID)
+		return false;
+
+	if (!(cert_value =3D asn1_der_find_elem(cert_bag, cert_bag_len,
+						ASN1_CONTEXT_EXPLICIT(0),
+						&tag, &cert_value_len)) ||
+			tag !=3D ASN1_ID_OCTET_STRING ||
+			cert_value + cert_value_len !=3D data + data_len)
+		return false;
+
+	/* Skip unsupported certificate types */
+	if (!asn1_oid_eq(&pkcs9_x509_certificate_oid, cert_id_len, cert_id))
+		return true;
+
+	if (!(cert =3D l_cert_new_from_der(cert_value, cert_value_len)))
+		return false;
+
+	if (!*out_certchain)
+		*out_certchain =3D certchain_new_from_leaf(cert);
+	else
+		certchain_link_issuer(*out_certchain, cert);
+
+	return true;
+}
+
+static bool pkcs12_parse_safe_contents(const uint8_t *data,
+					size_t data_len, const char *password,
+					struct l_certchain **out_certchain,
+					struct l_key **out_privkey)
+{
+	const uint8_t *safe_contents;
+	size_t safe_contents_len;
+	uint8_t tag;
+
+	if (!(safe_contents =3D asn1_der_find_elem(data, data_len, 0, &tag,
+							&safe_contents_len)) ||
+			tag !=3D ASN1_ID_SEQUENCE ||
+			data + data_len !=3D safe_contents + safe_contents_len)
+		return false;
+
+	/* RFC7292 Section 4.2 */
+	while (safe_contents_len) {
+		const uint8_t *safe_bag;
+		size_t safe_bag_len;
+		const uint8_t *bag_id;
+		size_t bag_id_len;
+		const uint8_t *bag_value;
+		int bag_value_len;
+
+		/* RFC7292 Section 4.2 */
+		if (!(safe_bag =3D asn1_der_find_elem(safe_contents,
+							safe_contents_len, 0,
+							&tag, &safe_bag_len)) ||
+				tag !=3D ASN1_ID_SEQUENCE)
+			return false;
+
+		if (!(bag_id =3D asn1_der_find_elem(safe_bag, safe_bag_len, 0,
+							&tag, &bag_id_len)) ||
+				tag !=3D ASN1_ID_OID)
+			return false;
+
+		/*
+		 * The bagValue is EXPLICITly tagged but we don't want to
+		 * unpack the inner TLV yet so don't use asn1_der_find_elem.
+		 */
+		safe_bag_len -=3D bag_id + bag_id_len - safe_bag;
+		safe_bag =3D bag_id + bag_id_len;
+
+		if (safe_bag_len < 4)
+			return false;
+
+		tag =3D *safe_bag++;
+		safe_bag_len--;
+		bag_value_len =3D asn1_parse_definite_length(&safe_bag,
+								&safe_bag_len);
+		bag_value =3D safe_bag;
+
+		if (bag_value_len < 0 || bag_value_len > (int) safe_bag_len ||
+				tag !=3D ASN1_ID(ASN1_CLASS_CONTEXT, 1, 0))
+			return false;
+
+		/* PKCS#9 attributes ignored */
+
+		safe_contents_len -=3D (safe_bag + safe_bag_len - safe_contents);
+		safe_contents =3D safe_bag + safe_bag_len;
+
+		if (asn1_oid_eq(&pkcs12_key_bag_oid, bag_id_len, bag_id)) {
+			if (!out_privkey || *out_privkey)
+				continue;
+
+			*out_privkey =3D pem_key_from_pkcs8_private_key_info(
+								bag_value,
+								bag_value_len);
+			if (!*out_privkey)
+				return false;
+		} else if (asn1_oid_eq(&pkcs12_pkcs8_shrouded_key_bag_oid,
+					bag_id_len, bag_id)) {
+			if (!out_privkey || *out_privkey)
+				continue;
+
+			*out_privkey =3D
+				pem_key_from_pkcs8_encrypted_private_key_info(
+								bag_value,
+								bag_value_len,
+								password);
+			if (!*out_privkey)
+				return false;
+		} else if (asn1_oid_eq(&pkcs12_cert_bag_oid,
+					bag_id_len, bag_id)) {
+			if (!out_certchain)
+				continue;
+
+			if (!pkcs12_parse_cert_bag(bag_value, bag_value_len,
+							out_certchain))
+				return false;
+		} else if (asn1_oid_eq(&pkcs12_safe_contents_bag_oid,
+					bag_id_len, bag_id)) {
+			/* TODO: depth check */
+			if (!(pkcs12_parse_safe_contents(bag_value,
+								bag_value_len,
+								password,
+								out_certchain,
+								out_privkey)))
+				return false;
+		}
+	}
+
+	return true;
+}
+
+/* RFC5652 Section 4 */
+static const struct asn1_oid pkcs7_data_oid =3D {
+	9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x07, 0x01 }
+};
+
+/* RFC5652 Section 8 */
+static const struct asn1_oid pkcs7_encrypted_data_oid =3D {
+	9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x07, 0x06 }
+};
+
+static void pkcs12_parse_pfx(const uint8_t *ptr, size_t len,
+				const char *password,
+				struct l_certchain **out_certchain,
+				struct l_key **out_privkey)
+{
+	const uint8_t *version;
+	size_t version_len;
+	const uint8_t *auth_safe;
+	size_t auth_safe_len;
+	const uint8_t *auth_safe_seq;
+	size_t auth_safe_seq_len;
+	const uint8_t *mac_data;
+	size_t mac_data_len;
+	const uint8_t *mac;
+	size_t mac_len;
+	const uint8_t *mac_salt;
+	size_t mac_salt_len;
+	const uint8_t *iterations_data;
+	size_t iterations_len;
+	unsigned int iterations;
+	const uint8_t *digest_alg;
+	size_t digest_alg_len;
+	const uint8_t *digest;
+	size_t digest_len;
+	const uint8_t *alg_id;
+	size_t alg_id_len;
+	struct pkcs12_hash *mac_hash;
+	L_AUTO_FREE_VAR(uint8_t *, key) =3D NULL;
+	struct l_checksum *hmac;
+	uint8_t hmac_val[64];
+	uint8_t tag;
+	unsigned int i;
+	bool ok;
+
+	/* RFC7292 Section 4 */
+	if (!(version =3D asn1_der_find_elem(ptr, len, 0, &tag, &version_len)) ||
+			tag !=3D ASN1_ID_INTEGER)
+		return;
+
+	if (version_len !=3D 1 || version[0] !=3D 3)
+		return;
+
+	/*
+	 * Since we only support the password-based integrity mode,  the
+	 * authSafe must be of PKCS#7 type "data" and not "signedData".
+	 */
+	if (!(auth_safe =3D pkcs7_unpack_content_info(ptr, len, 1,
+							&pkcs7_data_oid, NULL,
+							&tag,
+							&auth_safe_len)) ||
+			tag !=3D ASN1_ID_OCTET_STRING)
+		return;
+
+	/*
+	 * openssl can generate PFX structures without macData not signed
+	 * with a public key so handle this case, otherwise the macData
+	 * would not be optional.
+	 */
+	if (auth_safe + auth_safe_len =3D=3D ptr + len)
+		goto integrity_check_done;
+
+	if (!(mac_data =3D asn1_der_find_elem(ptr, len, 2, &tag,
+						&mac_data_len)) ||
+			tag !=3D ASN1_ID_SEQUENCE)
+		return;
+
+	if (!(mac =3D asn1_der_find_elem(mac_data, mac_data_len, 0, &tag,
+					&mac_len)) ||
+			tag !=3D ASN1_ID_SEQUENCE)
+		return;
+
+	if (!(mac_salt =3D asn1_der_find_elem(mac_data, mac_data_len, 1, &tag,
+						&mac_salt_len)) ||
+			tag !=3D ASN1_ID_OCTET_STRING || mac_salt_len > 1024)
+		return;
+
+	if (!(iterations_data =3D asn1_der_find_elem(mac_data, mac_data_len, 2,
+							&tag,
+							&iterations_len)) ||
+			tag !=3D ASN1_ID_INTEGER || iterations_len > 4)
+		return;
+
+	for (iterations =3D 0; iterations_len; iterations_len--)
+		iterations =3D (iterations << 8) | *iterations_data++;
+
+	if (iterations < 1 || iterations > 8192)
+		return;
+
+	/* RFC2315 Section 9.4 */
+	if (!(digest_alg =3D asn1_der_find_elem(mac, mac_len, 0, &tag,
+						&digest_alg_len)) ||
+			tag !=3D ASN1_ID_SEQUENCE)
+		return;
+
+	if (!(digest =3D asn1_der_find_elem(mac, mac_len, 1, &tag,
+						&digest_len)) ||
+			tag !=3D ASN1_ID_OCTET_STRING)
+		return;
+
+	if (!(alg_id =3D asn1_der_find_elem(digest_alg, digest_alg_len,
+						0, &tag, &alg_id_len)) ||
+			tag !=3D ASN1_ID_OID)
+		return;
+
+	/* This is going to be used for both the MAC and its key derivation */
+	for (i =3D 0; i < L_ARRAY_SIZE(pkcs12_mac_algs); i++)
+		if (asn1_oid_eq(&pkcs12_mac_algs[i].oid, alg_id_len, alg_id)) {
+			mac_hash =3D &pkcs12_mac_algs[i];
+			break;
+		}
+
+	if (i =3D=3D L_ARRAY_SIZE(pkcs12_mac_algs) || digest_len !=3D mac_hash->u)
+		return;
+
+	if (!(key =3D pkcs12_pbkdf(password, mac_hash, mac_salt, mac_salt_len,
+					iterations, 3, mac_hash->u)))
+		return;
+
+	hmac =3D l_checksum_new_hmac(mac_hash->alg, key, mac_hash->u);
+	explicit_bzero(key, mac_hash->u);
+
+	if (!hmac)
+		return;
+
+	ok =3D l_checksum_update(hmac, auth_safe, auth_safe_len) &&
+		l_checksum_get_digest(hmac, hmac_val, mac_hash->len) > 0;
+	l_checksum_free(hmac);
+
+	if (!ok)
+		return;
+
+	/*
+	 * SHA-512/224 and SHA-512/256 are not supported.  We can truncate the
+	 * output for key derivation but we can't do this inside the HMAC
+	 * algorithms based on these hashes.  We skip the MAC verification
+	 * if one of these hashes is used (identified by .u !=3D .len)
+	 */
+	if (mac_hash->u !=3D mac_hash->len)
+		goto integrity_check_done;
+
+	if (memcmp(hmac_val, digest, digest_len))
+		return;
+
+integrity_check_done:
+	if (!(auth_safe_seq =3D asn1_der_find_elem(auth_safe, auth_safe_len, 0,
+						&tag, &auth_safe_seq_len)) ||
+			tag !=3D ASN1_ID_SEQUENCE ||
+			auth_safe + auth_safe_len !=3D
+			auth_safe_seq + auth_safe_seq_len)
+		return;
+
+	i =3D 0;
+	while (1) {
+		struct asn1_oid data_oid;
+		const uint8_t *data;
+		size_t data_len;
+
+		if (!(data =3D pkcs7_unpack_content_info(auth_safe_seq,
+							auth_safe_seq_len, i++,
+							NULL, &data_oid, &tag,
+							&data_len)))
+			break;
+
+		if (asn1_oid_eq(&pkcs7_encrypted_data_oid,
+					data_oid.asn1_len, data_oid.asn1)) {
+			uint8_t *plaintext;
+			size_t plaintext_len;
+			struct asn1_oid oid;
+
+			if (tag !=3D ASN1_ID_SEQUENCE)
+				goto error;
+
+			/*
+			 * This is same as PKCS#7 encryptedData but the ciphers
+			 * used are from PKCS#12 (broken but still the default
+			 * everywhere) and PKCS#5 (recommended).
+			 */
+			plaintext =3D pkcs7_decrypt_encrypted_data(data, data_len,
+								password, &oid,
+								&plaintext_len);
+			if (!plaintext)
+				goto error;
+
+			/*
+			 * Since we only support PKCS#7 data and encryptedData
+			 * types, and there's no point re-encrypting
+			 * encryptedData, the plaintext must be a PKCS#7
+			 * "data".
+			 */
+			ok =3D asn1_oid_eq(&pkcs7_data_oid,
+						oid.asn1_len, oid.asn1) &&
+				pkcs12_parse_safe_contents(plaintext,
+								plaintext_len,
+								password,
+								out_certchain,
+								out_privkey);
+			explicit_bzero(plaintext, plaintext_len);
+			l_free(plaintext);
+
+			if (!ok)
+				goto error;
+		} else if (asn1_oid_eq(&pkcs7_data_oid,
+					data_oid.asn1_len, data_oid.asn1)) {
+			if (tag !=3D ASN1_ID_OCTET_STRING)
+				goto error;
+
+			if (!pkcs12_parse_safe_contents(data, data_len,
+							password,
+							out_certchain,
+							out_privkey))
+				goto error;
+		}
+		/* envelopedData support not needed */
+	}
+
+	return;
+
+error:
+	if (out_certchain && *out_certchain) {
+		l_certchain_free(*out_certchain);
+		*out_certchain =3D NULL;
+	}
+
+	if (out_privkey && *out_privkey) {
+		l_key_free(*out_privkey);
+		*out_privkey =3D NULL;
+	}
+}
+
 /*
  * Look at a file, try to detect which of the few X.509 certificate and/or
  * private key container formats it uses and load any certificates in it as
@@ -946,6 +1522,8 @@ LIB_EXPORT struct l_key *l_pem_load_private_key(const =
char *filename,
  *  PEM PKCS#8 encrypted and unenecrypted private keys
  *  PEM legacy PKCS#1 encrypted and unenecrypted private keys
  *  Raw X.509 certificates (.cer, .der, .crt)
+ *  PKCS#12 certificates
+ *  PKCS#12 encrypted and unencrypted private keys
  *
  * The raw format contains exactly one certificate, PEM and PKCS#12 files
  * can contain any combination of certificates and private keys.
@@ -1014,6 +1592,27 @@ LIB_EXPORT void l_pem_load_container_file(const char=
 *filename,
 =

 			goto close;
 		}
+
+		if (tag =3D=3D ASN1_ID_INTEGER) {
+			/*
+			 * Since we don't support public key-protected PKCS#12
+			 * modes, we always require the password at least for
+			 * the integrity check.  Strictly speaking encryption
+			 * may not actually be in use.  We also don't support
+			 * files with different integrity and privacy
+			 * passwords, they must be identical if privacy is
+			 * enabled.
+			 */
+			if (out_encrypted)
+				*out_encrypted =3D true;
+
+			if (!password)
+				goto close;
+
+			pkcs12_parse_pfx(seq_data, len, password,
+						out_certchain, out_privkey);
+			goto close;
+		}
 	}
 =

 not_der_after_all:
@@ -1060,6 +1659,19 @@ not_der_after_all:
 			goto next;
 		}
 =

+		/* PEM-encoded PKCS12, probably very rare */
+		if (!strcmp(type_label, "PKCS12")) {
+			if (out_encrypted)
+				*out_encrypted =3D true;
+
+			if (!password)
+				goto next;
+
+			pkcs12_parse_pfx(der, der_len, password,
+						out_certchain, out_privkey);
+			goto next;
+		}
+
 		/* Only use the first private key found */
 		if (out_privkey && !*out_privkey) {
 			*out_privkey =3D pem_load_private_key(der, der_len,
-- =

2.27.0

--===============2518797230398848725==--

