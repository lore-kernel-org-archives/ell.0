Content-Type: multipart/mixed; boundary="===============5162687964710426955=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/6] cert: Change l_certchain_foreach* signatures
Date: Fri, 30 Nov 2018 13:05:47 +0100
Message-ID: <20181130120550.8866-3-andrew.zaborowski@intel.com>
In-Reply-To: <20181130120550.8866-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5162687964710426955==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Change the "foreach" to "walk" in l_certchain_foreach_from_leaf/_ca
and in l_cert_foreach_cb_t to not imply that the whole chain is always
traversed because we let the callbacks interrupt the iteration by
returning true.  Drop the return values.  Add comments for the two
functions affected.
---
 ell/cert.c  | 28 ++++++++++++++++------------
 ell/cert.h  | 12 +++++-------
 ell/ell.sym |  4 ++--
 ell/tls.c   |  4 ++--
 4 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index 66433c2..ae93313 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -253,36 +253,40 @@ LIB_EXPORT struct l_cert *l_certchain_get_leaf(struct=
 l_certchain *chain)
 	return chain->leaf;
 }
 =

-LIB_EXPORT bool l_certchain_foreach_from_leaf(struct l_certchain *chain,
-						l_cert_foreach_cb_t cb,
+/*
+ * Call @cb for each certificate in the chain starting from the leaf
+ * certificate.  Stop if a call returns @true.
+ */
+LIB_EXPORT void l_certchain_walk_from_leaf(struct l_certchain *chain,
+						l_cert_walk_cb_t cb,
 						void *user_data)
 {
 	struct l_cert *cert;
 =

 	if (unlikely(!chain))
-		return false;
+		return;
 =

 	for (cert =3D chain->leaf; cert; cert =3D cert->issuer)
 		if (cb(cert, user_data))
-			return true;
-
-	return false;
+			break;
 }
 =

-LIB_EXPORT bool l_certchain_foreach_from_ca(struct l_certchain *chain,
-						l_cert_foreach_cb_t cb,
+/*
+ * Call @cb for each certificate in the chain starting from the root
+ * certificate.  Stop if a call returns @true.
+ */
+LIB_EXPORT void l_certchain_walk_from_ca(struct l_certchain *chain,
+						l_cert_walk_cb_t cb,
 						void *user_data)
 {
 	struct l_cert *cert;
 =

 	if (unlikely(!chain))
-		return false;
+		return;
 =

 	for (cert =3D chain->ca; cert; cert =3D cert->issued)
 		if (cb(cert, user_data))
-			return true;
-
-	return false;
+			break;
 }
 =

 LIB_EXPORT bool l_certchain_find(struct l_certchain *chain,
diff --git a/ell/cert.h b/ell/cert.h
index c1513f1..0c3947c 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -38,7 +38,7 @@ enum l_cert_key_type {
 	L_CERT_KEY_UNKNOWN,
 };
 =

-typedef bool (*l_cert_foreach_cb_t)(struct l_cert *cert, void *user_data);
+typedef bool (*l_cert_walk_cb_t)(struct l_cert *cert, void *user_data);
 =

 struct l_cert *l_cert_new_from_der(const uint8_t *buf, size_t buf_len);
 void l_cert_free(struct l_cert *cert);
@@ -51,12 +51,10 @@ struct l_key *l_cert_get_pubkey(struct l_cert *cert);
 void l_certchain_free(struct l_certchain *chain);
 =

 struct l_cert *l_certchain_get_leaf(struct l_certchain *chain);
-bool l_certchain_foreach_from_leaf(struct l_certchain *chain,
-					l_cert_foreach_cb_t cb,
-					void *user_data);
-bool l_certchain_foreach_from_ca(struct l_certchain *chain,
-					l_cert_foreach_cb_t cb,
-					void *user_data);
+void l_certchain_walk_from_leaf(struct l_certchain *chain,
+				l_cert_walk_cb_t cb, void *user_data);
+void l_certchain_walk_from_ca(struct l_certchain *chain,
+				l_cert_walk_cb_t cb, void *user_data);
 =

 bool l_certchain_find(struct l_certchain *chain, struct l_queue *ca_certs);
 bool l_certchain_verify(struct l_certchain *chain, struct l_queue *ca_cert=
s);
diff --git a/ell/ell.sym b/ell/ell.sym
index 9cea0c1..b8f3730 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -445,8 +445,8 @@ global:
 	l_cert_get_pubkey;
 	l_certchain_free;
 	l_certchain_get_leaf;
-	l_certchain_foreach_from_leaf;
-	l_certchain_foreach_from_ca;
+	l_certchain_walk_from_leaf;
+	l_certchain_walk_from_ca;
 	l_certchain_find;
 	l_certchain_verify;
 local:
diff --git a/ell/tls.c b/ell/tls.c
index 83128a5..e32b833 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -961,7 +961,7 @@ static bool tls_send_certificate(struct l_tls *tls)
 	 */
 =

 	total =3D 0;
-	l_certchain_foreach_from_leaf(tls->cert, tls_cert_list_add_size, &total);
+	l_certchain_walk_from_leaf(tls->cert, tls_cert_list_add_size, &total);
 =

 	buf =3D l_malloc(128 + total);
 	ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
@@ -971,7 +971,7 @@ static bool tls_send_certificate(struct l_tls *tls)
 	*ptr++ =3D total >> 16;
 	*ptr++ =3D total >>  8;
 	*ptr++ =3D total >>  0;
-	l_certchain_foreach_from_leaf(tls->cert, tls_cert_list_append, &ptr);
+	l_certchain_walk_from_leaf(tls->cert, tls_cert_list_append, &ptr);
 =

 	tls_tx_handshake(tls, TLS_CERTIFICATE, buf, ptr - buf);
 =

-- =

2.19.1


--===============5162687964710426955==--

