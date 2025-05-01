Received: from mail-pg1-f172.google.com (mail-pg1-f172.google.com [209.85.215.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F3CF912E7E
	for <ell@lists.linux.dev>; Thu,  1 May 2025 01:15:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1746062121; cv=none; b=gQxKHtSqjZPxAYUG2dTdnbHDiX1mmUfioQWXaoIsB+ZI1CfnFw3x05Uomt1atNrv3EddbgDU6VIdSWCuHg2ykHGDEBpJDdApy/t+DU96NaQ0ZRkTNyXPuoFdu4PAKEx/UrB2P0MNmk7CgVVsFF1BruUhcXNc0eBJgwnAskNuhLI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1746062121; c=relaxed/simple;
	bh=DR304Bq+MiRq5iBtQUZdhtaPgn/yQm6vXpaFxThCMMU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Uv6/inAH02GSFr531jCci7bkm8e1+Ou7LFsFrV5pz3wZfrLqfM3ojReviJ6nxm0zdieB+xH51ksjrXTt6IETkXV6fZBP3C/8ncjCApv/aApKHWnRWNhETsH5FyOnVHGnqdVJnjuqHezFmCPUlmwK7ZedsYPEkFXPqP/+5h2+b9Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nigauri.org; spf=none smtp.mailfrom=nigauri.org; dkim=pass (2048-bit key) header.d=nigauri-org.20230601.gappssmtp.com header.i=@nigauri-org.20230601.gappssmtp.com header.b=hlzQIcUx; arc=none smtp.client-ip=209.85.215.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nigauri.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=nigauri.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nigauri-org.20230601.gappssmtp.com header.i=@nigauri-org.20230601.gappssmtp.com header.b="hlzQIcUx"
Received: by mail-pg1-f172.google.com with SMTP id 41be03b00d2f7-7fd581c2bf4so388066a12.3
        for <ell@lists.linux.dev>; Wed, 30 Apr 2025 18:15:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nigauri-org.20230601.gappssmtp.com; s=20230601; t=1746062119; x=1746666919; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=o7jAEY/MH26z8XU4vygWa8EhMbHQwJKMnmBTCSsA7+o=;
        b=hlzQIcUx6kkrLvDSO1JhnBDFy6SVLzmcZNt6TZ4G1crRnribq1jj+L/mXE+oMW1Bqz
         NAYfz/rCK14aK5XD/r6d4MSBJCONhmwuDIcpEe2KsZ5Hxuvju9P91YbO/2LX7pvvbUYv
         Gsht6t0cZ7qO3h2R0CQqDQvVHrg41jFsQlWxmuwUUQlUSvTY+x2ZcuLhTntmID4uFIvZ
         5s3UiSDnKiJLL301uQzSm1KxpQltqIsPRQYJ0rkjMFFeUa+3aR7/8z1BfLjCSf+uTKxj
         T27URNW97OHT1vtv7bH7hqSzk1bk3YabpJ5kXjQvK6+Mw2k+yeyjZAEw/CCjKMzJygZu
         BsTQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1746062119; x=1746666919;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=o7jAEY/MH26z8XU4vygWa8EhMbHQwJKMnmBTCSsA7+o=;
        b=btzQ5KEtWRzlHCspwYfLPDtHMuVNsHpXNY+a1TTB4ThT/GonP5vu1rcWoHuCEeQZOQ
         IZuXFC7rPMdL0jCdAzn4B/t6wke5PlopH+LTJEZaPyvlw41WdHcuMdVVzJvT5a9Q9TF1
         xhUyQZ9n7AIhuCUsZtvoaUns9m0ZjXeOwxaiVMdZXV6JVlw3OUn//OrHemtQStMsUCST
         lDZsL92Ce9EGsGu5igdUWmX67orMeUSWHATYWtNl1hnoRdyuXA3XqaEoy9+lfmAK8St3
         SidO8Oq+TJJqwbKjYjx5pqZ0uykbTp3XtndnCBi7renQxFTd/kn2ld7p8HDNxjeEkFgh
         1HTA==
X-Gm-Message-State: AOJu0Yxtuxu1cmBawJEJHb7kdBSM6tkF1HxEa+b0JIeRnQZTBI22Cic2
	emKLA33mht4EkMLqHCwP1OySep+0hNMuwETlF6sZintkfazdX9efTEY+ljwnE0tUURaNRfE5TA=
	=
X-Gm-Gg: ASbGncvU/ppQRjysyUXeJ88WaGj2Fbzb6G0rC+bYRhcUpiMT56nU1aVnA4UGwHzkvFL
	c/eDoG0C5ZfRX1UpoB4j8gkxBSVWYgBDE+jjcf/aAVdkzAfe1yRIX3WffgfhyeOyOCDbO60V9+7
	mfz00FeHJSJQ+lqtjSzgtidw2Io6ALt4jdKETZazDj/hSCKIRYjZCnDo7NLoLTnMn1p8EsjRn7q
	g+vXk9UbEx3+CTlhkFn6BA5iiLj4h2iE+B8hHuuvnpkdCBjjblDpQlpS5rzybILwZmGSeIsCou1
	FPLHEBCErfmqI4vtjJZtONcpj+SYNW2+82VmJ0eya+DOZwJXtOPcRu+esdgupshy4wvRDxdMtw=
	=
X-Google-Smtp-Source: AGHT+IHk4wGAtMygqviIkbLT4puUUhCLWCenvz2vPvQhM//dkWTghXvYcvXpwAEz+qY6l47YkJQsBQ==
X-Received: by 2002:a17:90b:5206:b0:2ee:ee5e:42fb with SMTP id 98e67ed59e1d1-30a41d1a9eamr1370179a91.13.1746062118853;
        Wed, 30 Apr 2025 18:15:18 -0700 (PDT)
Received: from localhost (ae053227.dynamic.ppp.asahi-net.or.jp. [14.3.53.227])
        by smtp.gmail.com with UTF8SMTPSA id d9443c01a7336-22db50e7b45sm128976275ad.135.2025.04.30.18.15.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 30 Apr 2025 18:15:18 -0700 (PDT)
From: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
To: ell@lists.linux.dev
Cc: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
Subject: [PATCH] Add License variable to pkg-config file
Date: Thu,  1 May 2025 10:15:08 +0900
Message-ID: <20250501011508.3917337-1-iwamatsu@nigauri.org>
X-Mailer: git-send-email 2.49.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The pkg-config file has License variable that allows you to set the license for
the software. This sets 'LGPL-2.1-or-later' as defined in SPDX to License.

---
 ell/ell.pc.in | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/ell.pc.in b/ell/ell.pc.in
index 414ea75..35edb68 100644
--- a/ell/ell.pc.in
+++ b/ell/ell.pc.in
@@ -8,3 +8,4 @@ Description: Embedded Linux library
 Version: @VERSION@
 Libs: -L${libdir} -lell
 Cflags: -I${includedir}
+License: LGPL-2.1-or-later
-- 
2.49.0

