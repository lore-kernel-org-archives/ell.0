Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 8C6621E534
	for <ell@lists.linux.dev>; Thu,  9 Nov 2023 14:21:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from fedora.. (p4fefc822.dip0.t-ipconnect.de [79.239.200.34])
	by mail.holtmann.org (Postfix) with ESMTPSA id A7E8CCECE9
	for <ell@lists.linux.dev>; Thu,  9 Nov 2023 15:20:58 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
To: ell@lists.linux.dev
Subject: [PATCH 3/3] ecc: Add helper for creating a scalar modulo curve order
Date: Thu,  9 Nov 2023 15:20:56 +0100
Message-ID: <20231109142056.12385-3-marcel@holtmann.org>
X-Mailer: git-send-email 2.41.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The SPAKE2+ key exchange protocol requires the ability have a scalar
modulo curve order. This adds a helper that allows to create a new
scalar and run modulo curver order on it. This is similar to the
helper that does the same with the curve prime value.
---
 ell/ecc.c   | 35 +++++++++++++++++++++++++++++++++++
 ell/ecc.h   |  2 ++
 ell/ell.sym |  1 +
 3 files changed, 38 insertions(+)

diff --git a/ell/ecc.c b/ell/ecc.c
index ff147b84ed74..2124856dfe99 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -846,6 +846,41 @@ LIB_EXPORT struct l_ecc_scalar *l_ecc_scalar_new_modp(
 	return NULL;
 }
 
+LIB_EXPORT struct l_ecc_scalar *l_ecc_scalar_new_modn(
+					const struct l_ecc_curve *curve,
+					const void *bytes, size_t len)
+{
+	struct l_ecc_scalar *c;
+	uint64_t tmp[2 * L_ECC_MAX_DIGITS];
+	unsigned int ndigits = len / 8;
+
+	if (!bytes)
+		return NULL;
+
+	if (len % 8)
+		return NULL;
+
+	if (ndigits > curve->ndigits * 2)
+		return NULL;
+
+	c = _ecc_constant_new(curve, NULL, 0);
+	if (!c)
+		return NULL;
+
+	memset(tmp, 0, sizeof(tmp));
+	_ecc_be2native(tmp, bytes, ndigits);
+
+	_vli_mmod_slow(c->c, tmp, curve->n, curve->ndigits);
+
+	if (!_vli_is_zero_or_one(c->c, curve->ndigits) &&
+			secure_memcmp_64(curve->n, c->c, curve->ndigits) > 0)
+		return c;
+
+	l_ecc_scalar_free(c);
+
+	return NULL;
+}
+
 /*
  * Takes a buffer of the same size as the curve and scales it to a range
  * 1..n using value = (value mod (n - 1)) + 1.  For the curves we support
diff --git a/ell/ecc.h b/ell/ecc.h
index de116f018b44..5a8cf0341acc 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -66,6 +66,8 @@ struct l_ecc_scalar *l_ecc_scalar_new_random(
 					const struct l_ecc_curve *curve);
 struct l_ecc_scalar *l_ecc_scalar_new_modp(const struct l_ecc_curve *curve,
 						const void *buf, size_t len);
+struct l_ecc_scalar *l_ecc_scalar_new_modn(const struct l_ecc_curve *curve,
+						const void *buf, size_t len);
 struct l_ecc_scalar *l_ecc_scalar_new_reduced_1_to_n(
 					const struct l_ecc_curve *curve,
 					const void *buf, size_t len);
diff --git a/ell/ell.sym b/ell/ell.sym
index 0f593e1fc402..a887b2b09520 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -608,6 +608,7 @@ global:
 	l_ecc_scalar_new;
 	l_ecc_scalar_new_random;
 	l_ecc_scalar_new_modp;
+	l_ecc_scalar_new_modn;
 	l_ecc_scalar_new_reduced_1_to_n;
 	l_ecc_scalar_sum_x;
 	l_ecc_scalars_are_equal;
-- 
2.41.0

