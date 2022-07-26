Received: from mail-pl1-f169.google.com (mail-pl1-f169.google.com [209.85.214.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6810D5385
	for <ell@lists.linux.dev>; Tue, 26 Jul 2022 16:35:03 +0000 (UTC)
Received: by mail-pl1-f169.google.com with SMTP id d3so5935094pls.4
        for <ell@lists.linux.dev>; Tue, 26 Jul 2022 09:35:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=J4AcuxRb3iWedNA8jR8K83pLp95pONbrhbMVb/XlT+A=;
        b=fAB0AXB9K/1zhHfVcgZUi6rhWuhLuCF1rx3/TnoXDNbQKrsbCAvOe7Byof+DhtLlLT
         qL+ceHNIjyA34MSZqAfhDdtLBvYNg8Z6xgwuv/+CCMjHSJbtAiZA8LEJErwayoM/Urrq
         ErL+Dw2W+juhlQBhrwbFZPtCJAebNnF7Kb+Bo8URGxLXLpj3RFgW0AMiT/Xr+7kq23e8
         i2P4a3BamHXtIJY0VeWAcRYvI9G0xNl/Byrml/XIrXVooT4PqoATqNnU7zEp5MhxVwBF
         nvCqDYcO0npf2ZXZ0khnZ6EI81l+vccL30JQngsDnrgel9nbxAm6OmNQI0GsrdKbXJol
         Hmow==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=J4AcuxRb3iWedNA8jR8K83pLp95pONbrhbMVb/XlT+A=;
        b=ubE9uJVp9nXRG8PUlYdPo6yvweGMDKb/Be4DW1pjhReQg8q9qguuhVHrfrlS/ClBKk
         QaxLMF+P0gaLKw3s7d7IAQZotzlGmd1iL9AE1eN8nvhJbIl1Ze5S8Dh/3bvSucA6lhcn
         NjevQQzu3G/alP4lwFTjZc2R2dDEAvgBDiknXi4BHfnMc+VkzpNLpjS0/MfjCm6CAZun
         tDK05N1GUlQtdNFJT72EK/WsdyPuNZz1Of8jF2zUD4qNj+/gi6jSW5s+FJs8GGQbzclz
         OyvubbmEYFI3zwgFCstpi8TxFvlcg/tKXNvyy+oOfZZFF6BgEHBYPIp6DO5CLsOGg+V0
         PTAg==
X-Gm-Message-State: AJIora9ob9opSEHcFGEfLm+xUxAQN8G3sj9vtYpuhtG4PcLn28qixSUA
	lroUCYbDqGHdSyOZTXJRpC41nsFy6Rg=
X-Google-Smtp-Source: AGRyM1sXoyyUYYrdt+8hfom3bfQIEo7V7ZibSSsk39fc50kOpSgqIhSg2vz2TJE/MV2CmWFKAx32AQ==
X-Received: by 2002:a17:902:f542:b0:16d:5a3d:a529 with SMTP id h2-20020a170902f54200b0016d5a3da529mr15418388plf.170.1658853302697;
        Tue, 26 Jul 2022 09:35:02 -0700 (PDT)
Received: from jprestwo-xps.none (h208-100-169-68.bendor.broadband.dynamic.tds.net. [208.100.169.68])
        by smtp.gmail.com with ESMTPSA id z17-20020a170903019100b00168e83eda56sm11955336plg.3.2022.07.26.09.35.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 26 Jul 2022 09:35:02 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 2/2] genl: remove 'msg' from l_genl_attr
Date: Tue, 26 Jul 2022 09:35:00 -0700
Message-Id: <20220726163500.6171-2-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.3
In-Reply-To: <20220726163500.6171-1-prestwoj@gmail.com>
References: <20220726163500.6171-1-prestwoj@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The original l_genl_msg object was never being used
---
 ell/genl.c | 2 --
 ell/genl.h | 1 -
 2 files changed, 3 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index 2c873ef..4ed95df 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -1720,7 +1720,6 @@ LIB_EXPORT bool l_genl_attr_init(struct l_genl_attr *attr,
 	if (!NLA_OK(nla, len))
 		return false;
 
-	attr->msg = msg;
 	attr->data = NULL;
 	attr->len = 0;
 	attr->next_data = nla;
@@ -1773,7 +1772,6 @@ LIB_EXPORT bool l_genl_attr_recurse(const struct l_genl_attr *attr,
 	if (!nla)
 		return false;
 
-	nested->msg = attr->msg;
 	nested->data = NULL;
 	nested->len = 0;
 	nested->next_data = NLA_DATA(nla);
diff --git a/ell/genl.h b/ell/genl.h
index 42041fa..915bcf7 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -76,7 +76,6 @@ bool l_genl_request_family(struct l_genl *genl, const char *name,
 					l_genl_destroy_func_t destroy);
 
 struct l_genl_attr {
-	struct l_genl_msg *msg;
 	const void *data;
 	uint32_t len;
 	const void *next_data;
-- 
2.34.3

