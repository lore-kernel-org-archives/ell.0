Content-Type: multipart/mixed; boundary="===============0976722510429406796=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/7] asn1: Use const pointers in ASN1 parsing utilities
Date: Mon, 14 Aug 2017 16:57:45 +0200
Message-ID: <20170814145750.6683-2-andrew.zaborowski@intel.com>
In-Reply-To: <20170814145750.6683-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0976722510429406796==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

For convenience take const pointers as inputs to the ASN1 utilites,
we only use those functions for parsing.
---
 ell/asn1-private.h | 11 ++++++-----
 ell/tls.c          |  2 +-
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/ell/asn1-private.h b/ell/asn1-private.h
index d7c8b6b..7827355 100644
--- a/ell/asn1-private.h
+++ b/ell/asn1-private.h
@@ -63,8 +63,9 @@ static inline int asn1_parse_definite_length(const uint8_=
t **buf,
 }
 =

 /* Return index'th element in a DER SEQUENCE */
-static inline uint8_t *asn1_der_find_elem(uint8_t *buf, size_t len_in,
-				int index, uint8_t *tag, size_t *len_out)
+static inline const uint8_t *asn1_der_find_elem(const uint8_t *buf,
+						size_t len_in, int index,
+						uint8_t *tag, size_t *len_out)
 {
 	int tlv_len;
 =

@@ -90,9 +91,9 @@ static inline uint8_t *asn1_der_find_elem(uint8_t *buf, s=
ize_t len_in,
 }
 =

 /* Return an element in a DER SEQUENCE structure by path */
-static inline uint8_t *asn1_der_find_elem_by_path(uint8_t *buf, size_t len=
_in,
-						uint8_t tag, size_t *len_out,
-						...)
+static inline const uint8_t *asn1_der_find_elem_by_path(const uint8_t *buf,
+						size_t len_in, uint8_t tag,
+						size_t *len_out, ...)
 {
 	uint8_t elem_tag;
 	int pos;
diff --git a/ell/tls.c b/ell/tls.c
index 894389a..ecdcff4 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2489,7 +2489,7 @@ void tls_cert_free_certchain(struct tls_cert *cert)
 =

 enum tls_cert_key_type tls_cert_get_pubkey_type(struct tls_cert *cert)
 {
-	uint8_t *key_type;
+	const uint8_t *key_type;
 	size_t key_type_len;
 	int i;
 =

-- =

2.11.0


--===============0976722510429406796==--

