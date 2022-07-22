Received: from mail-pg1-f174.google.com (mail-pg1-f174.google.com [209.85.215.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E368715C9
	for <ell@lists.linux.dev>; Fri, 22 Jul 2022 20:30:06 +0000 (UTC)
Received: by mail-pg1-f174.google.com with SMTP id 23so5260351pgc.8
        for <ell@lists.linux.dev>; Fri, 22 Jul 2022 13:30:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=njq2ipD94Ut/QZ1/O4vJ57zqDi79K0XW9sUZnNRFwd4=;
        b=Iw71uBZ3uqFsW7iyNi49Ub+wbcwjKkYgWbCebC4G159Sl+PqRqweWBkkhuZwnFg1GM
         UDmflVf2tmAmHXR/rwHoDbcdYx/d+pP8Zp/eBH+1sgOeqXBdr3Rexm6yno9Ir4CbUfYJ
         R+CXWi8FCjGemuZnO/M3JbgJnmk6KmgxWiUQVjrorumAda1R6Orc3NjWxyMTFVLHnq4w
         LjyTFyZrdUuOhpo4PfVlbbe9nqR8SIbcBxsl0fMf6+zQ0r7nYCnbR5lwaBfhtbhvYdqD
         CqUWtI76urpwmDv1XlqXU/t/4tjxeC3gZlUut9zF1RFMDjp0kvj/PiHy0eZmquKtm4Iq
         poWg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=njq2ipD94Ut/QZ1/O4vJ57zqDi79K0XW9sUZnNRFwd4=;
        b=asw/lYYiL5zvWGquqj9Unz111gkon3Av9kR8E5L0i9fRJyBI4svc/XhiTqEByrmno0
         nVEDfVVVkqhYD1KSAIArFyDjjVLEtY5DkpuJK+AIisltlbvERS1LGbHGOBoGXQ15suWU
         2Hf9gAp7wXCZu7v3zL22ki2qjvaRswd3uMECco8xF/mGewNFuB/MYqvLpDQ/chdoqatQ
         W8UVe/vC97CTuuJ2am6BtVKJGxV3ohZ1A7i9cwtXJ4+nz9iSjwqa/1jZrK2TuJFNmhqI
         JgrQ00pJTZwvGJyKZlY//w9cIylDkBbKjct4ls1bOErI24lIAhpVod/Ud5NIdG4STMcC
         3WuA==
X-Gm-Message-State: AJIora/3NbanLxaTquCzC6BfeHmrdI1Myfb3IkKHXb1VWrwW2vvlGOKP
	UNigxgb6MxQrcuhG9oJOmztkr61qgQU=
X-Google-Smtp-Source: AGRyM1t68U4/mP1JuG6s2h6S9ze2nVohjeFhtnRELUCbofmfA49UUnTvR8HxCHbB36ogMUsvebja/g==
X-Received: by 2002:a05:6a00:450d:b0:52a:c1a3:9286 with SMTP id cw13-20020a056a00450d00b0052ac1a39286mr1464407pfb.63.1658521805887;
        Fri, 22 Jul 2022 13:30:05 -0700 (PDT)
Received: from localhost.localdomain ([50.45.187.22])
        by smtp.gmail.com with ESMTPSA id q21-20020aa79835000000b0052ac12e7596sm4341170pfl.114.2022.07.22.13.30.05
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 22 Jul 2022 13:30:05 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 1/2] uintset: add l_uintset_subtract
Date: Fri, 22 Jul 2022 13:27:46 -0700
Message-Id: <20220722202747.1193490-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This subtracts set_b from set_a, and returns the new set.
---
 ell/ell.sym   |  1 +
 ell/uintset.c | 37 +++++++++++++++++++++++++++++++++++++
 ell/uintset.h |  3 +++
 3 files changed, 41 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 8f4e59d..f454921 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -537,6 +537,7 @@ global:
 	l_uintset_foreach;
 	l_uintset_clone;
 	l_uintset_intersect;
+	l_uintset_subtract;
 	l_uintset_isempty;
 	l_uintset_size;
 	/* uuid */
diff --git a/ell/uintset.c b/ell/uintset.c
index 863bc56..4837bcf 100644
--- a/ell/uintset.c
+++ b/ell/uintset.c
@@ -532,6 +532,43 @@ LIB_EXPORT struct l_uintset *l_uintset_intersect(const struct l_uintset *set_a,
 	return intersection;
 }
 
+/**
+ * l_uintset_subtract:
+ * @set_a: The set of numbers
+ * @set_b: The set of numbers to subtract from set_a
+ *
+ * Subtracts two sets of numbers of an equal base, e.g.:
+ * l_uintset_get_min(set_a) must be equal to l_uintset_get_min(set_b) and
+ * l_uintset_get_max(set_a) must be equal to l_uintset_get_max(set_b)
+ *
+ * Returns: A newly allocated l_uintset containing set_a - set_b
+ */
+LIB_EXPORT struct l_uintset *l_uintset_subtract(const struct l_uintset *set_a,
+						const struct l_uintset *set_b)
+{
+	struct l_uintset *subtraction;
+	uint32_t offset;
+	uint32_t offset_max;
+
+	if (unlikely(!set_a || !set_b))
+		return NULL;
+
+	if (unlikely(set_a->min != set_b->min || set_a->max != set_b->max))
+		return NULL;
+
+	subtraction = l_uintset_new_from_range(set_a->min, set_a->max);
+
+	offset_max = (set_a->size + BITS_PER_LONG - 1) / BITS_PER_LONG;
+
+	/* Subtract by: set_a & ~set_b */
+	for (offset = 0; offset < offset_max; offset++) {
+		subtraction->bits[offset] =
+				set_a->bits[offset] & ~(set_b->bits[offset]);
+	}
+
+	return subtraction;
+}
+
 /**
  * l_uintset_isempty
  * @set: The set of numbers
diff --git a/ell/uintset.h b/ell/uintset.h
index aa9de48..86ce8f7 100644
--- a/ell/uintset.h
+++ b/ell/uintset.h
@@ -60,6 +60,9 @@ void l_uintset_foreach(const struct l_uintset *set,
 struct l_uintset *l_uintset_clone(const struct l_uintset *original);
 struct l_uintset *l_uintset_intersect(const struct l_uintset *set_a,
 						const struct l_uintset *set_b);
+struct l_uintset *l_uintset_subtract(const struct l_uintset *set_a,
+						const struct l_uintset *set_b);
+
 bool l_uintset_isempty(const struct l_uintset *set);
 uint32_t l_uintset_size(const struct l_uintset *set);
 
-- 
2.34.1

