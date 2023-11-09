Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 6DDB71E535
	for <ell@lists.linux.dev>; Thu,  9 Nov 2023 14:21:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from fedora.. (p4fefc822.dip0.t-ipconnect.de [79.239.200.34])
	by mail.holtmann.org (Postfix) with ESMTPSA id 89AB8CECE8
	for <ell@lists.linux.dev>; Thu,  9 Nov 2023 15:20:58 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
To: ell@lists.linux.dev
Subject: [PATCH 2/3] ecc: Introduce _vli_mmod_slow that works with curve_p and curve_n
Date: Thu,  9 Nov 2023 15:20:55 +0100
Message-ID: <20231109142056.12385-2-marcel@holtmann.org>
X-Mailer: git-send-email 2.41.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/ecc-external.c | 75 ++++++++++++++++++++++++++++++++++++++++++++++
 ell/ecc-private.h  |  3 ++
 2 files changed, 78 insertions(+)

diff --git a/ell/ecc-external.c b/ell/ecc-external.c
index 46f710bff11b..7a0882326811 100644
--- a/ell/ecc-external.c
+++ b/ell/ecc-external.c
@@ -314,6 +314,81 @@ void _vli_mod_sub(uint64_t *result, const uint64_t *left,
 		_vli_add(result, result, mod, ndigits);
 }
 
+/* Counts the number of 64-bit "digits" in vli. */
+static unsigned int _vli_num_digits(const uint64_t *vli, unsigned int ndigits)
+{
+	int i;
+
+	/* Search from the end until we find a non-zero digit.
+	 * We do it in reverse because we expect that most digits will
+	 * be nonzero.
+	 */
+	for (i = ndigits - 1; i >= 0 && vli[i] == 0; i--);
+
+	return (i + 1);
+}
+
+/* Counts the number of bits required for vli. */
+static unsigned int _vli_num_bits(const uint64_t *vli, unsigned int ndigits)
+{
+	unsigned int i, num_digits;
+	uint64_t digit;
+
+	num_digits = _vli_num_digits(vli, ndigits);
+	if (num_digits == 0)
+		return 0;
+
+	digit = vli[num_digits - 1];
+	for (i = 0; digit; i++)
+		digit >>= 1;
+
+	return ((num_digits - 1) * 64 + i);
+}
+
+/* Computes result = product % mod, where product is 2N words long.
+ * Currently only designed to work for curve_p or curve_n.
+ */
+void _vli_mmod_slow(uint64_t *result, const uint64_t *product,
+				const uint64_t *mod, unsigned int ndigits)
+{
+	uint64_t mod_m[2 * L_ECC_MAX_DIGITS];
+	uint64_t tmp[2 * L_ECC_MAX_DIGITS];
+	uint64_t *v[2] = { tmp, (uint64_t *) product };
+	uint64_t carry = 0;
+	unsigned int i;
+	/* Shift mod so its highest set bit is at the maximum position. */
+	int shift = (ndigits * 2 * 64) - _vli_num_bits(mod, ndigits);
+	int word_shift = shift / 64;
+	int bit_shift = shift % 64;
+
+	vli_clear(mod_m, word_shift);
+	if (bit_shift > 0) {
+		for (i = 0; i < ndigits; ++i) {
+			mod_m[word_shift + i] = (mod[i] << bit_shift) | carry;
+			carry = mod[i] >> (64 - bit_shift);
+		}
+	} else
+		vli_set(mod_m + word_shift, mod, ndigits);
+
+	for (i = 1; shift >= 0; --shift) {
+		uint64_t borrow = 0;
+		unsigned int j;
+
+		for (j = 0; j < ndigits * 2; ++j) {
+			uint64_t diff = v[i][j] - mod_m[j] - borrow;
+
+			if (diff != v[i][j])
+				borrow = (diff > v[i][j]);
+			v[1 - i][j] = diff;
+		}
+		i = !(i ^ borrow); /* Swap the index if there was no borrow */
+		_vli_rshift1(mod_m, ndigits);
+		mod_m[ndigits - 1] |= mod_m[ndigits] << (64 - 1);
+		_vli_rshift1(mod_m + ndigits, ndigits);
+	}
+	vli_set(result, v[i], ndigits);
+}
+
 /* Computes p_result = p_product % curve_p.
  * See algorithm 5 and 6 from
  * http://www.isys.uni-klu.ac.at/PDF/2001-0126-MT.pdf
diff --git a/ell/ecc-private.h b/ell/ecc-private.h
index dcf676d9614a..de84bc64dc1b 100644
--- a/ell/ecc-private.h
+++ b/ell/ecc-private.h
@@ -86,6 +86,9 @@ void _vli_mod_add(uint64_t *result, const uint64_t *left, const uint64_t *right,
 
 void _vli_rshift1(uint64_t *vli, unsigned int ndigits);
 
+void _vli_mmod_slow(uint64_t *result, const uint64_t *product,
+				const uint64_t *mod, unsigned int ndigits);
+
 bool _vli_mmod_fast(uint64_t *result, const uint64_t *product,
 			const uint64_t *curve_prime, unsigned int ndigits);
 
-- 
2.41.0

