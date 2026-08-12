Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net [217.70.183.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99AEC2E06D2
	for <ell@lists.linux.dev>; Wed, 12 Aug 2026 09:12:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.198
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786525938; cv=none; b=OgdfQjZ2jYKA/ToejOAxEGlGKn2z44KCERLhtDpNpnFqHYRKQ3DtvfoGFFVQP0HWt82laKM1AYUxt00UrTD8ghyws/Iia6OFXgFuglhDNa9so5d7/RKh1ZUNtfNzqEGLwGtRkzVvI1gUM82AOyOwM3d7h3O72gYAkdzmG62hioA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786525938; c=relaxed/simple;
	bh=HoL85+MEpVa4v7uT0dItSJIjQHXFzMYlJoo0UcPIBd0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CABVpKmN9FJacowNWcNMM0Jf5AXukNGbXhQnqMDrc3ByPRxabzxBliaRSqy6ac6yFLU5YvYz+cgD+9H9lXifZ3KVk9v63ig++77iPS6OFxMo7zG05vT5OjMQR+wy3iMhsu3KUCkORugNsE5zXcfN43Vl0B+6KrFdUO7CoaTOD50=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.198
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 71B773EBC5;
	Wed, 12 Aug 2026 09:12:07 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH v2 2/2] cert: Fix uninitialised variable
Date: Wed, 12 Aug 2026 11:11:21 +0200
Message-ID: <20260812091158.2134810-2-hadess@hadess.net>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260812091158.2134810-1-hadess@hadess.net>
References: <20260812091158.2134810-1-hadess@hadess.net>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-GND-Sasl: hadess@hadess.net
X-GND-State: clean
X-GND-Score: 0
X-GND-Cause: dmFkZTFRht4WBBujPSPVkye79OvjlNN//NaoyhQbIk4AC9s40Hpmt1q7xGKjwu3EzGVQ59kw13swsSJ/bs5Y5VHL/UYal6av0+rOIT/MI4avcZVudsZPzIrgKCL9r6EKX/ETWlpMKymz5bEKVhRjaQzXB6JZeCKa6m36/zUEWzeHLOgg2OApojKNz3qGInrd4/uKadQDFmvveYIZwO15qqMqMNScyh6Beb029YVXhBZPm0E/hG7WCuWOZY+wLGZfibmcq8XgO425sOdgpVJtyQiHnmKXSXw9Ed/jyjeYxgi5c+WdvaIeA20EcTknLY4n2qb8GWMGMK7d1iLul8zJI/GJ8fHEZGIToS68JHvvai5UuQ1H2v3T9exf7s5BNCVLihCChFGLStfNlwUGOvAjq8Q4HJekdu3LHmb/YA3w6LQny600cjJAL+8HjF94WNq7lnzt2oEx9a8rmLPrc5znHX9Y1Vp83RKPNVio4J9Get2YdcVXZ0Kci/48umY+jzoHFn8uuWdhM32j4ExGKmZLsTZnN/i3VIVb5ii8zuui/OWsFofT8wicZeu9EpAdx3eGabXE0DouqbXsr/GDJuJWGa0R9Xw7gesHxhR3xXCVG7Cfdnr+FoEvvfQddiY4SNJolH8W3WoGjgRiII5rwIAPkJHP8nPOXJe6a1IMJ0s33XsynschBw

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
Changes since v1:
- None

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
2.55.0

