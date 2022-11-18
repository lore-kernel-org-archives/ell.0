Received: from mail-pj1-f41.google.com (mail-pj1-f41.google.com [209.85.216.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99A80A492
	for <ell@lists.linux.dev>; Fri, 18 Nov 2022 21:16:44 +0000 (UTC)
Received: by mail-pj1-f41.google.com with SMTP id k2-20020a17090a4c8200b002187cce2f92so4195768pjh.2
        for <ell@lists.linux.dev>; Fri, 18 Nov 2022 13:16:44 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Lakz4iyOJ09x8nvUgCiLLujzVUcwk8jT6aN4/3Fx8UA=;
        b=c7gCXyFI2t02Oguv5KQ8Fm30KBKao7o032/AZMO8JhcE3DBZty71WAITsXcEgsQ9nf
         rgSayRqJlFBundvyhkQTYFWRGieeTcqHCEtAUomys+oJslmM3lNdEWQrEAfpTidU7OSN
         D8xEEbYM7PJcIsuL1WRnQuD22bRbUCIcOp+KE5RhF67y4JsbgOXiiGjpqSvCeVq2bnss
         U8/61n/4es60uyG69NHMPjKQ/+1wGTnnUKv14rR2lWf1NL5jwMg3spUafzxSwfI0f1nO
         QFb3iaymlR0NhHkjHyVMEFKHsqVpnZepa9+0XzXa2bT+SO5E3UpGq25cTOtLVKWUIQd1
         4keQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=Lakz4iyOJ09x8nvUgCiLLujzVUcwk8jT6aN4/3Fx8UA=;
        b=6jdWfXAkLkP4TDyTj4t0pYFx2A67Hs1mOJiEnSgWDbnaRNk8qTEI0c91mVJGFT9WMs
         sBWYll4YREl6zI/zQDUa5DsfuB94f1nVLH7pN9C28K6TereSadAmNAlqnCg68Mjd4PPz
         r83PNrhpABuYyYC4c+89TJixfoJ1hTxSgWYVPH/6VaZ2sfqE/1e5D/BkCzBn+6QbvZpd
         L00UNVRI4S6kBQrCHA8ySYCafEn8mUVn9Ed3324kSkPI0sUOFczMshY9ESiXG4a7iBzQ
         VsOyTwk+XsW3El7XhSir+l8BzSlhIDylc6Dt11jl7UVu8qyGXeazI/hLh2C6l7KYs+yi
         Q3PQ==
X-Gm-Message-State: ANoB5pkAdsmIGXeugjYq8ElOwO9+A6Tpl0KRJGxOmVkTOdRB9WBG1MFZ
	+F+xiuCY4MVSNWuJF/soDoY1h7XxjwQ=
X-Google-Smtp-Source: AA0mqf4PrpfbQf7ROhEr3FvJx/4jvT/HOCxag+ZqCQuxPESsWsD9YTMk33UEcn63sBhMtTXgE9q+Dw==
X-Received: by 2002:a17:902:ee53:b0:186:9fb9:1f84 with SMTP id 19-20020a170902ee5300b001869fb91f84mr1358229plo.45.1668806203937;
        Fri, 18 Nov 2022 13:16:43 -0800 (PST)
Received: from jprestwo-xps.none ([50.39.160.234])
        by smtp.gmail.com with ESMTPSA id y12-20020aa79aec000000b0056ee49d6e95sm3630142pfp.86.2022.11.18.13.16.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 18 Nov 2022 13:16:43 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [RFC 8/8] unit: update test-pbkdf2 with API change
Date: Fri, 18 Nov 2022 13:16:24 -0800
Message-Id: <20221118211624.19298-9-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.3
In-Reply-To: <20221118211624.19298-1-prestwoj@gmail.com>
References: <20221118211624.19298-1-prestwoj@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 unit/test-pbkdf2.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/unit/test-pbkdf2.c b/unit/test-pbkdf2.c
index 3f272ce..1053de2 100644
--- a/unit/test-pbkdf2.c
+++ b/unit/test-pbkdf2.c
@@ -52,6 +52,7 @@ static void pbkdf2_test(const void *data)
 	key_len = test->key_len ? : (strlen(test->key) / 2);
 
 	result = l_cert_pkcs5_pbkdf2(L_CHECKSUM_SHA1, test->password,
+					strlen(test->password),
 					(const uint8_t *) test->salt, salt_len,
 					test->count, output, key_len);
 
-- 
2.34.3

