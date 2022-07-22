Received: from mail-pl1-f182.google.com (mail-pl1-f182.google.com [209.85.214.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5188015D6
	for <ell@lists.linux.dev>; Fri, 22 Jul 2022 20:30:07 +0000 (UTC)
Received: by mail-pl1-f182.google.com with SMTP id c6so5464155pla.6
        for <ell@lists.linux.dev>; Fri, 22 Jul 2022 13:30:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=FUT92SGbEh2cZE2scW3RdwHu9uZrPfWv3DZak050nNo=;
        b=EwmEIvzqCh7nbTtiHEdbClxr7hgzoGkLsprLkYi9CtyYWQfsnmUoUbMwlrzWbIiSJ2
         vildI3VmJvWmGn5jfebeyvTtz/jNQuQdOvt2NCfkyLnoBPLtHcD6hgNsvCcgsKttI2TF
         2I7h74AMuey8KSh6eN2RB3y/zm6C+LuJ1w0iPbqnAi07UiicKBUV0A2E7OLt57NLf8Ri
         UMNK5oguGEH0NyOLT8jbaqKJnH++fNpk4b5k7DzF4G0WPvOxj57CKfPbpjP+H52sUqie
         vQjUAV+r8XAzJJwyTuXkzYUXNWXmy3hs9DG7Zz1g3I4gtnl49wqyol2RV2X1Vu6LT4rN
         FSZg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=FUT92SGbEh2cZE2scW3RdwHu9uZrPfWv3DZak050nNo=;
        b=wseW60JybYMefO7X+4m1u2PSCy9AQIzMiA1HmL6IaZWTEosarvYiDsRJ6IiNAhw5dX
         7vX+iVvzzvAtTHB+RWAP1fU5bABYAXOqymvqDR3BgUXPY+mxF+k0KgxgQ7slxW4kQ5j/
         GdHxQAnAFnssN67tlaGiz1LEI05RpyaHN2742nqGvOxC6OQh5Exvr6pNPLbJYsz0hg5r
         6DdCZWCqn9M9fbj0q/zkJiw2EBtqf5o46h8hs+mBitsVFWm/Ap1TWzvokHivu6m6ahr5
         ck1OfN4CPpJ4FIK2Pq+4DXz+V4DREpvTpot/zNB9cYEyFB7CQITeE5Yui7oXiezAMsGK
         6tiA==
X-Gm-Message-State: AJIora8NORC43iTZTIh+8hm1qaK9naI0JUKc4y4HwfomcS2zgTMuYLAA
	OJIdaK0tMQuVmHkwO5VmcopRbc/z2fw=
X-Google-Smtp-Source: AGRyM1vmj4WaPgZXa0dcnTUt/8Cirnl5HkZujOH0wRRLX3SPIbAvTkOD0qHrFClOio71J/taAxJieg==
X-Received: by 2002:a17:902:b182:b0:16c:da9d:5e8b with SMTP id s2-20020a170902b18200b0016cda9d5e8bmr1561674plr.74.1658521806500;
        Fri, 22 Jul 2022 13:30:06 -0700 (PDT)
Received: from localhost.localdomain ([50.45.187.22])
        by smtp.gmail.com with ESMTPSA id q21-20020aa79835000000b0052ac12e7596sm4341170pfl.114.2022.07.22.13.30.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 22 Jul 2022 13:30:06 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 2/2] unit: add unit test for l_uintset_subtract
Date: Fri, 22 Jul 2022 13:27:47 -0700
Message-Id: <20220722202747.1193490-2-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20220722202747.1193490-1-prestwoj@gmail.com>
References: <20220722202747.1193490-1-prestwoj@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 unit/test-uintset.c | 54 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff --git a/unit/test-uintset.c b/unit/test-uintset.c
index 6e3767b..a097f0b 100644
--- a/unit/test-uintset.c
+++ b/unit/test-uintset.c
@@ -388,6 +388,59 @@ static void test_uintset_size(const void *user_data)
 	l_uintset_free(set);
 }
 
+static void test_uintset_subtract(const void *data)
+{
+	struct l_uintset *set_a = l_uintset_new_from_range(0, 10);
+	struct l_uintset *set_b = l_uintset_new_from_range(1, 11);
+	struct l_uintset *sub;
+
+	/* Some sanity checks */
+	assert(l_uintset_subtract(NULL, NULL) == NULL);
+	assert(l_uintset_subtract(set_a, set_b) == NULL);
+
+	l_uintset_free(set_a);
+	l_uintset_free(set_b);
+
+	set_a = l_uintset_new_from_range(0, 128);
+	set_b = l_uintset_new_from_range(0, 128);
+
+	/* (<empty>) - (<empty>) = (<empty>) */
+	sub = l_uintset_subtract(set_a, set_b);
+	assert(l_uintset_isempty(sub));
+	l_uintset_free(sub);
+
+	/* Sanity check this works across word boundaries */
+	l_uintset_put(set_b, 65);
+	l_uintset_put(set_b, 64);
+	l_uintset_put(set_b, 63);
+
+	/* (<empty>) - (65, 64, 63) = (<empty>) */
+	sub = l_uintset_subtract(set_a, set_b);
+	assert(!l_uintset_contains(sub, 64));
+	l_uintset_free(sub);
+
+	l_uintset_put(set_a, 64);
+
+	/* (64) - (65, 64, 63) = (<empty>) */
+	sub = l_uintset_subtract(set_a, set_b);
+	assert(!l_uintset_contains(sub, 64));
+	l_uintset_free(sub);
+
+	l_uintset_take(set_b, 64);
+
+	/* (64) - (65, 63) = (64) */
+	sub = l_uintset_subtract(set_a, set_b);
+	assert(l_uintset_contains(sub, 64));
+	l_uintset_free(sub);
+
+	/* (65, 63) - (64) = (65, 63) */
+	sub = l_uintset_subtract(set_b, set_a);
+	assert(l_uintset_contains(sub, 65));
+	assert(!l_uintset_contains(sub, 64));
+	assert(l_uintset_contains(sub, 63));
+	l_uintset_free(sub);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -407,6 +460,7 @@ int main(int argc, char *argv[])
 							&intersect_data_2);
 	l_test_add("l_uintset isempty", test_uintset_isempty, NULL);
 	l_test_add("l_uintset size", test_uintset_size, NULL);
+	l_test_add("l_uintset_subtract", test_uintset_subtract, NULL);
 
 	return l_test_run();
 }
-- 
2.34.1

