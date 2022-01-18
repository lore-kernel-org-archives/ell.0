Content-Type: multipart/mixed; boundary="===============3658401027934347484=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH] ecc: add l_ecc_point_y_isodd
Date: Tue, 18 Jan 2022 08:56:05 -0800
Message-ID: <20220118165605.1968201-1-prestwoj@gmail.com>

--===============3658401027934347484==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This is required to know how a compressed point will be interpreted
after sending the raw (compressed) X coordiate.
---
 ell/ecc.c   | 5 +++++
 ell/ecc.h   | 1 +
 ell/ell.sym | 1 +
 3 files changed, 7 insertions(+)

diff --git a/ell/ecc.c b/ell/ecc.c
index 5830e01..c934da0 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -735,6 +735,11 @@ LIB_EXPORT ssize_t l_ecc_point_get_y(const struct l_ec=
c_point *p, void *y,
 	return p->curve->ndigits * 8;
 }
 =

+LIB_EXPORT bool l_ecc_point_y_isodd(const struct l_ecc_point *p)
+{
+	return p->y[0] & 1;
+}
+
 LIB_EXPORT ssize_t l_ecc_point_get_data(const struct l_ecc_point *p, void =
*buf,
 					size_t len)
 {
diff --git a/ell/ecc.h b/ell/ecc.h
index 84a16c2..0bddd0e 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -69,6 +69,7 @@ struct l_ecc_point *l_ecc_point_clone(const struct l_ecc_=
point *p);
 const struct l_ecc_curve *l_ecc_point_get_curve(const struct l_ecc_point *=
p);
 ssize_t l_ecc_point_get_x(const struct l_ecc_point *p, void *x, size_t xle=
n);
 ssize_t l_ecc_point_get_y(const struct l_ecc_point *p, void *y, size_t yle=
n);
+bool l_ecc_point_y_isodd(const struct l_ecc_point *p);
 =

 ssize_t l_ecc_point_get_data(const struct l_ecc_point *p, void *buf, size_=
t len);
 void l_ecc_point_free(struct l_ecc_point *p);
diff --git a/ell/ell.sym b/ell/ell.sym
index 51db458..a65ee6d 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -572,6 +572,7 @@ global:
 	l_ecc_point_from_data;
 	l_ecc_point_get_x;
 	l_ecc_point_get_y;
+	l_ecc_point_y_isodd;
 	l_ecc_point_get_data;
 	l_ecc_point_inverse;
 	l_ecc_point_multiply;
-- =

2.31.1

--===============3658401027934347484==--

