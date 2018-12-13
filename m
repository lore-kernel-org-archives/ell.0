Content-Type: multipart/mixed; boundary="===============6871791731949314162=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 7/9] tls, pem: Drop tls_cert_load_file, l_pem_load_certificate
Date: Thu, 13 Dec 2018 20:57:44 +0100
Message-ID: <20181213195746.32144-7-andrew.zaborowski@intel.com>
In-Reply-To: <20181213195746.32144-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6871791731949314162==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

These functions have no users left.
---
 ell/ell.sym       |  1 -
 ell/pem.c         | 20 --------------------
 ell/pem.h         |  1 -
 ell/tls-private.h |  1 -
 ell/tls.c         | 15 ---------------
 5 files changed, 38 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 2ff7d30..23d2349 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -337,7 +337,6 @@ global:
 	l_netlink_set_debug;
 	/* pem */
 	l_pem_load_buffer;
-	l_pem_load_certificate;
 	l_pem_load_certificate_chain;
 	l_pem_load_certificate_list;
 	l_pem_load_file;
diff --git a/ell/pem.c b/ell/pem.c
index dffd476..fa08962 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -245,26 +245,6 @@ LIB_EXPORT uint8_t *l_pem_load_file(const char *filena=
me, int index,
 	return result;
 }
 =

-LIB_EXPORT uint8_t *l_pem_load_certificate(const char *filename, size_t *l=
en)
-{
-	uint8_t *content;
-	char *label;
-
-	content =3D l_pem_load_file(filename, 0, &label, len);
-
-	if (!content)
-		return NULL;
-
-	if (strcmp(label, "CERTIFICATE")) {
-		l_free(content);
-		content =3D NULL;
-	}
-
-	l_free(label);
-
-	return content;
-}
-
 LIB_EXPORT struct l_certchain *l_pem_load_certificate_chain(
 							const char *filename)
 {
diff --git a/ell/pem.h b/ell/pem.h
index bb9e53a..fc5b019 100644
--- a/ell/pem.h
+++ b/ell/pem.h
@@ -37,7 +37,6 @@ uint8_t *l_pem_load_buffer(const uint8_t *buf, size_t buf=
_len,
 uint8_t *l_pem_load_file(const char *filename, int index,
 				char **type_label, size_t *len);
 =

-uint8_t *l_pem_load_certificate(const char *filename, size_t *len);
 struct l_certchain *l_pem_load_certificate_chain(const char *filename);
 struct l_queue *l_pem_load_certificate_list(const char *filename);
 =

diff --git a/ell/tls-private.h b/ell/tls-private.h
index e2ec014..3fda4b5 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -233,7 +233,6 @@ void tls_tx_record(struct l_tls *tls, enum tls_content_=
type type,
 bool tls_handle_message(struct l_tls *tls, const uint8_t *message,
 			int len, enum tls_content_type type, uint16_t version);
 =

-struct l_cert *tls_cert_load_file(const char *filename);
 int tls_parse_certificate_list(const void *data, size_t len,
 				struct l_certchain **out_certchain);
 =

diff --git a/ell/tls.c b/ell/tls.c
index 8abbabd..59d7f5a 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2868,21 +2868,6 @@ const char *tls_handshake_state_to_str(enum tls_hand=
shake_state state)
 	return buf;
 }
 =

-struct l_cert *tls_cert_load_file(const char *filename)
-{
-	uint8_t *der;
-	size_t len;
-	struct l_cert *cert;
-
-	der =3D l_pem_load_certificate(filename, &len);
-	if (!der)
-		return NULL;
-
-	cert =3D l_cert_new_from_der(der, len);
-	l_free(der);
-	return cert;
-}
-
 int tls_parse_certificate_list(const void *data, size_t len,
 				struct l_certchain **out_certchain)
 {
-- =

2.19.1


--===============6871791731949314162==--

