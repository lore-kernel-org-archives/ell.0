Received: from mail-pj1-f47.google.com (mail-pj1-f47.google.com [209.85.216.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CB573A48C
	for <ell@lists.linux.dev>; Fri, 18 Nov 2022 21:16:40 +0000 (UTC)
Received: by mail-pj1-f47.google.com with SMTP id d13-20020a17090a3b0d00b00213519dfe4aso6206625pjc.2
        for <ell@lists.linux.dev>; Fri, 18 Nov 2022 13:16:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=0wbuZwTsW+RnqzysL9+lXZ9CR85j4jNiYwD8RAd8HhI=;
        b=NinPkjFWcOEBloTHcdnGVQodc5q9CwjkzXoan8gdYO33yhaXzXiarTgBWXWJ9SwhaD
         b5NG1BiuyMKts9QtEarViWO8X0TUSUb//o8tQOcJelsSWgUnHOktfLs5qZtLJSmOEbR1
         49o9DEvMPd2ZcGlURfMgYtbytaK7LZEdxJj6TxLSFBLDq7zqVZZ90ACvKAQwxl4qEB5q
         XMNa8T+PMHFSpRc4Gw0TjlVeW0eTcf0b09d2BaKPpYCVjPBS/4L+uKEiKh3lIk8QQlWt
         PAReUjxSb5aX1TZPrEGlDmVgbWYZrv6vZ4mnd+PkJZwNC9COPBr7/510gjodLFtH5VZx
         jMIA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=0wbuZwTsW+RnqzysL9+lXZ9CR85j4jNiYwD8RAd8HhI=;
        b=v1k7+AgIznHuLxj18vW+Go2v6aRC7qym8SOR0u/S4SxSgPXhdR6g3jac4ghf0wmEzw
         iRk0aP65M1y2bzmXt4EJpoS1RB4WRMV/zkj1la+JbAHQ8SiAAzOxpNvIQurjLLm89bxw
         g4EIAvibcdA0HTCKNcbC/FdiQmCq5Er7tvCgftWEmw0cE6ZHER4dRhl/Cu666oQrkJcb
         gZIu4qHvNoNvJBd5IhvuyyM6DyQioE54lNuEKm1JWE5JSBwxQTgrJbzMGydToaD3Mu2e
         /yEtVLo1+aXZes9NJb6PO9T1A/HaezKgUUAv1aM47vRfXbteh3/8byN+3EOp49d5CVZ2
         ZzQw==
X-Gm-Message-State: ANoB5plF3JkZknVxuNU4jY2ephfcESJUTWarPZG8FxIxt3fGLzHFRaSF
	yimmJvMJMY5BHRBejp6Kl3ifkNgtNkg=
X-Google-Smtp-Source: AA0mqf44yKZc0X9Y47NOK1FqSeIaTspvRO4PwSLEadonHsy04877ZpaOSIErYwWV8ikf9rAH4HTU9A==
X-Received: by 2002:a17:902:c3cc:b0:186:acb1:891d with SMTP id j12-20020a170902c3cc00b00186acb1891dmr1109068plj.160.1668806200142;
        Fri, 18 Nov 2022 13:16:40 -0800 (PST)
Received: from jprestwo-xps.none ([50.39.160.234])
        by smtp.gmail.com with ESMTPSA id y12-20020aa79aec000000b0056ee49d6e95sm3630142pfp.86.2022.11.18.13.16.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 18 Nov 2022 13:16:39 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [RFC 2/8] unit: add key search test
Date: Fri, 18 Nov 2022 13:16:18 -0800
Message-Id: <20221118211624.19298-3-prestwoj@gmail.com>
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

Creates a keyring and key using syscall directly as this is the
intended use case of l_key_search() (keys outside of ELL). Then
verifies that l_key_search() returns the same ID as the created key.
---
 unit/test-key.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/unit/test-key.c b/unit/test-key.c
index 240a02c..0e09cf4 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -24,6 +24,9 @@
 #include <config.h>
 #endif
 
+#include <sys/syscall.h>
+#include <linux/keyctl.h>
+#include <unistd.h>
 #include <assert.h>
 
 #include <ell/ell.h>
@@ -661,6 +664,27 @@ static void test_key_crypto(const void *data)
 	l_key_free(pubkey);
 }
 
+static void test_key_search(const void *data)
+{
+	long keyring_id;
+	long key_id;
+
+	/*
+	 * Search is used to find a key out side of ELL's internal keyring. So
+	 * manually create a keyring/key here rather than using l_key APIs
+	 */
+
+	keyring_id = syscall(__NR_add_key, "keyring", "my-keyring", NULL,
+				0, KEY_SPEC_USER_KEYRING);
+	assert(keyring_id >= 0);
+
+	key_id = syscall(__NR_add_key, "user", "my-key",
+				KEY1_STR, KEY1_LEN, keyring_id);
+	assert(key_id >= 0);
+
+	assert(key_id == l_key_search(L_KEY_RAW, "my-keyring", "my-key"));
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -685,5 +709,7 @@ int main(int argc, char *argv[])
 	if (l_key_is_supported(L_KEY_FEATURE_CRYPTO))
 		l_test_add("key crypto", test_key_crypto, NULL);
 
+	l_test_add("key search", test_key_search, NULL);
+
 	return l_test_run();
 }
-- 
2.34.3

