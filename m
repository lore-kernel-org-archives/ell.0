Content-Type: multipart/mixed; boundary="===============3331625217271271173=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] ecc: Add l_ecc_curve_get_scalar_bytes
Date: Tue, 22 Jan 2019 19:02:28 +0100
Message-ID: <20190122180229.12051-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3331625217271271173==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a function to return the number of bytes used by the *_from_data
and *_get_data methods.
---
 ell/ecc.c   | 9 ++++++++-
 ell/ecc.h   | 1 +
 ell/ell.sym | 6 ++++++
 3 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/ell/ecc.c b/ell/ecc.c
index dd2e11a..eeb12dd 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -123,6 +123,14 @@ LIB_EXPORT const char *l_ecc_curve_get_name(const stru=
ct l_ecc_curve *curve)
 	return curve->name;
 }
 =

+LIB_EXPORT size_t l_ecc_curve_get_scalar_bytes(const struct l_ecc_curve *c=
urve)
+{
+	if (unlikely(!curve))
+		return 0;
+
+	return curve->ndigits * 8;
+}
+
 LIB_EXPORT const struct l_ecc_curve *l_ecc_curve_get_ike_group(
 							unsigned int group)
 {
@@ -589,7 +597,6 @@ LIB_EXPORT struct l_ecc_scalar *l_ecc_scalar_new_random(
 }
 =

 LIB_EXPORT ssize_t l_ecc_scalar_get_data(const struct l_ecc_scalar *c,
-
 						void *buf, size_t len)
 {
 	if (len < c->curve->ndigits * 8)
diff --git a/ell/ecc.h b/ell/ecc.h
index e867ef9..26a5889 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -44,6 +44,7 @@ enum l_ecc_point_type {
 =

 const struct l_ecc_curve *l_ecc_curve_get(const char *name);
 const char *l_ecc_curve_get_name(const struct l_ecc_curve *curve);
+size_t l_ecc_curve_get_scalar_bytes(const struct l_ecc_curve *curve);
 const unsigned int *l_ecc_curve_get_supported_ike_groups(void);
 const unsigned int *l_ecc_curve_get_supported_tls_groups(void);
 const struct l_ecc_curve *l_ecc_curve_get_ike_group(unsigned int group);
diff --git a/ell/ell.sym b/ell/ell.sym
index 7643a25..828278b 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -460,7 +460,13 @@ global:
 	l_certchain_verify;
 	/* ecc */
 	l_ecc_curve_get;
+	l_ecc_curve_get_name;
+	l_ecc_curve_get_scalar_bytes;
 	l_ecc_curve_get_supported_groups;
+	l_ecc_curve_get_supported_ike_groups;
+	l_ecc_curve_get_supported_tls_groups;
+	l_ecc_curve_get_ike_group;
+	l_ecc_curve_get_tls_group;
 	l_ecc_curve_get_order;
 	l_ecc_curve_get_prime;
 	l_ecc_point_add;
-- =

2.19.1


--===============3331625217271271173==--

