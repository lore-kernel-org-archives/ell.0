Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A810B3E6DC6
	for <ell@lists.linux.dev>; Tue, 17 Mar 2026 14:30:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.196
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773757837; cv=none; b=FL0LVUdvTcrRmDXqrRSxK52l/GVcyotxJm06qZmiwJywJDMLRS03vVtffWH3kuuxkddjJtZ0QJ97IgtI7msqcLfZVgJCoaCB5HhPRH/CJpwA5JMrmo4g2VP2q5ZEkhAzpUgfmgPkJkO9a20aUsZhW/AM/joRDcVALUwLjQAOMJo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773757837; c=relaxed/simple;
	bh=5/7E+oyn9VqmY3lUa4qrjABIF+YFpmBb7yo+sQsYCFM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=HDTz44oNN3JQ/bGEDeMVLzjSsSYKDkxGagAPbmIPunPsmzL2vE+xCJ0Pyp8E5t+FqgFAuFYREHNKRJXiXcYz24TvLnNF6YQcDnW7cM0F1THk+JdkEwS+90sPW88lVUee6Cy8kmSJXiU+PQ/ZRzcNkd1brQlrBst9TANJitD+2mY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.196
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 45A8F3EE17;
	Tue, 17 Mar 2026 14:30:27 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH 2/4] ell: Fix rawmemchr implementation warning in Alpine/clang
Date: Tue, 17 Mar 2026 15:28:55 +0100
Message-ID: <20260317143018.628844-3-hadess@hadess.net>
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
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgdeftddugeelucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgjfhgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepveethfelveejffetkeelheehueejlefhvdehteehgfeghfekgfdvfefhgeekieetnecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfedphhgvlhhopeholhhimhhpihgtpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpqhhiugepgeehteekhfefgffgudejpdhmohguvgepshhmthhpohhuthdpnhgspghrtghpthhtohepvddprhgtphhtthhopegvlhhlsehlihhsthhsrdhlihhnuhigrdguvghvpdhrtghpthhtohephhgruggvshhssehhrgguvghsshdrnhgvth

rawmemchr() is not available under Alpine, it's a glibc function, which
means our local implementation is used. That implementation tried to
disable GCC specific warnings which aren't available under clang, so
disable the pragma statements to disable the warnings when run under
clang.

In file included from ../ell/random.c:20:
../ell/missing.h:61:1: warning: unknown warning group '-Wstringop-overflow=', ignored [-Wunknown-warning-option]
   61 | _Pragma("GCC diagnostic ignored \"-Wstringop-overflow=\"")
      | ^
<scratch space>:20:25: note: expanded from here
   20 |  GCC diagnostic ignored "-Wstringop-overflow="
      |                         ^
1 warning generated.
[repeated many times]
---
 ell/missing.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ell/missing.h b/ell/missing.h
index b1ee0f147538..5b4f31675361 100644
--- a/ell/missing.h
+++ b/ell/missing.h
@@ -56,9 +56,13 @@ static inline void explicit_bzero(void *s, size_t n)
 #ifndef HAVE_RAWMEMCHR
 static inline void *rawmemchr(const void *s, int c)
 {
+#if defined(__GNUC__) && !defined(__clang__)
 _Pragma("GCC diagnostic push")
 _Pragma("GCC diagnostic ignored \"-Wstringop-overflow=\"")
+#endif /* gcc && !clang */
 	return memchr(s, c, PTRDIFF_MAX);
+#if defined(__GNUC__) && !defined(__clang__)
 _Pragma("GCC diagnostic pop")
+#endif /* gcc && !clang */
 }
 #endif
-- 
2.53.0

