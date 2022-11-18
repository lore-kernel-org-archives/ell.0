Received: from mail-pg1-f172.google.com (mail-pg1-f172.google.com [209.85.215.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 25EDEA48B
	for <ell@lists.linux.dev>; Fri, 18 Nov 2022 21:16:40 +0000 (UTC)
Received: by mail-pg1-f172.google.com with SMTP id 130so6034237pgc.5
        for <ell@lists.linux.dev>; Fri, 18 Nov 2022 13:16:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=b3MhY5Dkv8FZ2EdJDG4v6fQgnFZHvUgwGe4CVer0pqg=;
        b=axLgn3M+4a67dxHj7Bgxu6+o1A8yPpI58U3Jj/cy/7r9XuKhvY4Bl7rhp0Srgk7L/V
         VViwiBILiU9WQDqZuRdpXVYb4MLCsjmkiqfmv1Acj44Pfk93seOsL/xxtjoYrsJ89DKq
         2Al4QtMsSOjNpUkxVsiHmdtUeh5M1wBACII1CjbLI8mgLQDBd5qgrrTcb3hGdo4WgoYw
         DlAkM32kocpVSO5HDwaf4ErRyLT5irAwYwlNUmgaSS8LZgqfzSYUrdUQnnzjeesT8UDc
         Ec2FrYU5myC2q2lyjYaRrCG36lxGrnA/IDhVtBHutfMaV/Ge//JaTYN5nzeeWOHtUwYm
         nj1w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=b3MhY5Dkv8FZ2EdJDG4v6fQgnFZHvUgwGe4CVer0pqg=;
        b=tmAj8C+TqWW4qVmtfS3h+JtdupPxPjZ3ulRO8idhEhg+S4k4I6W30rpqhDqf9Nqi+r
         KtC8GvG5nSEpIeQ7WdSUZEyhD2ARg169ncKg2osTcWegdXIQKtHKf8f6eCo/QaCnqX2z
         Py6h/WAa0Te8XnF+G7vfKgUWXW5KwR0EUcJ4khsIzflJ6jJkV0Dy2974zeuIXyJqAjYr
         EMmbCs+ORIximk99DKc/X+QetRQN6UzNXCcV9YKcv/PN707g7CKHEy6YNOeWZ5bhKysU
         OMMnPC/zKr5CdgJ76A5P+VHBlU/eOgBMt5HI0dLr60wgxosr1AwVYEhMw3UcuFJRBgzk
         NrfQ==
X-Gm-Message-State: ANoB5pmw+31bHSLFncvFlhjwZeQc3MIDzfnL41LW5brUEMO/VpIEZdqm
	2mF6DXOjDoGHl8tROr1ikE4tWk9icj8=
X-Google-Smtp-Source: AA0mqf5y8zb8A0qvpiOW3fYO5Bj8MN3PYipa5FkWUA5NQ0/vZhmkv+hgOw9M+Qu4sdv9ooWQ0QFTGA==
X-Received: by 2002:aa7:9159:0:b0:572:24c7:34da with SMTP id 25-20020aa79159000000b0057224c734damr9673122pfi.73.1668806199429;
        Fri, 18 Nov 2022 13:16:39 -0800 (PST)
Received: from jprestwo-xps.none ([50.39.160.234])
        by smtp.gmail.com with ESMTPSA id y12-20020aa79aec000000b0056ee49d6e95sm3630142pfp.86.2022.11.18.13.16.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 18 Nov 2022 13:16:39 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [RFC 1/8] key: add l_key_search
Date: Fri, 18 Nov 2022 13:16:17 -0800
Message-Id: <20221118211624.19298-2-prestwoj@gmail.com>
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

Search for a key by type, keyring name, and description. Returns the
key ID or an error if not found.
---
 ell/ell.sym |  1 +
 ell/key.c   | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 ell/key.h   |  3 +++
 3 files changed, 50 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 6df9024..414b288 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -387,6 +387,7 @@ global:
 	l_key_decrypt;
 	l_key_sign;
 	l_key_verify;
+	l_key_search;
 	l_keyring_new;
 	l_keyring_restrict;
 	l_keyring_free;
diff --git a/ell/key.c b/ell/key.c
index 24374a5..5a82531 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -270,6 +270,26 @@ static long kernel_key_verify(int32_t serial,
 	return result >= 0 ? result : -errno;
 }
 
+static long kernel_key_request(const char *type, const char *description)
+{
+	long result;
+
+	result = syscall(__NR_request_key, type, description, NULL, 0);
+
+	return result >= 0 ? result : -errno;
+}
+
+static long kernel_key_search(int32_t keyring_id, const char *type,
+				const char *description)
+{
+	long result;
+
+	result = syscall(__NR_keyctl, KEYCTL_SEARCH, keyring_id, type,
+				description, 0);
+
+	return result >= 0 ? result : -errno;
+}
+
 static bool setup_internal_keyring(void)
 {
 	internal_keyring = kernel_add_key("keyring", "ell-internal", NULL, 0,
@@ -283,6 +303,32 @@ static bool setup_internal_keyring(void)
 	return true;
 }
 
+LIB_EXPORT int32_t l_key_search(enum l_key_type type, const char *keyring,
+					const char *description)
+{
+	long keyring_id;
+	long key_id;
+
+	if (unlikely((size_t)type >= L_ARRAY_SIZE(key_type_names)))
+		return -EINVAL;
+
+	if (unlikely(!keyring || !description))
+		return -EINVAL;
+
+	/* Find the ID of the keyring */
+	keyring_id = kernel_key_request("keyring", keyring);
+	if (keyring_id < 0)
+		return -ENOENT;
+
+	/* Search for the key by type/description */
+	key_id = kernel_key_search(keyring_id, key_type_names[type],
+					description);
+	if (key_id < 0)
+		return -ENOENT;
+
+	return key_id;
+}
+
 LIB_EXPORT struct l_key *l_key_new(enum l_key_type type, const void *payload,
 					size_t payload_length)
 {
diff --git a/ell/key.h b/ell/key.h
index 6897105..5fe8e00 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -62,6 +62,9 @@ enum l_key_cipher_type {
 struct l_key *l_key_new(enum l_key_type type, const void *payload,
 			size_t payload_length);
 
+int32_t l_key_search(enum l_key_type type, const char *keyring,
+					const char *description);
+
 void l_key_free(struct l_key *key);
 void l_key_free_norevoke(struct l_key *key);
 
-- 
2.34.3

