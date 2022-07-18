Received: from mail-oo1-f50.google.com (mail-oo1-f50.google.com [209.85.161.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D90A0323F
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 16:08:36 +0000 (UTC)
Received: by mail-oo1-f50.google.com with SMTP id d12-20020a4aeb8c000000b004214e709b72so2363334ooj.6
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 09:08:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=kW99CkzG/sAtLGON6i1sEngEB0b9gBWe/XHcegnda2w=;
        b=g5Q2Jsh3gilmNrt6JhAWqusKih5NorGK4HzpiZZZw960CXDgZ8p9s6v+qGeQ3AovWo
         hpz4fiPCDtBKNrKjLGGU2srU0wPbR8r3CuyWXDB8pkciTQy8h0x4AlDTcjEMY3aeTmUk
         U9HhXU+61R0rgL6L8IC9w7+5hvXy6JWwK1p611s9R5CtwP9InOFjk91Vz3PAS0+pyc7P
         8YQ3FiMiSTemYA8Ce4KvZpw9PxT/Fb2lF1VSzKo3NKEpBybXgfzwASX1DGU8X9eFfwMn
         yRl3ob1WJb3+42JhsCGeOlPbH+7LTJm2JHwE+rUlZ59G3XSfxeHwYDkT8n2FnonWp8kk
         3bTA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=kW99CkzG/sAtLGON6i1sEngEB0b9gBWe/XHcegnda2w=;
        b=ED3XIXeOJ+rCvxDhWsLU+dI+ArfAOCj/UyxtK6FSi8W1JMWDIEDkBWkiH9nHP4OUbc
         yv/HzzWqA6a+7WU8C62Re1cK5KFkcg383tF+ma3WS+Qb7CmNS2RadALZiTOm7MLuCvV+
         b+qZvnfAwkU1O2i5POETn4bDI9IF9cmbCjK9V3xfVvZXEBAb4CUonqkLF34N+zniLOq6
         a1Mlfygl3T157v3WgilthfxtzOHS52KIZqwu7IUn+Fe+pVUCm3YngS40vooNi8hDBO+B
         JYRf8OpepF7ccdujxYog7+yIr/5ZKNBpIHboz8Pfs1DPs9uNqBZGEzSH6i3OVx2q8TfN
         bA1Q==
X-Gm-Message-State: AJIora9K44bMkNKUZzzQ7q0r2SOKxA1MrC9RVFWWycdb6DZRl34sjFyy
	VQ4Yv7d6MxQWRiq7w6IV5h6DWs+6Ht4=
X-Google-Smtp-Source: AGRyM1tqI1fxv/l+54Cy7mUf9Qg2eBcKrMDkV9K8Zw4IJUUjdm+OuW4c2La5xymxsg5bRI1GydmPCw==
X-Received: by 2002:a4a:b642:0:b0:435:46f0:8102 with SMTP id f2-20020a4ab642000000b0043546f08102mr9702127ooo.17.1658160515924;
        Mon, 18 Jul 2022 09:08:35 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id t19-20020a9d5913000000b0061cae832e5dsm297941oth.3.2022.07.18.09.08.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 09:08:35 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 3/9] key: ECDSA data is given in x962 format
Date: Mon, 18 Jul 2022 11:02:16 -0500
Message-Id: <20220718160222.10634-3-denkenz@gmail.com>
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

When using the verify operation with ECDSA based public keys, the new
format type must be used.
---
 ell/key.c | 12 +++++-------
 ell/key.h |  1 +
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index 73f38581f736..24374a5d836d 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -383,18 +383,16 @@ LIB_EXPORT ssize_t l_key_get_payload_size(struct l_key *key)
 
 static const char *lookup_cipher(enum l_key_cipher_type cipher)
 {
-	const char* ret = NULL;
-
 	switch (cipher) {
 	case L_KEY_RSA_PKCS1_V1_5:
-		ret = "pkcs1";
-		break;
+		return "pkcs1";
 	case L_KEY_RSA_RAW:
-		ret = "raw";
-		break;
+		return "raw";
+	case L_KEY_ECDSA_X962:
+		return "x962";
 	}
 
-	return ret;
+	return NULL;
 }
 
 static const char *lookup_checksum(enum l_checksum_type checksum)
diff --git a/ell/key.h b/ell/key.h
index f26f7ecb26c3..68971052ffde 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -56,6 +56,7 @@ enum l_keyring_restriction {
 enum l_key_cipher_type {
 	L_KEY_RSA_PKCS1_V1_5,
 	L_KEY_RSA_RAW,
+	L_KEY_ECDSA_X962,
 };
 
 struct l_key *l_key_new(enum l_key_type type, const void *payload,
-- 
2.35.1

