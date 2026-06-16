Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net [217.70.183.197])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C13FF3451C6
	for <ell@lists.linux.dev>; Tue, 16 Jun 2026 09:19:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.197
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781601596; cv=none; b=IrmpgXpOzyqrDhfPZwHMkjBKw5MQUszFaifocaIvrTNw5Pnywcz7VnpnInwHY/DUWd5eOfTMr0TRFqn736g/vRQpcV9MIUvLgQb30r/BDsLfsfmRdJ63yLuW4j61aemBMIzpwooAopBLnrOuUFUCbEIJRetuqMrsCbegELTAPXg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781601596; c=relaxed/simple;
	bh=vBrwJhK20hHAdkz8PBgQBW+sCtOJ0/0m+3e2M2Wnt4g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hN32DNFYl2bKkd5GihEH4Rd1H/kLcPR+icQCRm/TqgWpq9SKBWmzlPV4T5wb4kG3l0b4NR0gGgGtmbpKW+GISyC43gsOTuaPzq7q0lmMS2ragrN5AuM7FcKdVxZChsRJp1l/kY9paAP3SvMp/BDaZf6flXpsxDqICaJo2DPT9jA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.197
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id B438E3EBC2;
	Tue, 16 Jun 2026 09:19:46 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH 2/2] cert: Fix uninitialised variable
Date: Tue, 16 Jun 2026 11:19:30 +0200
Message-ID: <20260616091937.3628329-2-hadess@hadess.net>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260616091937.3628329-1-hadess@hadess.net>
References: <20260616091937.3628329-1-hadess@hadess.net>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-GND-Sasl: hadess@hadess.net
X-GND-Score: 0
X-GND-Cause: dmFkZTFGguJd1X/WcDjP/IpVKlTKJudX+KKpZLcrRq9HfTnFAyBMbfL3ic8H4JkR93fcKsVCIZc3bddR4W6CpEa4p4pFiJN1ILeEJ1MQpgZjGMP7y6orllXXLB9DLH/Ouz227tOcbQ6b0djMCMeORgsliuDAIHA1jApr111z5QaOVqf9TsyaCYhnnT0KaQg9Q671QmujuosnDvsH+Im9G/Z6ZxUFDFcTn0PcGZ2wEINFzA8AsDYAcob0lYcbQa5aTppSPylHbv9Iv7fsyfynOzCpmLN9SW6ThaEcndoHaRJ4cf9g5+hcdhC4KlLI7TaZpEvCRKFEnEBMG+gnECsBgCLveXrgqRaLphWtyf6vXycZOTnDA+cGuZQMi4zIC+qDE27Rac+OvF8gJtb2vfcVj2Q7JcMzrnOORiLylobMINaNNrgI/JNFiqiTwG58K1ga2+sFTv1i4nDVfyBF3m9TxYULQIVdXcqUdK/HhoZZ0lK0n4rOqTQ/1zvucKP4lbQHErH3rAGm+E1rxn55bjeUx0u9TXm++bgUxyfo5ZkqalM5lgUeZRrfzvDQ/3g6BC2b574C7N1lVLW/4L8G1e7iTMitnnvdLdRXAeohDR3H2a3r4hVI+Us2bPOTu77RLQN8tHSPoBqtAJ/EBDIQbT5/Qd8dznPnPtT2trunfTy6mgrbDUnaVA
X-GND-State: clean

In file included from ./ell/util.h:20,
                 from ell/private.h:8,
                 from ell/cert.c:18:
In function '_l_l_free_cleanup',
    inlined from 'cert_set_filter_by_validity' at ell/cert.c:618:33,
    inlined from 'l_certchain_verify' at ell/cert.c:729:20:
./ell/util.h:257:21: warning: 'valid' may be used uninitialized [-Wmaybe-uninitialized]
  257 | DEFINE_CLEANUP_FUNC(l_free);
ell/cert.c: In function 'l_certchain_verify':
ell/cert.c:618:40: note: 'valid' was declared here
  618 |         _auto_(l_free) struct l_cert **valid;
      |                                        ^~~~~
---
 ell/cert.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/cert.c b/ell/cert.c
index ac9bdb7ee9e2..ad0d91c5f073 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -615,7 +615,7 @@ static struct l_cert **cert_set_filter_by_validity(struct l_queue *set,
 							int *out_valid)
 {
 	const struct l_queue_entry *entry;
-	_auto_(l_free) struct l_cert **valid;
+	_auto_(l_free) struct l_cert **valid = NULL;
 
 	*out_total = l_queue_length(set);
 	*out_valid = 0;
-- 
2.54.0

