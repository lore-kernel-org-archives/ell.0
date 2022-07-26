Received: from mail-pg1-f174.google.com (mail-pg1-f174.google.com [209.85.215.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C89825384
	for <ell@lists.linux.dev>; Tue, 26 Jul 2022 16:35:02 +0000 (UTC)
Received: by mail-pg1-f174.google.com with SMTP id f65so13577873pgc.12
        for <ell@lists.linux.dev>; Tue, 26 Jul 2022 09:35:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=hI6QSi/O/MST0K1KXlY/poQrkUOTYChYz6IMXxsS7nY=;
        b=eoR+4NPO5OnsehLJLCRrjkLZ/sMSDxJPGwZpS732JZy2cP87fUkGMaLT2XliNQXJ7A
         GfjH+G1fAPBFUSy84/FpNv9WuWTPsW3kYShBPKA5bt6mZ0Fexz/YoCqbAMdzP+KogwfH
         tHTiWjL528KLZovvtydwEWruwOK8vzxZWq7ugqyUNw/b3Zv1PW1AheiHWMF//R5l3OEr
         D/BrNvtooRLpuKSnx98T/nOknKw7hbNe1OJMtAXIqL96ruO8ppeL9CILrwXwN2D6azZ4
         suZSTDy4RKwBrIm5NAfSoKA0BHp1YMLWg3YfOC7ajuMwO+qixqMntEJVPevB1OWVyWXN
         vAJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=hI6QSi/O/MST0K1KXlY/poQrkUOTYChYz6IMXxsS7nY=;
        b=N6njTIXtcWfX5/KZEnPKEe5z3Zq4V3lPtjRx3AYjPgDGiABEQFnyt84xAgar0xozX7
         Byjj2mcIV4mPS3KC9TeXv+vtwT/DiHeEEBDbviopnjsOfDMvKemDVfsIyHEtq3GQ4UDs
         SRqfiA+Up9HNgkBFwxJQOxOrOPKVUHlZJKnhNs5zsNh9sFeWdJwNg3aCCfU58HMwc0Z7
         FkwV+gd3E+NeCdJiQLp5nON8mvJMeSmORRsc9zh35MbHifwA2w3N3NIJLvBxkt/YsNjV
         kLYykET/DvKa9MWe4nsSbshgry8qbDW7A7uFwmtQX9JrKEgevTdz4UrwfD24TDO3Gt5P
         Ty0A==
X-Gm-Message-State: AJIora/Ut/QZQDyWOIJpOobjN4F/lAhDH3svXCYOc1sGxJe7YOqSegzV
	x1j/oTKvVQYFvG1x3ihSsLSio8kaEPg=
X-Google-Smtp-Source: AGRyM1vjx9wUZ3e7quZthLJZIUjCMnHR6atdIwX0ZQ3P2PbHA7Lf/giImzwtMzBR6nwdh18ol2B6Tw==
X-Received: by 2002:a05:6a02:18b:b0:415:c9d:4e3c with SMTP id bj11-20020a056a02018b00b004150c9d4e3cmr15192853pgb.580.1658853302056;
        Tue, 26 Jul 2022 09:35:02 -0700 (PDT)
Received: from jprestwo-xps.none (h208-100-169-68.bendor.broadband.dynamic.tds.net. [208.100.169.68])
        by smtp.gmail.com with ESMTPSA id z17-20020a170903019100b00168e83eda56sm11955336plg.3.2022.07.26.09.35.01
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 26 Jul 2022 09:35:01 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 1/2] genl: make l_genl_attr_recurse take a const pointer
Date: Tue, 26 Jul 2022 09:34:59 -0700
Message-Id: <20220726163500.6171-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.3
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The outer attribute iterator should be const since its not being
modified.
---
 ell/genl.c | 2 +-
 ell/genl.h | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index 2cae2f0..2c873ef 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -1761,7 +1761,7 @@ LIB_EXPORT bool l_genl_attr_next(struct l_genl_attr *attr,
 	return true;
 }
 
-LIB_EXPORT bool l_genl_attr_recurse(struct l_genl_attr *attr,
+LIB_EXPORT bool l_genl_attr_recurse(const struct l_genl_attr *attr,
 						struct l_genl_attr *nested)
 {
 	const struct nlattr *nla;
diff --git a/ell/genl.h b/ell/genl.h
index 7e5b7bb..42041fa 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -109,7 +109,8 @@ bool l_genl_msg_leave_nested(struct l_genl_msg *msg);
 bool l_genl_attr_init(struct l_genl_attr *attr, struct l_genl_msg *msg);
 bool l_genl_attr_next(struct l_genl_attr *attr, uint16_t *type,
 					uint16_t *len, const void **data);
-bool l_genl_attr_recurse(struct l_genl_attr *attr, struct l_genl_attr *nested);
+bool l_genl_attr_recurse(const struct l_genl_attr *attr,
+				struct l_genl_attr *nested);
 
 bool l_genl_family_info_has_group(const struct l_genl_family_info *info,
 					const char *group);
-- 
2.34.3

