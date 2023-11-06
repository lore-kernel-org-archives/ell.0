Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id A4B7C33E5
	for <ell@lists.linux.dev>; Mon,  6 Nov 2023 19:14:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from fedora.. (p4ff9f475.dip0.t-ipconnect.de [79.249.244.117])
	by mail.holtmann.org (Postfix) with ESMTPSA id 7A363CECDA
	for <ell@lists.linux.dev>; Mon,  6 Nov 2023 20:06:41 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
To: ell@lists.linux.dev
Subject: [PATCH] ecc: Add helper for multiplying a scalar with a curve generator
Date: Mon,  6 Nov 2023 20:06:38 +0100
Message-ID: <20231106190638.296812-1-marcel@holtmann.org>
X-Mailer: git-send-email 2.41.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The SPAKE2+ key exchange protocol requires the ability to multiply a
random number with the curve generator. Instead of exposing the curve
generator expose a helper function that provides the multiplication.
---
 ell/ecc.c   | 12 ++++++++++++
 ell/ecc.h   |  2 ++
 ell/ell.sym |  1 +
 3 files changed, 15 insertions(+)

diff --git a/ell/ecc.c b/ell/ecc.c
index 59bff7bd5af1..ff147b84ed74 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -940,6 +940,18 @@ LIB_EXPORT bool l_ecc_point_multiply(struct l_ecc_point *ret,
 	return true;
 }
 
+LIB_EXPORT bool l_ecc_point_multiply_g(struct l_ecc_point *ret,
+					const struct l_ecc_scalar *scalar)
+{
+	if (unlikely(!ret || !scalar))
+		return false;
+
+	_ecc_point_mult(ret, &scalar->curve->g, scalar->c, NULL,
+						scalar->curve->p);
+
+	return true;
+}
+
 LIB_EXPORT bool l_ecc_point_add(struct l_ecc_point *ret,
 					const struct l_ecc_point *a,
 					const struct l_ecc_point *b)
diff --git a/ell/ecc.h b/ell/ecc.h
index 2f6faa4e79cd..de116f018b44 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -83,6 +83,8 @@ bool l_ecc_scalar_add(struct l_ecc_scalar *ret, const struct l_ecc_scalar *a,
 bool l_ecc_point_multiply(struct l_ecc_point *ret,
 				const struct l_ecc_scalar *scalar,
 				const struct l_ecc_point *point);
+bool l_ecc_point_multiply_g(struct l_ecc_point *ret,
+				const struct l_ecc_scalar *scalar);
 bool l_ecc_point_add(struct l_ecc_point *ret, const struct l_ecc_point *a,
 				const struct l_ecc_point *b);
 bool l_ecc_point_inverse(struct l_ecc_point *p);
diff --git a/ell/ell.sym b/ell/ell.sym
index c457a7620376..0f593e1fc402 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -593,6 +593,7 @@ global:
 	l_ecc_point_get_data;
 	l_ecc_point_inverse;
 	l_ecc_point_multiply;
+	l_ecc_point_multiply_g;
 	l_ecc_point_new;
 	l_ecc_point_from_sswu;
 	l_ecc_point_clone;
-- 
2.41.0

