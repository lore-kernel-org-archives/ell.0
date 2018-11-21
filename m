Content-Type: multipart/mixed; boundary="===============0760151772971562113=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 09/16] tls: Send the DistinguishedName in Certificate Request
Date: Wed, 21 Nov 2018 16:08:56 +0100
Message-ID: <20181121150903.24437-9-andrew.zaborowski@intel.com>
In-Reply-To: <20181121150903.24437-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0760151772971562113==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Now that we have l_cert_get_dn we can fill in the DistinguishedNames
fields in the Certificate Request TLS message.
---
 ell/tls.c | 38 +++++++++++++++++++++++++++++++++++---
 1 file changed, 35 insertions(+), 3 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 7d6b0e0..a748e62 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -39,6 +39,7 @@
 #include "cert-private.h"
 #include "tls-private.h"
 #include "key.h"
+#include "asn1-private.h"
 =

 void tls10_prf(const void *secret, size_t secret_len,
 		const char *label,
@@ -1050,10 +1051,22 @@ static struct tls_signature_hash_algorithms tls_sig=
nature_hash_pref[] =3D {
 static bool tls_send_certificate_request(struct l_tls *tls)
 {
 	uint8_t *buf, *ptr, *dn_ptr, *signature_hash_ptr;
+	const struct l_queue_entry *entry;
 	unsigned int i;
+	size_t dn_total =3D 0;
+
+	for (entry =3D l_queue_get_entries(tls->ca_certs); entry;
+			entry =3D entry->next) {
+		struct l_cert *ca_cert =3D entry->data;
+		size_t dn_size;
+
+		if (l_cert_get_dn(ca_cert, &dn_size))
+			dn_total +=3D 10 + dn_size;
+	}
 =

 	buf =3D l_malloc(128 + L_ARRAY_SIZE(tls_cert_type_pref) +
-			2 * L_ARRAY_SIZE(tls_signature_hash_pref));
+			2 * L_ARRAY_SIZE(tls_signature_hash_pref) +
+			dn_total);
 	ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
 =

 	/* Fill in the Certificate Request body */
@@ -1086,8 +1099,27 @@ static bool tls_send_certificate_request(struct l_tl=
s *tls)
 	}
 =

 	dn_ptr =3D ptr;
-	ptr +=3D 2;				/* Leave space for sizes */
-	l_put_be16(0, dn_ptr);			/* DistinguishedNames size */
+	ptr +=3D 2;			/* Leave space for the total DN size */
+
+	for (entry =3D l_queue_get_entries(tls->ca_certs); entry;
+			entry =3D entry->next) {
+		struct l_cert *ca_cert =3D entry->data;
+		size_t dn_size;
+		const uint8_t *dn =3D l_cert_get_dn(ca_cert, &dn_size);
+		uint8_t *cur_dn_ptr =3D ptr;
+
+		if (!dn)
+			continue;
+
+		ptr +=3D 2;		/* Leave space for current DN size */
+		*ptr++ =3D ASN1_ID_SEQUENCE;	/* DER outer SEQUENCE tag */
+		asn1_write_definite_length(&ptr, dn_size); /* length */
+		memcpy(ptr, dn, dn_size);	/* value */
+		ptr +=3D dn_size;
+		l_put_be16(ptr - cur_dn_ptr - 2, cur_dn_ptr);
+	}
+
+	l_put_be16(ptr - dn_ptr - 2, dn_ptr);	/* DistinguishedNames size */
 =

 	tls_tx_handshake(tls, TLS_CERTIFICATE_REQUEST, buf, ptr - buf);
 =

-- =

2.19.1


--===============0760151772971562113==--

