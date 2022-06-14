Received: from mail-pl1-f177.google.com (mail-pl1-f177.google.com [209.85.214.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 947841FDA
	for <ell@lists.linux.dev>; Tue, 14 Jun 2022 21:14:05 +0000 (UTC)
Received: by mail-pl1-f177.google.com with SMTP id i15so8795437plr.1
        for <ell@lists.linux.dev>; Tue, 14 Jun 2022 14:14:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=7lcR2q190lfrT16WpIKZJ4Zni7BFCQXd6Qu0mcZRNl4=;
        b=W53azEAW0nsvNWrwBvsqMk+pi/R2MLKnGhGOlIH0K195axdiZ2OpoNuh6BsR88JrFq
         lqg8ZDVUaUKylq2H4skXV8FzBcwlgSZR/LUMBM6F5Fd2FFGMg3USR8P55i8zJvoKqXvy
         cGDhhRqeGNFVGHDEDg7odRXvPlWlDB8ImZ0mQIMR0WLzsbcEFD04LVpcPKip8T1u8d+a
         7AQ0n1KIV3Uk2XXqoLOBVP2jQ+LVVcPdG0Adz8zZID9hMzEIJ3jBkWA0iPlJdhg0JyEt
         HtdxmcKI7+a8BGaObCB2uMkQJTASWpVwZWZhQkRaO9b/LRv0e2QFoppXd/g5AauMfpyY
         z4Ag==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=7lcR2q190lfrT16WpIKZJ4Zni7BFCQXd6Qu0mcZRNl4=;
        b=KQ+7oJ/afQS3EUHesj8kCl713gXX947JnRlmlvaMI0XLYfsuMxPDhzqpzkObzhvXD0
         NxrnpBJVDULfQXjC98n/voug7WXcub0SutwuwXa9njrhs+HvMGeBksRwhBp03TRka+VA
         N5MU6ddqYY9Quxsvfm6CK7MNyxpEefVsqWDSWneRroU6qcemo/g1mztlJKX/zbbjdmeP
         Dxy2SV6VqWySQwGi4kpZUNQWKNxga65WlwvFXe94B5gvwG+xGL100vr4QEkHljXPi/aC
         D11OgciUAF7ggm7HEKjLU6VBJneiADBFwTzLV3LphOLqQC7AXdu3oJHGnV9j/28oehyL
         yHbg==
X-Gm-Message-State: AJIora+2NkZLL5K0PHmAaDGvFhP8fCDwq8dAVnEkKLG92Gf5HMsYJZkS
	nwizujFCp6mja7c0IFrLCN4uG/nlpIU=
X-Google-Smtp-Source: AGRyM1va8HndwhVYVYhrZ0BKkmx6ONeC6flMbxfvjTSCMA5dRVc74wroxUtkgVfqp2giDImMKajXdA==
X-Received: by 2002:a17:902:d183:b0:168:d6d6:20aa with SMTP id m3-20020a170902d18300b00168d6d620aamr6288169plb.143.1655241244686;
        Tue, 14 Jun 2022 14:14:04 -0700 (PDT)
Received: from localhost.localdomain ([50.45.187.22])
        by smtp.gmail.com with ESMTPSA id o6-20020aa79786000000b0050dc76281e0sm7966806pfp.186.2022.06.14.14.14.04
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 14 Jun 2022 14:14:04 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH] CI test, please ignore
Date: Tue, 14 Jun 2022 14:11:47 -0700
Message-Id: <20220614211147.697569-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 README | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/README b/README
index 99207e3..6d8f930 100644
--- a/README
+++ b/README
@@ -1,3 +1,5 @@
+Changed the README
+
 ELL - Embedded Linux library
 ****************************
 
-- 
2.34.1

