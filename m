Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 6DD571E522
	for <ell@lists.linux.dev>; Thu,  9 Nov 2023 14:21:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from fedora.. (p4fefc822.dip0.t-ipconnect.de [79.239.200.34])
	by mail.holtmann.org (Postfix) with ESMTPSA id 67842CECE3
	for <ell@lists.linux.dev>; Thu,  9 Nov 2023 15:20:58 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
To: ell@lists.linux.dev
Subject: [PATCH 1/3] ecc: Make product variable of _vli_mmod_fast const
Date: Thu,  9 Nov 2023 15:20:54 +0100
Message-ID: <20231109142056.12385-1-marcel@holtmann.org>
X-Mailer: git-send-email 2.41.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/ecc-external.c | 2 +-
 ell/ecc-private.h  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/ecc-external.c b/ell/ecc-external.c
index a851271df26e..46f710bff11b 100644
--- a/ell/ecc-external.c
+++ b/ell/ecc-external.c
@@ -550,7 +550,7 @@ static void vli_mmod_fast_384(uint64_t *result, const uint64_t *product,
 /* Computes result = product % curve_prime
  *  from http://www.nsa.gov/ia/_files/nist-routines.pdf
 */
-bool _vli_mmod_fast(uint64_t *result, uint64_t *product,
+bool _vli_mmod_fast(uint64_t *result, const uint64_t *product,
 			const uint64_t *curve_prime, unsigned int ndigits)
 {
 	uint64_t tmp[2 * L_ECC_MAX_DIGITS];
diff --git a/ell/ecc-private.h b/ell/ecc-private.h
index 880ae800e8d8..dcf676d9614a 100644
--- a/ell/ecc-private.h
+++ b/ell/ecc-private.h
@@ -86,7 +86,7 @@ void _vli_mod_add(uint64_t *result, const uint64_t *left, const uint64_t *right,
 
 void _vli_rshift1(uint64_t *vli, unsigned int ndigits);
 
-bool _vli_mmod_fast(uint64_t *result, uint64_t *product,
+bool _vli_mmod_fast(uint64_t *result, const uint64_t *product,
 			const uint64_t *curve_prime, unsigned int ndigits);
 
 void _vli_mod_mult_fast(uint64_t *result, const uint64_t *left,
-- 
2.41.0

