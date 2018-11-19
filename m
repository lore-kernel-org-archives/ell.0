Content-Type: multipart/mixed; boundary="===============0816882629498458834=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/7] cert: Add l_cert and l_certchain accessor functions
Date: Mon, 19 Nov 2018 19:23:44 +0100
Message-ID: <20181119182348.4562-3-andrew.zaborowski@intel.com>
In-Reply-To: <20181119182348.4562-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0816882629498458834==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/cert.c  | 86 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/cert.h  | 15 ++++++++++
 ell/ell.sym |  7 +++++
 3 files changed, 108 insertions(+)

diff --git a/ell/cert.c b/ell/cert.c
index 141362f..7d0c0b5 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -146,6 +146,52 @@ LIB_EXPORT void l_cert_free(struct l_cert *cert)
 	l_free(cert);
 }
 =

+LIB_EXPORT const uint8_t *l_cert_get_der_data(struct l_cert *cert,
+						size_t *out_len)
+{
+	if (unlikely(!cert))
+		return NULL;
+
+	*out_len =3D cert->asn1_len;
+	return cert->asn1;
+}
+
+LIB_EXPORT const uint8_t *l_cert_get_dn(struct l_cert *cert, size_t *out_l=
en)
+{
+	if (unlikely(!cert))
+		return NULL;
+
+	return asn1_der_find_elem_by_path(cert->asn1, cert->asn1_len,
+						ASN1_ID_OID, out_len,
+						X509_CERTIFICATE_POS,
+						X509_TBSCERTIFICATE_POS,
+						X509_TBSCERT_SUBJECT_DN_POS,
+						-1);
+}
+
+LIB_EXPORT enum l_cert_key_type l_cert_get_pubkey_type(struct l_cert *cert)
+{
+	if (unlikely(!cert))
+		return L_CERT_KEY_UNKNOWN;
+
+	return cert->pubkey_type;
+}
+
+/*
+ * Note: Returns a new l_key object to be freed by the caller.
+ */
+LIB_EXPORT struct l_key *l_cert_get_pubkey(struct l_cert *cert)
+{
+	if (unlikely(!cert))
+		return NULL;
+
+	/* Use kernel's ASN.1 certificate parser to find the key data for us */
+	if (cert->pubkey_type =3D=3D L_CERT_KEY_RSA)
+		return l_key_new(L_KEY_RSA, cert->asn1, cert->asn1_len);
+
+	return NULL;
+}
+
 /*
  * Note: takes ownership of the certificate.  The certificate is
  * assumed to be new and not linked into any certchain object.
@@ -197,3 +243,43 @@ LIB_EXPORT void l_certchain_free(struct l_certchain *c=
hain)
 =

 	l_free(chain);
 }
+
+LIB_EXPORT struct l_cert *l_certchain_get_leaf(struct l_certchain *chain)
+{
+	if (unlikely(!chain))
+		return NULL;
+
+	return chain->leaf;
+}
+
+LIB_EXPORT bool l_certchain_foreach_from_leaf(struct l_certchain *chain,
+						l_cert_foreach_cb_t cb,
+						void *user_data)
+{
+	struct l_cert *cert;
+
+	if (unlikely(!chain))
+		return false;
+
+	for (cert =3D chain->leaf; cert; cert =3D cert->issuer)
+		if (cb(cert, user_data))
+			return true;
+
+	return false;
+}
+
+LIB_EXPORT bool l_certchain_foreach_from_ca(struct l_certchain *chain,
+						l_cert_foreach_cb_t cb,
+						void *user_data)
+{
+	struct l_cert *cert;
+
+	if (unlikely(!chain))
+		return false;
+
+	for (cert =3D chain->ca; cert; cert =3D cert->issued)
+		if (cb(cert, user_data))
+			return true;
+
+	return false;
+}
diff --git a/ell/cert.h b/ell/cert.h
index aafc0a9..81a8b43 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -37,11 +37,26 @@ enum l_cert_key_type {
 	L_CERT_KEY_UNKNOWN,
 };
 =

+typedef bool (*l_cert_foreach_cb_t)(struct l_cert *cert, void *user_data);
+
 struct l_cert *l_cert_new_from_der(const uint8_t *buf, size_t buf_len);
 void l_cert_free(struct l_cert *cert);
 =

+const uint8_t *l_cert_get_der_data(struct l_cert *cert, size_t *out_len);
+const uint8_t *l_cert_get_dn(struct l_cert *cert, size_t *out_len);
+enum l_cert_key_type l_cert_get_pubkey_type(struct l_cert *cert);
+struct l_key *l_cert_get_pubkey(struct l_cert *cert);
+
 void l_certchain_free(struct l_certchain *chain);
 =

+struct l_cert *l_certchain_get_leaf(struct l_certchain *chain);
+bool l_certchain_foreach_from_leaf(struct l_certchain *chain,
+					l_cert_foreach_cb_t cb,
+					void *user_data);
+bool l_certchain_foreach_from_ca(struct l_certchain *chain,
+					l_cert_foreach_cb_t cb,
+					void *user_data);
+
 #ifdef __cplusplus
 }
 #endif
diff --git a/ell/ell.sym b/ell/ell.sym
index 0e6f8a0..414df53 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -435,7 +435,14 @@ global:
 	/* cert */
 	l_cert_new_from_der;
 	l_cert_free;
+	l_cert_get_der_data;
+	l_cert_get_dn;
+	l_cert_get_pubkey_type;
+	l_cert_get_pubkey;
 	l_certchain_free;
+	l_certchain_get_leaf;
+	l_certchain_foreach_from_leaf;
+	l_certchain_foreach_from_ca;
 local:
 	*;
 };
-- =

2.19.1


--===============0816882629498458834==--

