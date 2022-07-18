Received: from mail-ot1-f51.google.com (mail-ot1-f51.google.com [209.85.210.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D6AC333DF
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 18:07:16 +0000 (UTC)
Received: by mail-ot1-f51.google.com with SMTP id br15-20020a056830390f00b0061c9d73b8bdso3719184otb.6
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 11:07:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Jj8SzOc4fPGKTCmDSCizZ0kMBR+BMY1DeLBui51Bxng=;
        b=m8uA5HUPka495onoTbfVOGwD8mBVbNizflUEo5OqIgNU+2N87c4IXEY3XVK3qwEUjj
         cudYF8QXtQHrnNYLPSwGvV1wwRED69folGkw4Vx2aqJc73OKsmmCmP20XgL/sR23jwFH
         QaSL2AtWlnKJbr7yFsOCh1R+TTNkA/Cot/Z1YZl2uU8C9VZo/fsIRbhJW0SCTwfO7mCc
         32G93OOBKmwQg+HTq0/f1nEl+k0SblhJVFH0DKhounqZLP2jhghPHJmFG2cXJ/fSgoOw
         /Cxi19lcGTHxARlzej70IjWQ0EF8RktJui5SQffQy8dExh+UA3A1mCey+frNkDPBtc2A
         E25w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Jj8SzOc4fPGKTCmDSCizZ0kMBR+BMY1DeLBui51Bxng=;
        b=qwHDer9BckyERxbCWPmFVi0TZFwynKYZwMIJ8VZVun/T8kmz/i4tVlLG0Y85ruOklq
         yac5DKzHpm+ukBtn9T1K0y2qg3EXb69Jx/9v9nQigWduJIorXNN34b1/Ev2rxZoDGnNz
         BHOYCEidRMnnoCGydAaz7fQDgwUKnfGqcfdRrXk2adXCV7H3cBK4qz+DlG8MTghmNkG9
         8J/a0ZInDucH6o+tIRapE/Uhx9EDh/fkYNF0whq+ldY5CG9pA4COJ7m3Vj0U7VGmMe1o
         CJz9gcFkD2vZ1gLMuT60NjvF0A9Fq1pKkO1rraGbABwHWAtOdbWsEmfOCagPvm20mOJN
         4JOA==
X-Gm-Message-State: AJIora8Cu2TxcEgpIKyCsgMdJcMjqk0M8CdjnphsWBRYEpbKO+HUmeAw
	//J6hfMj+0zVILJsIZD9UBAtdjjobjE=
X-Google-Smtp-Source: AGRyM1tKUw9kATb878hT+PGD2UCYqjiyLjjtanEVKPPOEJDj1nnBe7L9cyqDilWXsZUUUBZDOjE+8g==
X-Received: by 2002:a05:6830:248c:b0:61c:98a2:105d with SMTP id u12-20020a056830248c00b0061c98a2105dmr4446760ots.158.1658167635742;
        Mon, 18 Jul 2022 11:07:15 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id n23-20020a056870559700b0010c727a3c79sm6808467oao.26.2022.07.18.11.07.15
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 11:07:15 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v2 09/10] useful: Add maxsize()
Date: Mon, 18 Jul 2022 13:00:44 -0500
Message-Id: <20220718180045.5845-9-denkenz@gmail.com>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220718180045.5845-1-denkenz@gmail.com>
References: <20220718180045.5845-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Similar to minsize(), but for finding the maximum of two sizes
---
 ell/useful.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/ell/useful.h b/ell/useful.h
index 791fa2006494..efd91d78b3f2 100644
--- a/ell/useful.h
+++ b/ell/useful.h
@@ -38,6 +38,14 @@ static inline size_t minsize(size_t a, size_t b)
 	return b;
 }
 
+static inline size_t maxsize(size_t a, size_t b)
+{
+	if (a >= b)
+		return a;
+
+	return b;
+}
+
 static inline void set_bit(void *addr, unsigned int bit)
 {
 	unsigned char *field = addr;
-- 
2.35.1

