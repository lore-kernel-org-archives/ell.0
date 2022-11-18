Received: from mail-pj1-f54.google.com (mail-pj1-f54.google.com [209.85.216.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0CDDFA48B
	for <ell@lists.linux.dev>; Fri, 18 Nov 2022 21:16:41 +0000 (UTC)
Received: by mail-pj1-f54.google.com with SMTP id w15-20020a17090a380f00b0021873113cb4so5767989pjb.0
        for <ell@lists.linux.dev>; Fri, 18 Nov 2022 13:16:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=CAUTsZ3m+AAOnrwq/bW9M0ZTo/k+K/GGIkWw32M8Ukc=;
        b=iMIwMvGQJxCSUSsG+vY6rzSuNDPDeWYsGHl4PREcQRvvxocYsjVvYzFjQXnS7tNCPS
         6eLtjiyaxMjcbKiBq8/2QPsBKTsvkWc0umD1tHUijgGkls/vzvkq5hxzc66H6Q+BBL6+
         QaIJkd1IhAHytis27eWz6Pm186EMR1LDlpx5QwfW4eZd1k3RT7HAHqYTyVDMoaCS9OQc
         DgG/DRQeyrRSIAVIcf2A6rareFCTOavPoilMdNE3grmQaIXlfZHowoXGC7KqsX/SCBTf
         YPJJ1L7LOZQ+4bcOD7OpOxbue8HceLkn2c+WuHjpiPZkT258PV0H3xpjhS6KFVH5PZX/
         LrBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=CAUTsZ3m+AAOnrwq/bW9M0ZTo/k+K/GGIkWw32M8Ukc=;
        b=znK+18Gy3RAXSlka+r4OjXSD5SqtcajSES9ZSZNxu2vikpoH6O6xjsFzEl1UZ8cY42
         lyy8TfN+TSxEVBeM5bkiK0wlpfRyXNwgdRQtq+5hdmQzT3HlAhHiayAKw6JZPyh1TUE2
         8kVGSrMuxziDOfiVHPhCWOasIAXgP/qJa/zvjouY25KYBSNZer2QF0kjRx7GTCRpzgYy
         2Yl+dBgKY0TIVThCFpqp4ZoyPn49isnbb4uj5G6hdABNnUvqC6eWC6WIXYmt1pR0ilse
         rFUBpQpwwnT/Ffr1Zts7gD1Bq33XjWA3i49xG6TUMjsYF/vc4xLk6fFRoeDwC9/Twu7H
         z5Fg==
X-Gm-Message-State: ANoB5pmcV2ndvujpAl9n2D9X297kIsB7ArCvnynVhqOL6kPqGRzF9RDo
	7vQqMrg9WymzeDKP4lzCR4sM0SsFIQI=
X-Google-Smtp-Source: AA0mqf7zKvr8zBKz+yCJZhMKTOOoGdIpGgeRjUT19cOlrOJnTEjqs8Swat3mnV3NBWsHSXqdZBbu/g==
X-Received: by 2002:a17:902:ed93:b0:188:b5d6:2873 with SMTP id e19-20020a170902ed9300b00188b5d62873mr1189082plj.144.1668806201439;
        Fri, 18 Nov 2022 13:16:41 -0800 (PST)
Received: from jprestwo-xps.none ([50.39.160.234])
        by smtp.gmail.com with ESMTPSA id y12-20020aa79aec000000b0056ee49d6e95sm3630142pfp.86.2022.11.18.13.16.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 18 Nov 2022 13:16:41 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [RFC 4/8] checksum: add l_checksum_new_hmac_from_key_id
Date: Fri, 18 Nov 2022 13:16:20 -0800
Message-Id: <20221118211624.19298-5-prestwoj@gmail.com>
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

Same as l_checksum_new_hmac but uses a key ID rather than a
key directly.
---
 ell/checksum.c | 17 +++++++++++++++++
 ell/checksum.h |  2 ++
 ell/ell.sym    |  1 +
 3 files changed, 20 insertions(+)

diff --git a/ell/checksum.c b/ell/checksum.c
index e17f070..dc5e61a 100644
--- a/ell/checksum.c
+++ b/ell/checksum.c
@@ -68,6 +68,10 @@ struct sockaddr_alg {
 #define SOL_ALG 279
 #endif
 
+#ifndef ALG_SET_KEY_BY_KEY_SERIAL
+#define ALG_SET_KEY_BY_KEY_SERIAL 7
+#endif
+
 struct checksum_info {
 	const char *name;
 	uint8_t digest_len;
@@ -213,6 +217,19 @@ LIB_EXPORT struct l_checksum *l_checksum_new_hmac(enum l_checksum_type type,
 					&checksum_hmac_algs[type]);
 }
 
+struct l_checksum *l_checksum_new_hmac_from_key_id(enum l_checksum_type type,
+							int32_t key_id)
+{
+	if (!is_valid_index(checksum_hmac_algs, type) ||
+			!checksum_hmac_algs[type].name)
+		return NULL;
+
+	return checksum_new_common(checksum_hmac_algs[type].name,
+					ALG_SET_KEY_BY_KEY_SERIAL,
+					&key_id, sizeof(key_id),
+					&checksum_hmac_algs[type]);
+}
+
 /**
  * l_checksum_clone:
  * @checksum: parent checksum object
diff --git a/ell/checksum.h b/ell/checksum.h
index 531fcb0..3dab13f 100644
--- a/ell/checksum.h
+++ b/ell/checksum.h
@@ -48,6 +48,8 @@ struct l_checksum *l_checksum_new(enum l_checksum_type type);
 struct l_checksum *l_checksum_new_cmac_aes(const void *key, size_t key_len);
 struct l_checksum *l_checksum_new_hmac(enum l_checksum_type type,
 					const void *key, size_t key_len);
+struct l_checksum *l_checksum_new_hmac_from_key_id(enum l_checksum_type type,
+							int32_t key_id);
 struct l_checksum *l_checksum_clone(struct l_checksum *checksum);
 
 void l_checksum_free(struct l_checksum *checksum);
diff --git a/ell/ell.sym b/ell/ell.sym
index 414b288..08252b8 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -115,6 +115,7 @@ global:
 	l_checksum_new;
 	l_checksum_new_cmac_aes;
 	l_checksum_new_hmac;
+	l_checksum_new_hmac_from_key_id;
 	l_checksum_clone;
 	l_checksum_free;
 	l_checksum_reset;
-- 
2.34.3

