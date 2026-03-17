Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A7FDD3E63BC
	for <ell@lists.linux.dev>; Tue, 17 Mar 2026 14:30:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.196
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773757836; cv=none; b=uGmLkEFOJkk+7C+d0J2MTtd0K6wEJhncq0U3XHCVpRMNNB9n0H0D7Amzq4qn3QQdlb+9GvNIY/WrlNbXEPa0YZB61d2MXbDa0GfYa/Ir5LMjNaZLTSvrCo0Tv9DnJouU+wkpKvRkQnKzlxtqAbOEVmbPqgEKeYWu5wJJCLCmPvI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773757836; c=relaxed/simple;
	bh=wXx4jXDLlI5a9IxuDJy+hEXL/uUfjSunMR09pediPeg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=HMqtRsS4VfWDaxnp2h+oqIa5bxx94bpPdArqRhn7MGQphAbH7RoUJPZvEV2ESYR5wJfBgJJqLNEciY3xtpeSelShaCQ30QfFLcdf4eVE/EZxhqHMqT1HLnK+5RdDBHzTc0y7XIC7Sa7AvtGxEcCyzLrENii12Dzcc7soJTgbCGY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.196
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 9018C3EE1D;
	Tue, 17 Mar 2026 14:30:27 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH 3/4] ell: Fix cert_pkcs12_pbkdf() warning under Alpine/clang
Date: Tue, 17 Mar 2026 15:28:56 +0100
Message-ID: <20260317143018.628844-4-hadess@hadess.net>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260317143018.628844-1-hadess@hadess.net>
References: <20260317143018.628844-1-hadess@hadess.net>
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
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgdeftddugeelucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgjfhgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepveethfelveejffetkeelheehueejlefhvdehteehgfeghfekgfdvfefhgeekieetnecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfedphhgvlhhopeholhhimhhpihgtpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpqhhiugepledtudekveefgffgudffpdhmohguvgepshhmthhpohhuthdpnhgspghrtghpthhtohepvddprhgtphhtthhopegvlhhlsehlihhsthhsrdhlihhnuhigrdguvghvpdhrtghpthhtohephhgruggvshhssehhrgguvghsshdrnhgvth

Disable GCC specific warning under clang.

../ell/cert-crypto.c:235:1: warning: unknown warning group '-Wmaybe-uninitialized', ignored [-Wunknown-warning-option]
  235 | _Pragma("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
      | ^
<scratch space>:28:25: note: expanded from here
   28 |  GCC diagnostic ignored "-Wmaybe-uninitialized"
      |                         ^
1 warning generated.
../ell/cert-crypto.c:235:1: warning: unknown warning group '-Wmaybe-uninitialized', ignored [-Wunknown-warning-option]
  235 | _Pragma("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
      | ^
<scratch space>:28:25: note: expanded from here
   28 |  GCC diagnostic ignored "-Wmaybe-uninitialized"
      |                         ^
1 warning generated.
---
 ell/cert-crypto.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ell/cert-crypto.c b/ell/cert-crypto.c
index d6babe007d1c..de416050bfb5 100644
--- a/ell/cert-crypto.c
+++ b/ell/cert-crypto.c
@@ -231,8 +231,10 @@ uint8_t *cert_pkcs12_pbkdf(const char *password,
 		ptr += s_len + salt_len - j;
 	}
 
+#if defined(__GNUC__) && !defined(__clang__)
 _Pragma("GCC diagnostic push")
 _Pragma("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
+#endif /* gcc && !clang */
 	if (p_len) {
 		for (j = passwd_len; j < p_len;
 					j += passwd_len, ptr += passwd_len)
@@ -243,7 +245,9 @@ _Pragma("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
 		explicit_bzero(bmpstring, passwd_len);
 		l_free(bmpstring);
 	}
+#if defined(__GNUC__) && !defined(__clang__)
 _Pragma("GCC diagnostic pop")
+#endif /* gcc && !clang */
 
 	key = l_malloc(key_len + hash->len);
 
-- 
2.53.0

