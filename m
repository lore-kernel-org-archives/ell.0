Content-Type: multipart/mixed; boundary="===============0512228927386596251=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 05/10] asn1: Use const pointers in ASN1 parsing utilities
Date: Fri, 11 Aug 2017 01:10:11 +0200
Message-ID: <20170810231016.29445-5-andrew.zaborowski@intel.com>
In-Reply-To: <20170810231016.29445-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0512228927386596251==
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
index c1f1c5d..b87d932 100644
--- a/ell/asn1-private.h
+++ b/ell/asn1-private.h
@@ -63,8 +63,9 @@ static inline int parse_asn1_definite_length(const uint8_=
t **buf,
 }
 =

 /* Return index'th element in a DER SEQUENCE */
-static inline uint8_t *der_find_elem(uint8_t *buf, size_t len_in, int inde=
x,
-			uint8_t *tag, size_t *len_out)
+static inline const uint8_t *der_find_elem(const uint8_t *buf, size_t len_=
in,
+						int index, uint8_t *tag,
+						size_t *len_out)
 {
 	int tlv_len;
 =

@@ -90,9 +91,9 @@ static inline uint8_t *der_find_elem(uint8_t *buf, size_t=
 len_in, int index,
 }
 =

 /* Return an element in a DER SEQUENCE structure by path */
-static inline uint8_t *der_find_elem_by_path(uint8_t *buf, size_t len_in,
-						uint8_t tag, size_t *len_out,
-						...)
+static inline const uint8_t *der_find_elem_by_path(const uint8_t *buf,
+						size_t len_in, uint8_t tag,
+						size_t *len_out, ...)
 {
 	uint8_t elem_tag;
 	int pos;
diff --git a/ell/tls.c b/ell/tls.c
index aa6e487..9b199ef 100644
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


--===============0512228927386596251==--

