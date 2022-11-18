Received: from mail-pj1-f50.google.com (mail-pj1-f50.google.com [209.85.216.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AEEE6A492
	for <ell@lists.linux.dev>; Fri, 18 Nov 2022 21:16:42 +0000 (UTC)
Received: by mail-pj1-f50.google.com with SMTP id h14so5549580pjv.4
        for <ell@lists.linux.dev>; Fri, 18 Nov 2022 13:16:42 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=KusMdMhGMdqC/lhe6s1xSGLhI9LFB4lCd0CO28FyslY=;
        b=MUTs2JIw+oqOnnud03x6uWP9BJ5jgxHn1D444+8INSZt4WgIxjncZiSa602egssly9
         mStTtK4Rd0swsmfzs54T8MDq1ezOaDwd9i1tVybHAl/Sf7SZzbEs+8YnsmXagkKd7LvJ
         ihm0hNbN8D/lpaNL6ntEXVs1izUochNtHgHmz3SWl9A5tPI/F+QzImvte8CkhEUcLT7J
         aR4ITCITMwzO37r9ja74ZRPQJoODmUeSZGmtH09I9aQ5UqP0dGc99n1gcJNBUYZj8pe4
         q89cxbWCC7urWB/rYvuWCME52zai7Jscnux4G1nopcmibcEDuOh10XY1mF7G+Vn2oWdA
         YlOw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=KusMdMhGMdqC/lhe6s1xSGLhI9LFB4lCd0CO28FyslY=;
        b=5aXAG+utIlwmG+XjDns2pkOgQa6fTfG8MIZi8DzWGkzw2Ef8mYNXwR1Ge2uV30rp7q
         /cAFmNjXEre9sEaOogYgAJZ//7P58/A63Yuklp3Mi7fq11wqpn7ZEu31Bmemx/aZ++b8
         XH7TGFUyStDcKq9KRsqk+/wscUzt7JLHsF+y31ris2ybP8dtw0vnTuduqa0pJJfSa6jW
         T3lLMPYcz1niPX8Cov6sLkJmYVVVYso+R4BZ2Th7aOQPygY6vEBmuih59s3Sb3vFyDDF
         sm3EwaUXgrkB+FpRm7XxayHm6LfyG+84MpLefI3T0Z0xpoahm5DYzBddy5NT0inVRibM
         qr4g==
X-Gm-Message-State: ANoB5pkFyF9xo6K2Amm9DsN2q2uUjWUaV2FJ8Yj8Jj9re1fIeOxbVKbG
	gaqQPC2akZyy63V6Co9WDi5PzW7WtiM=
X-Google-Smtp-Source: AA0mqf6NPTYyBJZrwdQ1LhKrKqw2it/AwRWM2ZJ9oyRPTOH3yuPGCbMuamDqzQbpSXQhwThxqvjZwQ==
X-Received: by 2002:a17:902:ab41:b0:187:4738:bf85 with SMTP id ij1-20020a170902ab4100b001874738bf85mr1274555plb.94.1668806202031;
        Fri, 18 Nov 2022 13:16:42 -0800 (PST)
Received: from jprestwo-xps.none ([50.39.160.234])
        by smtp.gmail.com with ESMTPSA id y12-20020aa79aec000000b0056ee49d6e95sm3630142pfp.86.2022.11.18.13.16.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 18 Nov 2022 13:16:41 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [RFC 5/8] cert-crypto: refactor l_cert_pkcs5_pbkdf2
Date: Fri, 18 Nov 2022 13:16:21 -0800
Message-Id: <20221118211624.19298-6-prestwoj@gmail.com>
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

This makes the actual algorithm common to prepare for adding a
new variant which uses a key ID rather than password.
---
 ell/cert-crypto.c | 67 +++++++++++++++++++++++++++++------------------
 1 file changed, 41 insertions(+), 26 deletions(-)

diff --git a/ell/cert-crypto.c b/ell/cert-crypto.c
index e6e8876..bf748b0 100644
--- a/ell/cert-crypto.c
+++ b/ell/cert-crypto.c
@@ -103,44 +103,34 @@ LIB_EXPORT bool l_cert_pkcs5_pbkdf1(enum l_checksum_type type,
 	return !iter_count;
 }
 
-/* RFC8018 section 5.2 */
-LIB_EXPORT bool l_cert_pkcs5_pbkdf2(enum l_checksum_type type,
-					const char *password,
-					const uint8_t *salt, size_t salt_len,
-					unsigned int iter_count,
-					uint8_t *out_dk, size_t dk_len)
+static size_t cert_checksum_to_length(enum l_checksum_type type)
 {
-	size_t h_len;
-	struct l_checksum *checksum;
-	unsigned int i;
-
 	switch (type) {
 	case L_CHECKSUM_SHA1:
-		h_len = 20;
-		break;
+		return 20;
 	case L_CHECKSUM_SHA224:
-		h_len = 28;
-		break;
+		return 28;
 	case L_CHECKSUM_SHA256:
-		h_len = 32;
-		break;
+		return 32;
 	case L_CHECKSUM_SHA384:
-		h_len = 48;
-		break;
+		return 48;
 	case L_CHECKSUM_SHA512:
-		h_len = 64;
-		break;
+		return 64;
 	case L_CHECKSUM_NONE:
 	case L_CHECKSUM_MD4:
 	case L_CHECKSUM_MD5:
-		return false;
+		return 0;
 	default:
-		return false;
+		return 0;
 	}
+}
 
-	checksum = l_checksum_new_hmac(type, password, strlen(password));
-	if (!checksum)
-		return false;
+static bool cert_pkcs5_pbkdf2(struct l_checksum *checksum, const uint8_t *salt,
+				size_t salt_len, size_t h_len,
+				unsigned int iter_count, uint8_t *out_dk,
+				size_t dk_len)
+{
+	unsigned int i;
 
 	for (i = 1; dk_len; i++) {
 		unsigned int j, k;
@@ -180,9 +170,34 @@ LIB_EXPORT bool l_cert_pkcs5_pbkdf2(enum l_checksum_type type,
 		dk_len -= block_len;
 	}
 
+	return !dk_len;
+}
+
+/* RFC8018 section 5.2 */
+LIB_EXPORT bool l_cert_pkcs5_pbkdf2(enum l_checksum_type type,
+					const char *password,
+					const uint8_t *salt, size_t salt_len,
+					unsigned int iter_count,
+					uint8_t *out_dk, size_t dk_len)
+{
+	size_t h_len;
+	struct l_checksum *checksum;
+	bool r;
+
+	h_len = cert_checksum_to_length(type);
+	if (!h_len)
+		return false;
+
+	checksum = l_checksum_new_hmac(type, password, strlen(password));
+	if (!checksum)
+		return false;
+
+	r = cert_pkcs5_pbkdf2(checksum, salt, salt_len, h_len, iter_count,
+				out_dk, dk_len);
+
 	l_checksum_free(checksum);
 
-	return !dk_len;
+	return r;
 }
 
 /* RFC7292 Appendix B */
-- 
2.34.3

