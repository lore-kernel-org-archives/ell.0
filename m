Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net [217.70.183.197])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB9A42F12A5
	for <ell@lists.linux.dev>; Tue, 16 Jun 2026 09:19:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.197
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781601595; cv=none; b=Pxp6jgkuTMnKTKhN8/R96oufjQPNAPPxivAN6cfB9JPrE47korYdESDblhObHXKs1h8AlWqFyIuFbywUYWF78I8gJZl881anErRmn9eEFYoMIuW6pA0vdSdQP1ZIpM/zBCkJSscw4k7MGbyGs8HNzO8xu4fZcxvVM4vtQxYjTv0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781601595; c=relaxed/simple;
	bh=S2akKUWJGE5D9zszWTPUZi2BItyE4jvck/tAm2d7fR4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ns5mQBLIMePf5a3h2J37BGJ7GH5tHEAvlBvvN6yCLcoIeGSk4uCNdrfeIJ+MbtiokOpYT3/ONb3bZSCxoB+cZoXZL18xR7e5tOoYEwp43Rgfd6PAj4jG9bFM5OPznhCeF7aRy1/zTr4AbzQT3dLisrrWvERW81oWok4/RYUO0k8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.197
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 562573EC1C;
	Tue, 16 Jun 2026 09:19:46 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH 1/2] settings: Fix uninitialised use
Date: Tue, 16 Jun 2026 11:19:29 +0200
Message-ID: <20260616091937.3628329-1-hadess@hadess.net>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-GND-Sasl: hadess@hadess.net
X-GND-Score: 0
X-GND-Cause: dmFkZTEx2wStsKqIzcUxDlXd1yVAR3S7Jtsx8E015a0qEC9eeWs6N2WwUikKUpdZVKxaU0XnCTDhPxp8fjYT34yWOc04vOeS8dRMeZZU9o68slOxyu+bZT4KobZE7FcdypPPaJV7FT54RKTaYcxZAQqX4kIf6wUcI9EAvj1eYNybZvwfhjaWLYq5UPEvlhp+ozbMAtMB6Zy3P/H+lcPP0w4vJt/PfG68cCkmNm87SOE5ro73QP3fW1d7TukFigulnTKIpa2EzKdATD04BFWV8Sta/Se2k0ZoP8uyWzv3h+c3bNM2quG31MCkmZN8t+4qEyf4eezZ3bWKe7g86IGOmlmACki7SNNepsQ/zBfVyOs2T89XV2g3+W+Vl25BxVckEnDL7HdPqrXfJS6RVeY753vHkzh8zcJ4cSO0NGAA4jaze8qO2Xu7JAMBKdsHilBUJ8RUGbkPIkF4SoSW0jPKeR1A8NfFoGQV6VPCAmtCL3IRw/MZy03a3PZ8ra/40jUutyvfqkg2t6H8jVobR7zSzdcbHTOpllnG3sO/L8kJ7p4EbEB1H1A/yZCjJ+CSjDgC2q4FQaG4CcyGoVO255tz2GJc0Oz/V2AcC75i0Ca0qDFQ5LqDChx4JVYM9k7U58XX+9WPwPuHQ0RDkcWv4LH4TLUJkMgD5BgtYbTGpOY8G63vqCV71Q
X-GND-State: clean

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
 ell/util.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/util.h b/ell/util.h
index e44ec69f8d97..69680e1f168e 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -236,7 +236,7 @@ static inline void l_put_be64(uint64_t val, void *ptr)
 }
 
 #define L_AUTO_FREE_VAR(vartype,varname) \
-	vartype varname __attribute__((cleanup(auto_free)))
+	vartype varname __attribute__((cleanup(auto_free))) = NULL
 
 #define L_ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 
-- 
2.54.0

