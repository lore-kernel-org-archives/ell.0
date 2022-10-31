Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8823D20F2
	for <ell@lists.linux.dev>; Mon, 31 Oct 2022 10:53:56 +0000 (UTC)
Received: by mail-wm1-f53.google.com with SMTP id l16-20020a05600c4f1000b003c6c0d2a445so7749150wmq.4
        for <ell@lists.linux.dev>; Mon, 31 Oct 2022 03:53:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=TpBniWtTNAxDyGSVsPtQ6gYSK1/0OO7bYOa3iFtAA6Y=;
        b=dCdPNOU8LEfsTaqaEavcgRTjkf21z/A0KSO7MYilVtQRRUHUw00gXQf0Q2BnDVRoD7
         QOsDpkwXYMcNguirHJj5b0fDPSP63KCUNJh9rffhVFu0KbDJAyBUYp+w9ggMgJsg2J1/
         /C4wZM672BpCdb6KGAoZIFAs2XIxHlA5Nqm/0v/4sWMsciluhXkY4FJRtMpiaY+Lretu
         futzd8JtbjLOO/5inDJlkCsbqwnjoFHG25Dk39D5AOBEG2UOOwebeGOc1KimjpfoFZCg
         qaz6etlwwpKNVsuQlJaJK57+QOR1hWMWws3FlJFbVaIthgQXs1dmTvgITrjkgwD+dAT6
         AzjA==
X-Gm-Message-State: ACrzQf1YaFtidgBN0XG2qIoW7d35TZSpaGLF5S964cGvJoAJiS3XZ7W5
	hnGaA5GcHkj6c6b2VLrAmS0sG9xKzF4=
X-Google-Smtp-Source: AMsMyM6LkKzasAGUd8NlivrVsANRZ087hCuJZ8BAYt2dn3TCrRfDe/mQ64macEtbSQ8chDBpSxZzQQ==
X-Received: by 2002:a1c:f311:0:b0:3b5:18ca:fc5e with SMTP id q17-20020a1cf311000000b003b518cafc5emr7660698wmq.70.1667213633946;
        Mon, 31 Oct 2022 03:53:53 -0700 (PDT)
Received: from localhost.localdomain ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id ay19-20020a5d6f13000000b00236b2804d79sm6890737wrb.2.2022.10.31.03.53.52
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 31 Oct 2022 03:53:52 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 1/4] cert: Fix logic in cert_parse_asn1_time check
Date: Mon, 31 Oct 2022 11:53:39 +0100
Message-Id: <20221031105342.2660357-1-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Fix wrong operator in a condition that ended up being always true.
---
 ell/cert.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/cert.c b/ell/cert.c
index b4f5df7..ab469c2 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -236,7 +236,7 @@ static uint64_t cert_parse_asn1_time(const uint8_t *data, size_t len,
 		return L_TIME_INVALID;
 
 	if (unlikely((len != i + 1 || data[i] != 'Z') &&
-			(len != i + 5 || data[i] != '+' || data[i] != '-')))
+			(len != i + 5 || (data[i] != '+' && data[i] != '-'))))
 		return L_TIME_INVALID;
 
 	tm.tm_year = (data[0] - '0') * 10 + (data[1] - '0');
-- 
2.34.1

