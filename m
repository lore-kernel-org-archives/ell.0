Received: from mail-pl1-f171.google.com (mail-pl1-f171.google.com [209.85.214.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D7C412CB5
	for <ell@lists.linux.dev>; Sat, 18 Dec 2021 04:15:11 +0000 (UTC)
Received: by mail-pl1-f171.google.com with SMTP id n16so2745905plc.2
        for <ell@lists.linux.dev>; Fri, 17 Dec 2021 20:15:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=8MbUogbnvoIsQ015ii/YC3ATY39Zwxpmk2ol9A5N7Ic=;
        b=oaHT9db/oQt2L04y7y0hont1X+kkfJCngl4azbTU7IVy/fIffeW6wx3Kt0etLafIYV
         hMjyGP06ZhTLlW7HjmsBvPTQas3gY3hIJjlyXUidF4K4nOrT3jYtv6LtVU/RK7rxgCEP
         LOtVGIbdaLijVBW1WTk0xHXpRuKe8MynIcnyWVZ3676jUlmutzkX52T+lZPpapqxNWOT
         SkJOscvlekQ1v42vhcfM1ZW2vQTVV4UOYaxGnWz1hvGF27+/AA32Fq/s328sB46J8r0m
         HQ/CBbNu+7LIAdGb6BgwcFaLqCSk1apsq1aifGw7H/yxtUdosZUZe3jsrufpXNl/IwYd
         Ut3w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=8MbUogbnvoIsQ015ii/YC3ATY39Zwxpmk2ol9A5N7Ic=;
        b=U+R0hyhSgKayyGR43f5tyE4HeGVkXQNUF5ECjIfBKBL/jZFPiYni208dPERsg2kvDY
         mFqp9Uyuv2z+wfdtZfz/RmJmzLKQ5P7dIptyFHmb02uGPH9XraVbjQyH9vreWSnLVhJ8
         gGgN51dJGTvaOFFvbMo49RpB+v/xKze8cM2WlLurTey8Lcrb8VxVHFOgZqy2bCCUYRa0
         BrQ/NnUdJJJOsuYOPvjwWxMLtpfDYisLyXlAseV25gek77bEAJ+G/mMB4V+AtabPi6gg
         4xgt8OkUTfbsEziKON9mfMQM2WX7FuBFIkQ7Mh+0E5UNaVlz/lPvqaswGrmd+SXAkA2N
         IoQQ==
X-Gm-Message-State: AOAM530+cQkgbcW08MaLEwpH/sZP1/DT1KEIHfiX/9yOSsbC8x6i6HEr
	+y8qhdMNgAdYmBr4dF0pcCRPuiwqqMhw0Q==
X-Google-Smtp-Source: ABdhPJycLGnf6MaXmbbkJ1H+Pu/+MBi0OmuFuQLgVbXiVNoULD9zj33hEs5I/JO7cznZ631MIkTjAA==
X-Received: by 2002:a17:902:d88b:b0:142:8acf:615b with SMTP id b11-20020a170902d88b00b001428acf615bmr6311672plz.62.1639800911279;
        Fri, 17 Dec 2021 20:15:11 -0800 (PST)
Received: from hydra.localdomain ([50.45.159.39])
        by smtp.gmail.com with ESMTPSA id qe2sm10194506pjb.42.2021.12.17.20.15.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 17 Dec 2021 20:15:10 -0800 (PST)
From: Ossama Othman <ossama.othman@gmail.com>
X-Google-Original-From: Ossama Othman <ossama.othman@intel.com>
To: ell@lists.linux.dev
Cc: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 3/3] unit: Initialize variables prior to use
Date: Fri, 17 Dec 2021 20:14:31 -0800
Message-Id: <20211218041431.114737-4-ossama.othman@intel.com>
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

Address "use of uninitialized variable" related error exhibited by
Valgrind in the test-rtnl unit test.
---
 unit/test-rtnl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/unit/test-rtnl.c b/unit/test-rtnl.c
index 107f69a..e6d2201 100644
--- a/unit/test-rtnl.c
+++ b/unit/test-rtnl.c
@@ -147,7 +147,7 @@ static void route6_dump_cb(int error,
 {
 	const struct rtmsg *rtmsg = data;
 	char *dst = NULL, *gateway = NULL, *src = NULL;
-	uint32_t table, ifindex;
+	uint32_t table = 0, ifindex = 0;
 
 	test_assert(!error);
 	test_assert(type == RTM_NEWROUTE);
-- 
2.32.0

