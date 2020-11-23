Content-Type: multipart/mixed; boundary="===============2622378952160655166=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/5] pem: Parse PKCS#1 formatted private keys
Date: Mon, 23 Nov 2020 12:54:13 +0100
Message-ID: <20201123115417.218473-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2622378952160655166==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The PKCS#1 RSAPrivateKey format is used within the PKCS#8 PrivateKey
structure so we just need to wrap it in some extra ASN.1 data to get a
format understood by the pkcs8-key-parse module.

Improve some comments with the right RFC references.
---
 ell/asn1-private.h |   1 +
 ell/pem.c          | 106 +++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 98 insertions(+), 9 deletions(-)

diff --git a/ell/asn1-private.h b/ell/asn1-private.h
index e34f977..2a31241 100644
--- a/ell/asn1-private.h
+++ b/ell/asn1-private.h
@@ -29,6 +29,7 @@
 #define ASN1_ID_INTEGER		ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x02)
 #define ASN1_ID_BIT_STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x03)
 #define ASN1_ID_OCTET_STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x04)
+#define ASN1_ID_NULL		ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x05)
 #define ASN1_ID_OID		ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x06)
 #define ASN1_ID_UTF8STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x0c)
 #define ASN1_ID_PRINTABLESTRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x13)
diff --git a/ell/pem.c b/ell/pem.c
index b54270e..99020b1 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -400,14 +400,21 @@ static struct l_key *pem_load_private_key(uint8_t *co=
ntent,
 	struct l_key *pkey =3D NULL;
 =

 	/*
-	 * RFC7469- and PKCS#8-compatible label (default in OpenSSL 1.0.1+)
-	 * and the older (OpenSSL <=3D 0.9.8 default) label.
+	 * RFC7468 Section 10-compatible unencrypted private key label
+	 * (also mentioned in PKCS#8/RFC5958 Section 5), encodes
+	 * the PKCS#8/RFC5958 PrivateKeyInfo structure -- supported
+	 * directly by the pkcs8-key-parser kernel module.
 	 */
-	if (!strcmp(label, "PRIVATE KEY") ||
-			!strcmp(label, "RSA PRIVATE KEY"))
+	if (!strcmp(label, "PRIVATE KEY"))
 		goto done;
 =

-	/* RFC5958 (PKCS#8) section 3 type encrypted key label */
+	/*
+	 * RFC7468 Section 11-compatible encrypted private key label
+	 * (also mentioned in PKCS#8/RFC5958 Section 5), encodes
+	 * the PKCS#8/RFC5958 EncryptedPrivateKeyInfo structure.  We
+	 * decrypt it into a plain PrivateKeyInfo for the
+	 * pkcs8-key-parser module.
+	 */
 	if (!strcmp(label, "ENCRYPTED PRIVATE KEY")) {
 		const uint8_t *key_info, *alg_id, *data;
 		uint8_t tag;
@@ -479,11 +486,92 @@ static struct l_key *pem_load_private_key(uint8_t *co=
ntent,
 	}
 =

 	/*
-	 * TODO: handle RSA PRIVATE KEY format encrypted keys
-	 * (as produced by "openssl rsa" commands), incompatible with
-	 * RFC7468 parsing because of the headers present before
-	 * base64-encoded data.
+	 * Legacy RSA private key label aka. SSLeay format label, created
+	 * by most software but not documented in an RFC.  Encodes the
+	 * PKCS#1/RFC8017 RSAPrivateKey structure.  We wrap it in a PKCS#8
+	 * PrivateKeyInfo for the pkcs8-key-parser module.
+	 *
+	 * TODO: decrypt RSA PRIVATE KEY format encrypted keys
+	 * as produced by "openssl rsa" commands.  These are incompatible
+	 * with RFC7468 parsing because of the RFC822 headers present
+	 * before base64-encoded data.  The format is documented in
+	 * RFC1421 and the encryption algorithms in RFC1423 although
+	 * openssl allows many more algorithms than those documented.
+	 * Then wrap in a PrivateKeyInfo like above.
 	 */
+	if (!strcmp(label, "RSA PRIVATE KEY")) {
+		const uint8_t *data;
+		uint8_t tag;
+		size_t data_len;
+		const uint8_t *key_data;
+		size_t key_data_len;
+		int i;
+		uint8_t *private_key;
+		size_t private_key_len;
+		uint8_t *one_asymmetric_key;
+		uint8_t *ptr;
+
+		static const uint8_t version0[] =3D {
+			ASN1_ID_INTEGER, 0x01, 0x00
+		};
+		static const uint8_t pkcs1_rsa_encryption[] =3D {
+			ASN1_ID_SEQUENCE, 0x0d,
+			ASN1_ID_OID, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d,
+			0x01, 0x01, 0x01,
+			ASN1_ID_NULL, 0x00,
+		};
+
+		/*
+		 * Sanity check that it's a version 0 or 1 RSAPrivateKey
+		 * structure with the 8 integers, if it's not, make a last
+		 * ditch attempt to load it into the kernel directly.
+		 */
+		key_data =3D asn1_der_find_elem(content, len, 0, &tag,
+						&key_data_len);
+		if (!key_data || tag !=3D ASN1_ID_SEQUENCE)
+			goto done;
+
+		data =3D asn1_der_find_elem(key_data, key_data_len, 0, &tag,
+						&data_len);
+		if (!data || tag !=3D ASN1_ID_INTEGER || data_len !=3D 1 ||
+				(data[0] !=3D 0x00 && data[0] !=3D 0x01))
+			goto done;
+
+		for (i =3D 1; i < 9; i++) {
+			data =3D asn1_der_find_elem(key_data, key_data_len,
+							i, &tag, &data_len);
+			if (!data || tag !=3D ASN1_ID_INTEGER || data_len < 1)
+				goto done;
+		}
+
+		private_key =3D l_malloc(10 + len);
+		ptr =3D private_key;
+		*ptr++ =3D ASN1_ID_OCTET_STRING;
+		asn1_write_definite_length(&ptr, len);
+		memcpy(ptr, content, len);
+		ptr +=3D len;
+		private_key_len =3D ptr - private_key;
+
+		one_asymmetric_key =3D l_malloc(32 + private_key_len);
+		ptr =3D one_asymmetric_key;
+		*ptr++ =3D ASN1_ID_SEQUENCE;
+		asn1_write_definite_length(&ptr,
+						sizeof(version0) +
+						sizeof(pkcs1_rsa_encryption) +
+						private_key_len);
+		memcpy(ptr, version0, sizeof(version0));
+		ptr +=3D sizeof(version0);
+		memcpy(ptr, pkcs1_rsa_encryption, sizeof(pkcs1_rsa_encryption));
+		ptr +=3D sizeof(pkcs1_rsa_encryption);
+		memcpy(ptr, private_key, private_key_len);
+		ptr +=3D private_key_len;
+		l_free(private_key);
+
+		l_free(content);
+		content =3D one_asymmetric_key;
+		len =3D ptr - one_asymmetric_key;
+		goto done;
+	}
 =

 	/* Label not known */
 	goto err;
-- =

2.27.0

--===============2622378952160655166==--

