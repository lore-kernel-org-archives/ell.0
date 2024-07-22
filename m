Received: from mail-oo1-f50.google.com (mail-oo1-f50.google.com [209.85.161.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 388FB18030
	for <ell@lists.linux.dev>; Mon, 22 Jul 2024 19:04:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1721675088; cv=none; b=Q0E/28OeFYWm28igDO74fRfqTfd4wpzwAsPA+nXugxfH6OA4N8YpiooURafnCRJgY2Z6hIn6BoYrTIoxD69hFdFypY3VWRzZO4VE9faVrG2ze2SFGM/RKzcxTUo3ZnpZqK8Kgc7YcdSK+AyXhJIYC7XMM+mgEqoBMnyt5gylGzQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1721675088; c=relaxed/simple;
	bh=Z4jFBkz/sqQaJ0jaV769Swf3yzEUugsksMGiRoZ8hsM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=IrOcBkLj2I3LTrc9I6MpIKO1Na2F6hIFIMHY+4pJnlq79+pv/Lp7eAFSnqFGA/duudEMWDSiG6JX12HBXuaUz9tmxm05ihNlutwMtzqwEEKQIStSZQNDTA1Cdj0/fDftLPj8mQX7+ZUUj3Xe4Pw5ijMdyfy/nTLZX9HuUN+vsno=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=TwQ7Dqwc; arc=none smtp.client-ip=209.85.161.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TwQ7Dqwc"
Received: by mail-oo1-f50.google.com with SMTP id 006d021491bc7-5d5846f797aso404525eaf.0
        for <ell@lists.linux.dev>; Mon, 22 Jul 2024 12:04:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1721675086; x=1722279886; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=/3JMGqD0j4AtdgIadpyC8Tft9BzzxUUNEYDEsvlR9Zk=;
        b=TwQ7DqwcfFl9eSMOGfg3dXDto/FOywYzvP7w1kciNyuHgA4eWEfHJpQQCB6luGj2yk
         MrVUHpRl4y2xiaxeFMY8q/dp+2wjz5jnzRXHiC28whGOeUdV5RVihFNYmqJuMwmHsCyo
         LZ6WOSK6e6EYY0AUJhcYOw1B1HfFBs3w1y1+hcNFXM/T1EpwYFrVvRAXA5g5YkEEsHzG
         QOiCzgfVnxAL0VWqYqlldQcSF93+3htC2Om9K9mReFEkt+RKJVrbVnd1rkJVhAjYHKdj
         lm8NrzV3L76S7hHeIG2LKwalMWYSOEytBtbbnFGqwC/p46gZdVhZ360LgrMe5EdEC0NY
         ffGw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1721675086; x=1722279886;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=/3JMGqD0j4AtdgIadpyC8Tft9BzzxUUNEYDEsvlR9Zk=;
        b=MZDY9Wiw/8oTn3hMrBljHscwUlWzJSGPdJs9VzfRuxXGDlgn9QjGiIL4lzMn8POsvf
         1sq8mlVvwpI45QWoXOshGk8LhKjW7zfZ2aL6CJtjDyS780Da2gGrsaojkBAr9LvoPsZY
         yB4XgIjCM0wOO264pePX6Kr3X9aKdHJhQsIC2WV6Dd3fz7vkiLvkmxWrzlLw6hqaa/Ha
         TWiabpWcg6NvNHLuEaLXC7xedL8/LQhSXzZlklFnVJbYrEqdW92m2iAEUTlnbwhK0sT8
         NvVPfa8iPkmNxTk/q8hT0ZuTZXOaKfMoY+AL8P9ea+20Zdxsy9zbIU3WDiqyIEQ9yXtG
         CjYQ==
X-Gm-Message-State: AOJu0YxN02fk9L2arOR64CAJgNspEhBKTkb+dWR1ErhrTUwAqjHapK3i
	AgDjgtOX1CGMyVlMss4/1ElaZQWnVSqcKmbYD+QzmIeODNajilxjgu66Rw==
X-Google-Smtp-Source: AGHT+IGLzyflDBK6IPdKxvnFh75CSvRbUIPT5XHXdfGOxCfvWTMDpqE8PqlMXyCF4Ait6jtxBw0SbA==
X-Received: by 2002:a05:6820:4c04:b0:5cc:a794:9ea7 with SMTP id 006d021491bc7-5d58b807b66mr1175897eaf.7.1721675086064;
        Mon, 22 Jul 2024 12:04:46 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5d55aaee1fasm1411186eaf.42.2024.07.22.12.04.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 22 Jul 2024 12:04:45 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 01/12] useful: Add utility to find the next power of two
Date: Mon, 22 Jul 2024 14:04:18 -0500
Message-ID: <20240722190443.43196-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/useful.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/ell/useful.h b/ell/useful.h
index 7bb924bcab8c..504ea089cb21 100644
--- a/ell/useful.h
+++ b/ell/useful.h
@@ -52,6 +52,12 @@ static inline unsigned char bit_field(const unsigned char oct,
 	return (oct >> start) & mask;
 }
 
+/* Must be called with n >= 2 and n <= ULONG_MAX / 2 + 1 */
+static inline unsigned long roundup_pow_of_two(unsigned long n)
+{
+	return 1UL << (sizeof(unsigned long) * 8 - __builtin_clzl(n - 1));
+}
+
 #define DIV_ROUND_CLOSEST(x, divisor)			\
 ({							\
 	typeof(divisor) _d = (divisor);			\
-- 
2.45.2

