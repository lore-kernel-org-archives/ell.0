Received: from mail-oo1-f46.google.com (mail-oo1-f46.google.com [209.85.161.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E31AB1BBBE5
	for <ell@lists.linux.dev>; Thu, 31 Oct 2024 16:19:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1730391574; cv=none; b=gNbDiHFb+ekVXwDQ1hIkmUbeXL4CZLCzzal1TKZAs30deOTJoIGOX+UX4XPAv5Ii+duQEXDnks40WiNDYOajUqZ5yY7cYD5SS9oq82jajpbg+lIsD0BNlfjhJMOIzC+Iu6QOv0L8kS44mH6LiEZGTKdCosZkYk7KLZXikLW65XY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1730391574; c=relaxed/simple;
	bh=bKIBXUZcGgZBPK8AQ1WafBBvTvnGBy+Q/TmIwWI6uLY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=oYOjh9Hd7ji24puT+v04mbz7I37uWk6xwSL/8i5N8IlHvMhMFKgCqh3uHfCAnznaVOLKQoBhwVzY52eN8yFytlK7MAqQI4+Ge7O5JZIbWkklHefHZZ/gJRpQXcRL2/W+vRUNAQMAzOW+Rlw1gp2q5vG20OX8DVNsz3tL9mTIsUE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=EGFaBkfW; arc=none smtp.client-ip=209.85.161.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EGFaBkfW"
Received: by mail-oo1-f46.google.com with SMTP id 006d021491bc7-5ebbfcab9f4so583480eaf.2
        for <ell@lists.linux.dev>; Thu, 31 Oct 2024 09:19:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1730391572; x=1730996372; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Q+XhyLzw3GzoKzkcm8+lIuLmW/g0FgLmJNEl8bLP6ZI=;
        b=EGFaBkfWb5XqeGC9X5eStSzMLwEk8j63fKFEK89Ahr9JJJD9ZUYBX13PXuBEIWrYdC
         4nsiV+Vwr9ZTEXVwTuji5ZKC6L/1Sua48nkrcbB0d28xxJJKt77oPcmMWLALpcLPhJ8p
         7a5q6oFb8SlEG4E9Yl2Xeip8v0gIjgSKp3gzjj3v+GPPoYUGvIlxCKy/8Up6hOZg1kWg
         64PBEIseERBCAkRjBjcLrJs86uADUXjFquTiJY2yfzE2sENOizKnfMNCGZq1jFj865ne
         lMbIvR9nw0pBOj60v7EJNGV4vlO8qClXQDWQjM4owDOKHqKvaIu5hd6DwnGJcOvsEpR2
         4E1A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1730391572; x=1730996372;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=Q+XhyLzw3GzoKzkcm8+lIuLmW/g0FgLmJNEl8bLP6ZI=;
        b=byllcni8t6X/NfCfHjTOf6R6FUI6hQ67ahUHfZaKwZ/VW0cVgZ9sZyFsbVOK1fGo7X
         r8e0v9wqxss/x1thz4fBk9TaCIh5Ia0DrEQYubYdA+hFqH1SgUdi90VLcshJ0eiAFgxO
         LHnpYDrmODdyjnEdQWtu+u1FyBKmE2QuPyQqGC22AZAZpUL57R5vAgaDJKELtM0jYoeD
         wWLisYbpLIZA+0ArA1WUvuXV8rCdJOBjvSvlOP6mSF1BmLVMqxaWdSsLJx5gDPh9o4/i
         RWsGHUA5SyKShotyGWBFeOJC5tBoM1KgOzHYgm0vvpSkcpC+Cjt1Lb/h+kDM2sh5jfRB
         Uk2A==
X-Gm-Message-State: AOJu0Yxrn0hKIryMZltEHvhlwp6qfZvgfWUBlx2ibqk0HyCNpj+eoZ9u
	Lth03a2EDUKx8k5Mzug/1VX13ogB8MvzslIj1lcWaS0NGdi2Yf4OliurOQ==
X-Google-Smtp-Source: AGHT+IGmzIwDpPz2nSBHROIeGPfZ68hKzjE5OLtG+5zwo+ROdkLkMCE/BP4HkXDSJusOq3axwYuAuQ==
X-Received: by 2002:a05:6820:617:b0:5e7:cb2e:e01c with SMTP id 006d021491bc7-5ec6db74a13mr2204186eaf.7.1730391571773;
        Thu, 31 Oct 2024 09:19:31 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5ec70509a9fsm349337eaf.23.2024.10.31.09.19.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 31 Oct 2024 09:19:31 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v2 2/2] unit: Add l_safe_memcpy test
Date: Thu, 31 Oct 2024 11:19:18 -0500
Message-ID: <20241031161928.1514776-2-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
In-Reply-To: <20241031161928.1514776-1-denkenz@gmail.com>
References: <20241031161928.1514776-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 unit/test-util.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/unit/test-util.c b/unit/test-util.c
index 341c790c3731..4d4e2e91a47c 100644
--- a/unit/test-util.c
+++ b/unit/test-util.c
@@ -288,6 +288,16 @@ static void test_roundup_pow_of_two(const void *test_data)
 	}
 }
 
+static void test_safe_memcpy(const void *test_data)
+{
+	static const uint8_t src[] = { 0x00, 0xff, 0xff, 0xff };
+	uint8_t dst[10];
+
+	assert(l_safe_memcpy(dst, src, sizeof(src)) == dst);
+	assert(l_safe_memcpy(dst, src, 0) == dst);
+	assert(l_safe_memcpy(dst, NULL, 0) == dst);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -313,5 +323,7 @@ int main(int argc, char *argv[])
 
 	l_test_add("roundup_pow_of_two", test_roundup_pow_of_two, NULL);
 
+	l_test_add("l_safememcpy", test_safe_memcpy, NULL);
+
 	return l_test_run();
 }
-- 
2.45.2

