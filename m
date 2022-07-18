Received: from mail-oa1-f42.google.com (mail-oa1-f42.google.com [209.85.160.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0AABB33CC
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 16:08:38 +0000 (UTC)
Received: by mail-oa1-f42.google.com with SMTP id 586e51a60fabf-10c0d96953fso24954999fac.0
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 09:08:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=P8es6darHQSIrKvCc3RqVOFWWjrBgz6LjZJJi9XhwmQ=;
        b=aVCHnyEFF8RDAZEvpLFQNy57yAfFyDyLe6Tjp29WuvUz2XAiU2V+jtfKoKdzj34A4/
         0MZbpi41UHdcEeR6WxKtHYl3fhLPp9sCiJBjL74ltFXJnZ3F67SY/PwEwtTfsQfiBhEa
         u/uU7+TtImEbfWT1dXtlQLtToSfjqEDDRJaLuEjuwrllrLHLCGsImkptlge7Xlhp6gOI
         HvSAinmnRJmkw7tuJg3uHvV9Z7x7a6SIO3xN0VJK/OiXElhUAhaoIfC4mhusGKiB0X2V
         UWL6q/6dLB/X95OlHQ7DZE9dTLv++F2GETvAAptGViqYF70B3b0aQLhVEnhSw3Hmgbfu
         Msag==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=P8es6darHQSIrKvCc3RqVOFWWjrBgz6LjZJJi9XhwmQ=;
        b=GMPKJWXF7LgzZrcmlW2COI/TmkX919EDYDqAsiqYcWiy52Z1eJ5R5Mp3gl/GIylvfl
         7u1/9B+AVtBUgP4BfqJmjHeRxw/Fo3uG1Gu1p6rxUI9iyVUU44MXeBLie2ivb4+1ds1a
         QboCP/yZXhlxnDL0RPGEfhVYcdNJHclYoisIyhC/apWdETA48W1iyKBhYqOIzPPxhAt3
         07sQPw5stP2AiMlxmkIQF5YuDGi80F3Dry2HqTSZLre+EMo+nHj9kkMOBSseWyFQqKDG
         meYkUUscVGwpMOa3BOLljzlYazuTSk2FAcT5g5b4/QrxshhIBj3tJWPuGYzN51JniOsr
         OnCQ==
X-Gm-Message-State: AJIora+YLPrSFHXYTxCa3iSCSmK2j4Vv3D7w+sSK7ckg/hM3D0uCxOdC
	kD7bdXBwnKJK/sgP2Iico/XLjbLDF9I=
X-Google-Smtp-Source: AGRyM1t/oiug6TZ2t6t2Djq6Pn6tnak0avBWqcBv8qsnZ98dbeCAdWn70a/lMnzgK0yXVN47a4QnWA==
X-Received: by 2002:a05:6808:186:b0:33a:71a1:a753 with SMTP id w6-20020a056808018600b0033a71a1a753mr3406211oic.49.1658160517990;
        Mon, 18 Jul 2022 09:08:37 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id t19-20020a9d5913000000b0061cae832e5dsm297941oth.3.2022.07.18.09.08.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 09:08:37 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 6/9] tls: Add helper to find hash function by id
Date: Mon, 18 Jul 2022 11:02:19 -0500
Message-Id: <20220718160222.10634-6-denkenz@gmail.com>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220718160222.10634-1-denkenz@gmail.com>
References: <20220718160222.10634-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Instead of open-coding a loop to map the hash id from
SignatureAndHashAlgorithm structure to a supported hash function.
---
 ell/tls-suites.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index d5d2ec8f741f..bc6a756422b3 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -47,6 +47,17 @@ enum signature_algorithm {
 	SIGNATURE_ALGORITHM_ECDSA = 3,
 };
 
+static enum handshake_hash_type find_hash_by_id(uint8_t id)
+{
+	enum handshake_hash_type hash;
+
+	for (hash = 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
+		if (tls_handshake_hash_data[hash].tls_id == id)
+			break;
+
+	return hash;
+}
+
 /*
  * Sanitize DigitallySigned struct input, making sure the lengths
  * are valid and correspond to what we expect.
@@ -182,11 +193,7 @@ static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t in_len,
 	}
 
 	if (tls->negotiated_version >= L_TLS_V12) {
-		enum handshake_hash_type hash;
-
-		for (hash = 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
-			if (tls_handshake_hash_data[hash].tls_id == in[0])
-				break;
+		enum handshake_hash_type hash = find_hash_by_id(in[0]);
 
 		if (hash == __HANDSHAKE_HASH_COUNT) {
 			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
-- 
2.35.1

