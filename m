Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net [217.70.183.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99B7D3624AE
	for <ell@lists.linux.dev>; Wed, 12 Aug 2026 09:12:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.198
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786525936; cv=none; b=p8JxFgskz39jO8yfF/ugw4V8Tj8PGWRDKUiP+lD3MDE9/h+dYhsm00bPsUk8U0fkqJ6gGL9ZQbm3z1HG5e5wWshUJpX5GP6aGP9tb7fps79vltHhMTVPrW0m4B2yzTsrOH5NtMXvZsHaomXjd3K8M7mFpT1Ka8LEv/mhQ7QjlQM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786525936; c=relaxed/simple;
	bh=QpWcfaKmF3WV58cDSiEnRCPTQ9E/+cttkznqc7+Y5rc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=jINKglmfRs/QjNFmZqZesNl7K3D7hqBDt2vOeVfkKI5QAj2oNlBAKq0HzQp+Pm8Dkl/gWQqciExdzzoxfrn/BujMyyd5twB25dVmy4LhUi7q4rHHWZWBTC6wY+NKxIniO4Del0x3wGbNvvpDsTIw8fXIqB8E/CvPapi79PITTt0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.198
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 2019F3EB8E;
	Wed, 12 Aug 2026 09:12:07 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH v2 1/2] settings: Fix uninitialised use
Date: Wed, 12 Aug 2026 11:11:20 +0200
Message-ID: <20260812091158.2134810-1-hadess@hadess.net>
X-Mailer: git-send-email 2.55.0
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
X-GND-Cause: dmFkZTGjyYnFldSx0anmcRSlmRYS9fyJLhOLdl920mIzQPFcIhGoZI64w/f3IP2wWDQUASX7r5ToyokAgvSBqOCPcY8kxNS6CUXKeboz5hEiDgzrkyictDP9pTljPgdprlMECMkODkdLPDb0+FgdWWe5DEGLsZz7nrY5adrvgmYJXGsph19diSJCQgqxI+UhCtJaV+EogBpBNm6gVZroerUf4WJJ6NHw4uWDalbeSGVSadvBifL9GyoR7JMZZ0sMiet4FDhEhV4DZi2ivcdinHVMZbN7yInl7W+GCzZ3eLlWrPzW1HFaBpkq0SaYCIl/fLmxWjm4CoEB9ZPp+d1BfKExQEY5tPc+33zLBaUiJdbAo/+UCVqAtoZW6xCuHpWbNlsxkNPFvnegT7hh3mZnASb5up4UGeXdXddQHGAw7YWrCQ93FTNu+/P+XUgWOo+sSbOc+PtIuAgjqLouJv8vgYnRwMzsQQSNiVtf4rmO3C7AtQPT8znxU2c0mTMvza+L7VzBjoqh0vwAQLxPOyINK9f2rvW3xI2M4dnPQPMEJMqfDMT/4f2RAd3612KxqHQtE9cHUNTLDZCT8tHKzcZUJ/Vv323Hs0TL06mjkB/WUFW3h/aOg4XGZ9bi18QN4KmateFD0YbZTBtA34r265sNojD/+4858629jIqIbC/GE+oTP2ghcg

__attribute__(cleanup) variables need to be initialised in situ.

In file included from ell/private.h:8,
                 from ell/settings.c:36:
In function 'auto_free',
    inlined from 'l_settings_set_double' at ell/settings.c:1335:2:
./ell/util.h:265:9: warning: 'buf' may be used uninitialized [-Wmaybe-uninitialized]
  265 |         l_free(*p);
      |         ^~~~~~~~~~
ell/settings.c: In function 'l_settings_set_double':
ell/settings.c:1335:33: note: 'buf' was declared here
 1335 |         L_AUTO_FREE_VAR(char *, buf);
      |                                 ^~~
In function 'auto_free',
    inlined from 'l_settings_set_float' at ell/settings.c:1381:2:
./ell/util.h:265:9: warning: 'buf' may be used uninitialized [-Wmaybe-uninitialized]
  265 |         l_free(*p);
      |         ^~~~~~~~~~
ell/settings.c: In function 'l_settings_set_float':
ell/settings.c:1381:33: note: 'buf' was declared here
 1381 |         L_AUTO_FREE_VAR(char *, buf);
      |                                 ^~~
---
Changes since v1:
- Fix the fix to note create more warnings

 ell/settings.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/settings.c b/ell/settings.c
index b46d00bd2899..01307ba72b87 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -1332,7 +1332,7 @@ LIB_EXPORT bool l_settings_set_double(struct l_settings *settings,
 					const char *group_name, const char *key,
 					double in)
 {
-	L_AUTO_FREE_VAR(char *, buf);
+	L_AUTO_FREE_VAR(char *, buf) = NULL;
 
 	buf = l_strdup_printf("%f", in);
 
@@ -1378,7 +1378,7 @@ LIB_EXPORT bool l_settings_set_float(struct l_settings *settings,
 					const char *group_name, const char *key,
 					float in)
 {
-	L_AUTO_FREE_VAR(char *, buf);
+	L_AUTO_FREE_VAR(char *, buf) = NULL;
 
 	buf = l_strdup_printf("%f", (double)in);
 
-- 
2.55.0

