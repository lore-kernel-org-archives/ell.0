Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com [209.85.221.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E38631C2D
	for <ell@lists.linux.dev>; Tue, 20 Sep 2022 13:32:07 +0000 (UTC)
Received: by mail-wr1-f48.google.com with SMTP id bq9so4325744wrb.4
        for <ell@lists.linux.dev>; Tue, 20 Sep 2022 06:32:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=DUiwdwzhPJguHKXKA3ySWVT+9rY4F7aeUFf/xvB39Xw=;
        b=XAVlzRTNlGRgp4kMg2cUkb6TzIU04TzcxlND05l0qtk7DbWJE2JZKpzDXriQNzpILm
         FQhAH7D1V7rgfMmKmGbs+PcH6MRY+zdtcYwRMyu2Gtxb6zh1xvdRqv8mDO2Jgma4i1qr
         d/t1yWtQYrTwkdmOGe80kBUgRg86lhqXMK7D4tQWQPIL8Hh3wbfkPYcDSBp9/v+RXfCh
         SQRw++LUJLqFw+IB/gDJeEi7byJamOlGDny3IrrKMwxNyAAGK3cZo7LP2RXPw/AYqm+3
         PxjshWU7rgRnaTAdGaLDjxJ5rqbD3stEnSxS+59Ofwx80YF5+v90yxPQDlCGiUK7EhTp
         bphg==
X-Gm-Message-State: ACrzQf1N+7HThr8S13TPNcT11ZOHysP3evTznu3vlIb72faSulFi/ctL
	75v8ThZ3TJ3FpLqSGZY7ocovuIxyVAioKtJB
X-Google-Smtp-Source: AMsMyM7LxRfRLmaFVohEVL9ATeFJzi9lTzvea1mkvHFAbGy2j5gPrWT+5lXIxJbZk/kZGbzctn0DEQ==
X-Received: by 2002:a05:6000:1687:b0:22a:3516:4f98 with SMTP id y7-20020a056000168700b0022a35164f98mr14055871wrd.525.1663680725976;
        Tue, 20 Sep 2022 06:32:05 -0700 (PDT)
Received: from iss.ger.corp.intel.com ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id d16-20020adff2d0000000b0022863395912sm2082wrp.53.2022.09.20.06.32.05
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Sep 2022 06:32:05 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 2/6] unit: Update net_domain_list_parse test
Date: Tue, 20 Sep 2022 15:31:57 +0200
Message-Id: <20220920133201.3303119-2-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20220920133201.3303119-1-andrew.zaborowski@intel.com>
References: <20220920133201.3303119-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 unit/test-net.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/unit/test-net.c b/unit/test-net.c
index ff5d2b0..f3f1522 100644
--- a/unit/test-net.c
+++ b/unit/test-net.c
@@ -113,11 +113,13 @@ static void test_net_domain_list_parse(const void *data)
 	static const uint8_t l1[] = { 7, 'e', 'x', 'a', 'm', 'p', 'l', 'e',
 					3, 'c', 'o', 'm', 0,
 					4, 't', 'e', 's', 't', 0 };
-	static const uint8_t l2[] = { 0, 0};
+	static const uint8_t l2[] = { 0, 0 };
 	static const uint8_t l3[] = { 4, '.', '=', '2', '3', 0 };
+	static const uint8_t l4[] = { 7, 'e', 'x', 'a', 'm', 'p', 'l', 'e',
+					3, 'c', 'o', 'm', 0, 0 };
 	char **domains;
 
-	domains = net_domain_list_parse(l1, sizeof(l1));
+	domains = net_domain_list_parse(l1, sizeof(l1), false);
 	assert(domains);
 	assert(domains[0]);
 	assert(!strcmp(domains[0], "example.com"));
@@ -126,14 +128,21 @@ static void test_net_domain_list_parse(const void *data)
 	assert(!domains[2]);
 	l_strfreev(domains);
 
-	assert(!net_domain_list_parse(l2, sizeof(l2)));
+	assert(!net_domain_list_parse(l2, sizeof(l2), false));
 
-	domains = net_domain_list_parse(l3, sizeof(l3));
+	domains = net_domain_list_parse(l3, sizeof(l3), false);
 	assert(domains);
 	assert(domains[0]);
 	assert(!strcmp(domains[0], "\\.\\06123"));
 	assert(!domains[1]);
 	l_strfreev(domains);
+
+	domains = net_domain_list_parse(l4, sizeof(l4), true);
+	assert(domains);
+	assert(domains[0]);
+	assert(!strcmp(domains[0], "example.com"));
+	assert(!domains[1]);
+	l_strfreev(domains);
 }
 
 int main(int argc, char *argv[])
-- 
2.34.1

