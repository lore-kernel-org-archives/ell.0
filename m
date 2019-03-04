Content-Type: multipart/mixed; boundary="===============6804521016543429034=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 1/5] ell: Use __inline__ instead of inline for C89.
Date: Mon, 04 Mar 2019 10:42:55 -0800
Message-ID: <20190304184259.22809-2-ossama.othman@intel.com>
In-Reply-To: <20190304184259.22809-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6804521016543429034==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The inline keyword was introduced in C99.  Use the gcc __inline__
extension for older C standards.
---
 ell/asn1-private.h | 4 ++++
 ell/utf8.h         | 4 ++++
 ell/util.h         | 4 ++++
 3 files changed, 12 insertions(+)

diff --git a/ell/asn1-private.h b/ell/asn1-private.h
index bea9ea9..53bba4c 100644
--- a/ell/asn1-private.h
+++ b/ell/asn1-private.h
@@ -40,6 +40,10 @@ struct asn1_oid {
 	((oid1)->asn1_len =3D=3D (oid2_len) && \
 	 !memcmp((oid1)->asn1, (oid2_string), (oid2_len)))
 =

+#if __STDC_VERSION__ <=3D 199409L
+#define inline __inline__
+#endif
+
 static inline int asn1_parse_definite_length(const uint8_t **buf,
 						size_t *len)
 {
diff --git a/ell/utf8.h b/ell/utf8.h
index 92226d3..c92da60 100644
--- a/ell/utf8.h
+++ b/ell/utf8.h
@@ -80,6 +80,10 @@ enum l_ascii {
 #define l_ascii_isxdigit(c) \
 	((l_ascii_table[(unsigned char) (c)] & L_ASCII_XDIGIT) !=3D 0)
 =

+#if __STDC_VERSION__ <=3D 199409L
+#define inline __inline__
+#endif
+
 static inline __attribute__ ((always_inline))
 					bool l_ascii_isblank(unsigned char c)
 {
diff --git a/ell/util.h b/ell/util.h
index de4df74..c4ba7f8 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -102,6 +102,10 @@ do {						\
 #error "Unknown byte order"
 #endif
 =

+#if __STDC_VERSION__ <=3D 199409L
+#define inline __inline__
+#endif
+
 static inline uint8_t l_get_u8(const void *ptr)
 {
 	return *((const uint8_t *) ptr);
-- =

2.17.1


--===============6804521016543429034==--

