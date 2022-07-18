Received: from mail-oa1-f48.google.com (mail-oa1-f48.google.com [209.85.160.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6ED1E323C
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 16:08:40 +0000 (UTC)
Received: by mail-oa1-f48.google.com with SMTP id 586e51a60fabf-10bec750eedso24924882fac.8
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 09:08:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Jj8SzOc4fPGKTCmDSCizZ0kMBR+BMY1DeLBui51Bxng=;
        b=FgeMsxcF/NL0f3iRNSK8TDxim38FYOYlA3VZpGmIPJejpTaF8q9UOy5W0hZZVEZNCc
         wl8R8IEOGN5EmmEo1rZg6JPJNcTLz/wevwLeYidSD3ZjRZJPHIPkmUPGIklO4xAKdliL
         VkiiQSNo7RqCG4J1jjkNV9DyONhsTKNk1DPPWYmaIqVQ4P9TzsuWoqxiVwkDL9PFnCXa
         zblbb4chGI/hjAvkATqL5f0El9AgATwnS8uumfzwq6fLNF+EaUN7zzdqq/iqnY/6Z5tk
         2wLn+ZMPhFkytL+Jo8IbdcQhoqmLNB5p6yWpWcGOZE/UE3H4ULnQ+hjLB1b0zuz+yGPa
         fxog==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Jj8SzOc4fPGKTCmDSCizZ0kMBR+BMY1DeLBui51Bxng=;
        b=CW8nrBFDsM0x8/j1Yj4jr3isUlHAEJ+JkJIyhSDeS0NDiwEc0lgCs0txh9jrbcY+pj
         34IWL/K6IIivL0xSvts3NvSW/OCHdy49NhSjpv/wZBmZMmE+gFSjHCjd+eY33ZXVYh/z
         KTLkvUfQde9fSe4HVsYFnz88otd1MaxvXtP64/leL0GDksy3TPHl1A0nCqDseTmOdb+w
         57wtVPmat7/Zrxhak0LzWvP7E5erWe3kpKG9dsM0Wj8YsYqKWYG1PoPytFzovV74HNm/
         5W4M6dWQZrjePpkC9ZzxJGS3yxG1dEuteN5dVYhzmpcfIqooX9O6dT4OWaNfg0jIgz/7
         +W1Q==
X-Gm-Message-State: AJIora+O9evHuU6txDDM5jHg9I1pjssS1sa+PrVtkv5INVPUrU85R44R
	LUgRoAphCi6wmzmSHp743SZ2+YJ3BPM=
X-Google-Smtp-Source: AGRyM1sr5lgSpXi+QmU72+6JrKL04/9TD/Xx40LH9pnO0D9mPYtjgOsXuVBwRCqmaLLsP53LTzYXAg==
X-Received: by 2002:a05:6870:c083:b0:10c:275b:45f3 with SMTP id c3-20020a056870c08300b0010c275b45f3mr18290148oad.206.1658160519455;
        Mon, 18 Jul 2022 09:08:39 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id t19-20020a9d5913000000b0061cae832e5dsm297941oth.3.2022.07.18.09.08.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 09:08:39 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 8/9] useful: Add maxsize()
Date: Mon, 18 Jul 2022 11:02:21 -0500
Message-Id: <20220718160222.10634-8-denkenz@gmail.com>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220718160222.10634-1-denkenz@gmail.com>
References: <20220718160222.10634-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Similar to minsize(), but for finding the maximum of two sizes
---
 ell/useful.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/ell/useful.h b/ell/useful.h
index 791fa2006494..efd91d78b3f2 100644
--- a/ell/useful.h
+++ b/ell/useful.h
@@ -38,6 +38,14 @@ static inline size_t minsize(size_t a, size_t b)
 	return b;
 }
 
+static inline size_t maxsize(size_t a, size_t b)
+{
+	if (a >= b)
+		return a;
+
+	return b;
+}
+
 static inline void set_bit(void *addr, unsigned int bit)
 {
 	unsigned char *field = addr;
-- 
2.35.1

