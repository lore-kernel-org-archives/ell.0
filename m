Received: from mail-wr1-f54.google.com (mail-wr1-f54.google.com [209.85.221.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5E4F71374
	for <ell@lists.linux.dev>; Wed, 26 Oct 2022 13:16:14 +0000 (UTC)
Received: by mail-wr1-f54.google.com with SMTP id v1so26253625wrt.11
        for <ell@lists.linux.dev>; Wed, 26 Oct 2022 06:16:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=jqO+uUyC/hSlQWB1J+6q6J4rMTCbxcK8qLrE/OAWUj4=;
        b=mw58TLEgamQTLO4bDqqim0nH8/5/ZfA7k/M2Q23wGt51SQsrP3QqwWiPLENnvhvY2T
         ved6kfA2zcKvscemSFJmFVMX8osPI5QxXOnCMzbNLz0V6bASe8lnYl4jRLAX7kWpKhd6
         eerzvnytLrmUkYxfZrzTDTJZfxk8jBRYflwnON/kA6xYs3tMGRMDMXcipDPjTAnBZOgb
         edo5dASlmOKIRvMi9rwSmQ7UTBoESMakodZDToMCTu1q9emrXqPNykc+LwL0temnKj6g
         cfsHExd29vco18yX3RH4YM/zGiMS/3Ad54y53lulHxDVd11jSCKQF0YcTP4bK0iFMgW0
         vXiA==
X-Gm-Message-State: ACrzQf0024IpJzMEvW4avlnfzgdQdXRQxz4GLCWuQ2pNbSclWf51GWEd
	+5dAunr2Pq0flI/TEWpJ9gWeyfLx6M4=
X-Google-Smtp-Source: AMsMyM4iDRhNoOHzfsAr42PAQoMrdm8dg86/YHrsgyORsJ200wZD33CgahzFmKJ3+ucOTAwGcDDCbg==
X-Received: by 2002:adf:e711:0:b0:236:2f7f:4f08 with SMTP id c17-20020adfe711000000b002362f7f4f08mr22392343wrm.375.1666790172014;
        Wed, 26 Oct 2022 06:16:12 -0700 (PDT)
Received: from localhost.localdomain ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id x23-20020a05600c21d700b003a83ca67f73sm1934771wmj.3.2022.10.26.06.16.10
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 26 Oct 2022 06:16:10 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 3/6] tls: Fix an RFC reference
Date: Wed, 26 Oct 2022 15:15:55 +0200
Message-Id: <20221026131558.2393488-3-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20221026131558.2393488-1-andrew.zaborowski@intel.com>
References: <20221026131558.2393488-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/tls-extensions.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/tls-extensions.c b/ell/tls-extensions.c
index 6154df0..7796825 100644
--- a/ell/tls-extensions.c
+++ b/ell/tls-extensions.c
@@ -785,7 +785,7 @@ ssize_t tls_parse_signature_algorithms(struct l_tls *tls,
 	return ptr + len - buf;
 }
 
-/* RFC 5462, Section 7.4.1.4.1 */
+/* RFC 5246, Section 7.4.1.4.1 */
 static ssize_t tls_signature_algorithms_client_write(struct l_tls *tls,
 						uint8_t *buf, size_t len)
 {
-- 
2.34.1

