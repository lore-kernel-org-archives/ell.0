Received: from mail-pg1-f179.google.com (mail-pg1-f179.google.com [209.85.215.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 75977A48D
	for <ell@lists.linux.dev>; Fri, 18 Nov 2022 21:16:41 +0000 (UTC)
Received: by mail-pg1-f179.google.com with SMTP id f3so6051788pgc.2
        for <ell@lists.linux.dev>; Fri, 18 Nov 2022 13:16:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=X5GC5gLzE1EINRN6KowrVk/o57xY4IZpmv+uiURo/Lo=;
        b=GrHu7KwNwui23n8PyWDosw4w4N2LzZgKOAnNfHhklLvxbk3cyGrGiMznx49+vV8Bb4
         CGryAQX7SIkY83gWTdxDV6VRg4Cpz2c25TPlsvJ6UWKzmIX/PiC21IWixRsWzSM+g7nI
         wv4neJAsW7H3KUdyA+N6rAifiFi9sFeHPEO+SzWLqjyhccZMEFcg2yZRpE0AWqmkPu1f
         ylvLcDRW+6yi5Fg9IbZWcVSG0YniLFevmX2PRti+DREP0DqW7uvY+mWucHTk13PNvJoq
         Aix5nNw/LxZc2Ki52k297WeUonOmiWdO6bMHC0Zpmn0gjX43iggxfakNlCqf61En5Va7
         7pyw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=X5GC5gLzE1EINRN6KowrVk/o57xY4IZpmv+uiURo/Lo=;
        b=qxxmVpW/RYrq1smpRiA4zz67ALyCgpadiW8n3C6Yua48+oD0Br8ArK3ijRUdJtoAQ6
         1Lh7nJqcfqXVaB6musp2FUv9+pIIcyePsDQkpf8GnvRBnEH+ziuKqo/1qm256TECN1bC
         iEsw+jLBYEHCenD13g030pCEJyTNM1Xb981ULTAboFEuaMu/nnXHK+H2MWy3cjY5SMfy
         xTiAO5e5MkIUInWSYx9tz4bYnr74mv2H+idvpDHg5V6//vplq6FJJruGBf0uIlBK8mps
         uBa99GDfafYtMQhrO9kCps/KfMm5sk6tPxjRpSCEJ5rdreBRq46MHMd2CzqqM3TeEfeg
         x5ZA==
X-Gm-Message-State: ANoB5plCr3DcpTu7cCQbN+h0pcbf3GllVjWhyrpV8qBLOtX6muARBHhQ
	fOreprEx0II2B69WrSbIjFh0uysOLkQ=
X-Google-Smtp-Source: AA0mqf6Hy5x7M0AUJYCkzgKlFxMio2225MMxTzwQAdL9aKYEBeHvE8v2YoJkQOIz5vFOZ8tRr19xrg==
X-Received: by 2002:a05:6a00:3029:b0:572:8c05:6e2c with SMTP id ay41-20020a056a00302900b005728c056e2cmr9554656pfb.85.1668806200779;
        Fri, 18 Nov 2022 13:16:40 -0800 (PST)
Received: from jprestwo-xps.none ([50.39.160.234])
        by smtp.gmail.com with ESMTPSA id y12-20020aa79aec000000b0056ee49d6e95sm3630142pfp.86.2022.11.18.13.16.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 18 Nov 2022 13:16:40 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [RFC 3/8] checksum: commonize checksum creation
Date: Fri, 18 Nov 2022 13:16:19 -0800
Message-Id: <20221118211624.19298-4-prestwoj@gmail.com>
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

The various checksums were using virutally the same init code. Make
this common which will make initialization by key ID much simpler
to add.
---
 ell/checksum.c | 103 ++++++++++++++++++-------------------------------
 1 file changed, 37 insertions(+), 66 deletions(-)

diff --git a/ell/checksum.c b/ell/checksum.c
index c71205a..e17f070 100644
--- a/ell/checksum.c
+++ b/ell/checksum.c
@@ -146,55 +146,22 @@ static int create_alg(const char *alg)
 	return sk;
 }
 
-/**
- * l_checksum_new:
- * @type: checksum type
- *
- * Creates new #l_checksum, using the checksum algorithm @type.
- *
- * Returns: a newly allocated #l_checksum object.
- **/
-LIB_EXPORT struct l_checksum *l_checksum_new(enum l_checksum_type type)
-{
-	struct l_checksum *checksum;
-	int fd;
-
-	if (!is_valid_index(checksum_algs, type) || !checksum_algs[type].name)
-		return NULL;
-
-	checksum = l_new(struct l_checksum, 1);
-	checksum->alg_info = &checksum_algs[type];
-
-	fd = create_alg(checksum->alg_info->name);
-	if (fd < 0)
-		goto error;
-
-	checksum->sk = accept4(fd, NULL, 0, SOCK_CLOEXEC);
-	close(fd);
-
-	if (checksum->sk < 0)
-		goto error;
-
-	return checksum;
-
-error:
-	l_free(checksum);
-	return NULL;
-}
-
-LIB_EXPORT struct l_checksum *l_checksum_new_cmac_aes(const void *key,
-							size_t key_len)
+static struct l_checksum *checksum_new_common(const char *alg, int sockopt,
+						const void *data, size_t len,
+						struct checksum_info *info)
 {
 	struct l_checksum *checksum;
 	int fd;
 
-	fd = create_alg("cmac(aes)");
+	fd = create_alg(alg);
 	if (fd < 0)
 		return NULL;
 
-	if (setsockopt(fd, SOL_ALG, ALG_SET_KEY, key, key_len) < 0) {
-		close(fd);
-		return NULL;
+	if (data) {
+		if (setsockopt(fd, SOL_ALG, sockopt, data, len) < 0) {
+			close(fd);
+			return NULL;
+		}
 	}
 
 	checksum = l_new(struct l_checksum, 1);
@@ -206,40 +173,44 @@ LIB_EXPORT struct l_checksum *l_checksum_new_cmac_aes(const void *key,
 		return NULL;
 	}
 
-	checksum->alg_info = &checksum_cmac_aes_alg;
+	checksum->alg_info = info;
 	return checksum;
 }
 
-LIB_EXPORT struct l_checksum *l_checksum_new_hmac(enum l_checksum_type type,
-					  const void *key, size_t key_len)
+/**
+ * l_checksum_new:
+ * @type: checksum type
+ *
+ * Creates new #l_checksum, using the checksum algorithm @type.
+ *
+ * Returns: a newly allocated #l_checksum object.
+ **/
+LIB_EXPORT struct l_checksum *l_checksum_new(enum l_checksum_type type)
 {
-	struct l_checksum *checksum;
-	int fd;
-
-	if (!is_valid_index(checksum_hmac_algs, type) ||
-			!checksum_hmac_algs[type].name)
-		return NULL;
-
-	fd = create_alg(checksum_hmac_algs[type].name);
-	if (fd < 0)
+	if (!is_valid_index(checksum_algs, type) || !checksum_algs[type].name)
 		return NULL;
 
-	if (setsockopt(fd, SOL_ALG, ALG_SET_KEY, key, key_len) < 0) {
-		close(fd);
-		return NULL;
-	}
+	return checksum_new_common(checksum_algs[type].name, 0, NULL, 0,
+					&checksum_algs[type]);
+}
 
-	checksum = l_new(struct l_checksum, 1);
-	checksum->sk = accept4(fd, NULL, 0, SOCK_CLOEXEC);
-	close(fd);
+LIB_EXPORT struct l_checksum *l_checksum_new_cmac_aes(const void *key,
+							size_t key_len)
+{
+	return checksum_new_common("cmac(aes)", ALG_SET_KEY, key, key_len,
+					&checksum_cmac_aes_alg);
+}
 
-	if (checksum->sk < 0) {
-		l_free(checksum);
+LIB_EXPORT struct l_checksum *l_checksum_new_hmac(enum l_checksum_type type,
+					  const void *key, size_t key_len)
+{
+	if (!is_valid_index(checksum_hmac_algs, type) ||
+			!checksum_hmac_algs[type].name)
 		return NULL;
-	}
 
-	checksum->alg_info = &checksum_hmac_algs[type];
-	return checksum;
+	return checksum_new_common(checksum_hmac_algs[type].name,
+					ALG_SET_KEY, key, key_len,
+					&checksum_hmac_algs[type]);
 }
 
 /**
-- 
2.34.3

