Received: from mail-pj1-f44.google.com (mail-pj1-f44.google.com [209.85.216.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 344E62CB0
	for <ell@lists.linux.dev>; Sat, 18 Dec 2021 04:15:11 +0000 (UTC)
Received: by mail-pj1-f44.google.com with SMTP id jw3so563357pjb.4
        for <ell@lists.linux.dev>; Fri, 17 Dec 2021 20:15:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=xUE6CjFlT6PRzhdQ5sH22BkE8ZT1cCsLKLmtEudMjao=;
        b=M4V8x8q+OXn4mpCJ8IjOnB3BaIkgHqFGmiQSNqvVJA0eGDLgcrNs/+Mcjedc03kdhO
         yY7VoSZyFr8Gdw+CpDOyFx7a6k/5sC1DL+p1wdUagv7p2LN/CgXl3zTwMW3LazIdnOYk
         b5702a54uuDv5HlQdqX6qMqBrpGfa2qnxuEqg+jY1QbPvFalJVMsgONfHmubR2+Hdh85
         rvsJI/NjqCzkibtbuIsctpPL0gjlXvFwxHs5KBy5BJFYheDx9zJ02x89hDueePtJuf8P
         VgX/hTChXxqJfWfrSZI1DgkZU1iK1mb7WT5neW58gblYbM0g4TLo/5ywPfX/SvCWFtUz
         q7CQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=xUE6CjFlT6PRzhdQ5sH22BkE8ZT1cCsLKLmtEudMjao=;
        b=DWfQCkhV/2N2Fg6bUPjpq5WjRteGGegmqoBOelrYXDGzqCfoavRtCqAzrOa1KnkBeL
         eQk8i767M0gqpD2vYTtj8pP+03ltEZmmKGjO9A2OU3VZDbSUhszGyTf+5e7Xq7xtOKT2
         1FYmsU1OnR79u7+X/rZouWhfSElFhP2qwildUPC0AUutJ8lCo41MlshvT7cnJiT7Xk1x
         zl1hwEmzXkITaBpLNKfmR3LqWWPQcFBP1uuBu0XGUwdNMu6FFWWAg10aqg6jTO/XdW0U
         KllRjq/wG5NnKZtNWoHAwi5UcuaGMLZMyTnsFFD5l/Glp3pkcAFDZPLEC3dZt+81J9bC
         Swhg==
X-Gm-Message-State: AOAM531zJhmqEk520ZYptBfX24ZQAo/2HOHGyBBXn9EjHnMXwgTlhvcF
	C0zgqUYPgwgxmBE1JRKasD4P9Hkq14vnfw==
X-Google-Smtp-Source: ABdhPJy+1mSfZD/e3kth42tQMoRpUug5HhTAvesfcYpuSbMi/0wgBNNFjb2bUEAbCzeDb/GZwscbbw==
X-Received: by 2002:a17:902:be06:b0:142:5a21:9e8a with SMTP id r6-20020a170902be0600b001425a219e8amr6322541pls.17.1639800910574;
        Fri, 17 Dec 2021 20:15:10 -0800 (PST)
Received: from hydra.localdomain ([50.45.159.39])
        by smtp.gmail.com with ESMTPSA id qe2sm10194506pjb.42.2021.12.17.20.15.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 17 Dec 2021 20:15:10 -0800 (PST)
From: Ossama Othman <ossama.othman@gmail.com>
X-Google-Original-From: Ossama Othman <ossama.othman@intel.com>
To: ell@lists.linux.dev
Cc: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 2/3] unit: Free l_uintset when done.
Date: Fri, 17 Dec 2021 20:14:30 -0800
Message-Id: <20211218041431.114737-3-ossama.othman@intel.com>
X-Mailer: git-send-email 2.32.0
In-Reply-To: <20211218041431.114737-1-ossama.othman@intel.com>
References: <20211218041431.114737-1-ossama.othman@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

In the test_uintset_size() test case, free the l_uintset instance when
done to fix a memory leak.
---
 unit/test-uintset.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/unit/test-uintset.c b/unit/test-uintset.c
index 31dc274..6e3767b 100644
--- a/unit/test-uintset.c
+++ b/unit/test-uintset.c
@@ -384,6 +384,8 @@ static void test_uintset_size(const void *user_data)
 		assert(l_uintset_take(set, i));
 
 	assert(l_uintset_size(set) == 0);
+
+	l_uintset_free(set);
 }
 
 int main(int argc, char *argv[])
-- 
2.32.0

