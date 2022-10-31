Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com [209.85.128.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5494220F4
	for <ell@lists.linux.dev>; Mon, 31 Oct 2022 10:54:01 +0000 (UTC)
Received: by mail-wm1-f41.google.com with SMTP id l32so6900384wms.2
        for <ell@lists.linux.dev>; Mon, 31 Oct 2022 03:54:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=ag5o6vvBojQ+euAPrNyhySDM/H5orXN7bSa4P5V6CjU=;
        b=eGPRqR11UR2C7lLiJzKnU/EZXuG2xaxX3gkuR3w7+a/bDzVz/cNi0CWKQD8c02smWG
         pUF9PclffA+dTX2P3m+BzWTwpGLH9E24FSyIWbXJEC1CsVARCpXfqtu6rYyddJ83dkUk
         JHlzLuP/GAnRuI8D/2Nyelzm3fjLuiGubqye/WAZr7WHTfmccNUDfnUxYm5XivJbyX+3
         5HIGm+FA8kuHdqMDf14cNO+VOIFYairQXroLdDHGXXHs+RufLQADQuBaCIur9eWXaoRc
         oj5r+XNm5sweXUzi+1XEVHIYriO9aGk19Thnm4YlG8ykCUGzTuy+IziZb/bnfocP4+OP
         HV2A==
X-Gm-Message-State: ACrzQf3OOOgY1rdWbejrCe5Wctm045jzdnShhiKJ8tHRkOg4SC1D1BrF
	th9sXkUhn4kLubqzmEuVjqgdDKEAC/4=
X-Google-Smtp-Source: AMsMyM6x6X2SQREuZbrs4tcRLix3NnJ4jhMpNYlrpxRWSST/gCpVTBmMNGuOVTfEuBwju08Sh2Y6yQ==
X-Received: by 2002:a05:600c:4e45:b0:3cd:f141:b7d8 with SMTP id e5-20020a05600c4e4500b003cdf141b7d8mr7560910wmq.196.1667213638525;
        Mon, 31 Oct 2022 03:53:58 -0700 (PDT)
Received: from localhost.localdomain ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id ay19-20020a5d6f13000000b00236b2804d79sm6890737wrb.2.2022.10.31.03.53.57
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 31 Oct 2022 03:53:57 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 4/4] unit: Minimal l_certchain_verify validity dates test
Date: Mon, 31 Oct 2022 11:53:42 +0100
Message-Id: <20221031105342.2660357-4-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20221031105342.2660357-1-andrew.zaborowski@intel.com>
References: <20221031105342.2660357-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 unit/test-tls.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 53d4f38..e089859 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -231,7 +231,10 @@ static void test_certificates(const void *data)
 	struct l_queue *wrongca;
 	struct l_queue *wrongca2;
 	struct l_queue *twocas;
+	struct l_cert *expired;
+	struct l_queue *mixedcas;
 	struct l_certchain *chain;
+	struct l_certchain *expiredchain;
 
 	cacert = l_pem_load_certificate_list(CERTDIR "cert-ca.pem");
 	assert(cacert && !l_queue_isempty(cacert));
@@ -245,9 +248,18 @@ static void test_certificates(const void *data)
 	twocas = l_pem_load_certificate_list(CERTDIR "cert-chain.pem");
 	assert(twocas);
 
+	mixedcas = l_pem_load_certificate_list(CERTDIR "cert-chain.pem");
+	assert(mixedcas);
+	expired = load_cert_file(CERTDIR "cert-expired.pem");
+	assert(expired);
+	l_queue_push_tail(mixedcas, expired);
+
 	chain = l_pem_load_certificate_chain(CERTDIR "cert-server.pem");
 	assert(chain);
 
+	expiredchain = l_pem_load_certificate_chain(CERTDIR "cert-expired.pem");
+	assert(expiredchain);
+
 	assert(!l_certchain_verify(chain, wrongca, NULL));
 	assert(l_certchain_verify(chain, cacert, NULL));
 	assert(l_certchain_verify(chain, NULL, NULL));
@@ -294,6 +306,7 @@ static void test_certificates(const void *data)
 	assert(l_certchain_verify(chain, cacert, NULL));
 	assert(l_certchain_verify(chain, NULL, NULL));
 	assert(l_certchain_verify(chain, twocas, NULL));
+	assert(l_certchain_verify(chain, mixedcas, NULL));
 
 	l_certchain_free(chain);
 	l_queue_destroy(cacert, (l_queue_destroy_func_t) l_cert_free);
@@ -317,12 +330,17 @@ static void test_certificates(const void *data)
 	assert(l_certchain_verify(chain, cacert, NULL));
 	assert(l_certchain_verify(chain, NULL, NULL));
 	assert(!l_certchain_verify(chain, twocas, NULL));
+	assert(!l_certchain_verify(chain, mixedcas, NULL));
+
+	assert(!l_certchain_verify(expiredchain, NULL, NULL));
 
 	l_certchain_free(chain);
+	l_certchain_free(expiredchain);
 	l_queue_destroy(cacert, (l_queue_destroy_func_t) l_cert_free);
 	l_queue_destroy(wrongca, (l_queue_destroy_func_t) l_cert_free);
 	l_queue_destroy(wrongca2, (l_queue_destroy_func_t) l_cert_free);
 	l_queue_destroy(twocas, (l_queue_destroy_func_t) l_cert_free);
+	l_queue_destroy(mixedcas, (l_queue_destroy_func_t) l_cert_free);
 }
 
 static void test_ec_certificates(const void *data)
-- 
2.34.1

