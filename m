Received: from mail-oa1-f43.google.com (mail-oa1-f43.google.com [209.85.160.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0FC3F33DE
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 18:07:16 +0000 (UTC)
Received: by mail-oa1-f43.google.com with SMTP id 586e51a60fabf-10c0119dd16so25857964fac.6
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 11:07:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=pMAzSKeE5FuNXbvrHPS5yhXcTBNmrECY11tiJECwGqc=;
        b=XHrdzhFSIcaRT7pS+5bBfsUq8Zo48H52Rhj0KxJYNg0OkEQHtlULcavTVAKpZ4QXkF
         6TQ8Ulsq+oXdOcyOQP5rhwDae7F8YsnWln5ySkpspVTpQlLf+MSQEQfmPFHw1Z9hwrZR
         6mMzzVZr+NgiCNA1QHzuiyRDjmoPv2kFYiDAdSvnuRuB/Ht1g1E4B7Yj8agS1GNiJnkb
         e7GpvOuYHrPPRFM5+1u0o0GO9S3E4Or4dOGRQOmPyomyQijlQe2sWQezq8OFojivtMB5
         4w9Eseau2v2EIPFrM6bRvGmPfBideKuY7FUG4yEnM2Ly97qev919lHBXYAn8b9WK+hG1
         aBIA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=pMAzSKeE5FuNXbvrHPS5yhXcTBNmrECY11tiJECwGqc=;
        b=L6YfqlL092Ou4vgD46GkPOZWtg5tkej75NhE8AlIDTE4WGG9cbsr3ZWJVtK/UVBCdW
         G4i14wGsfMikPSoN6wPaspUjMY1cE4226pxa81tFOAxnnK4xXmPoXmYeg8Rapo34k6o3
         LLWnIs8hTHhzUuMbY0qE/bsnOWf1PqpAjnuDsYLzZTfmdcnfr+GTgMb7LLjNcAPKUwIu
         PVhoGQDArESiInej5ngT2PhGllCJoOw+qTFNEGCGD9W0Vy3tMHZ0e/30eP6OgVrjcoR+
         iKpS8cq98g+pCWkgeU2PB7V2oAnLdlfFFDtUEWUaL95kDVSulGAf4E/AUR30U63gdAna
         GSQA==
X-Gm-Message-State: AJIora/Fam47H4dMvwMmd/8E59VOuJ9gEoDHXgpayk0+WiZFwf0iEWx3
	5Qbcf4dL3lNzOwawo574wF5+OgMKKmY=
X-Google-Smtp-Source: AGRyM1uV19TI4nAL9ELOZ+fn8tElTvt7t5Yy3NhTDKOiTO0G3JeK0DT8Z3l2uWO8E37wG9XIq+uQjQ==
X-Received: by 2002:a05:6808:e88:b0:337:9676:ddd4 with SMTP id k8-20020a0568080e8800b003379676ddd4mr13052181oil.9.1658167635052;
        Mon, 18 Jul 2022 11:07:15 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id n23-20020a056870559700b0010c727a3c79sm6808467oao.26.2022.07.18.11.07.14
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 11:07:14 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v2 08/10] unit: Skip ECDSA cipher suite tests
Date: Mon, 18 Jul 2022 13:00:43 -0500
Message-Id: <20220718180045.5845-8-denkenz@gmail.com>
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

Since ECDSA sign operation is currently not supported, ECDSA in server
mode cannot work.  Skip tests for these cipher suites for now.
---
 unit/test-tls.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index aee5b2e36b78..53d4f38ef875 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -1050,6 +1050,9 @@ int main(int argc, char *argv[])
 		struct tls_bulk_encryption_algorithm *alg = suite->encryption;
 		bool supported;
 
+		if (l_str_has_prefix(suite->name, "TLS_ECDHE_ECDSA"))
+			continue;
+
 		if (alg->cipher_type == TLS_CIPHER_AEAD)
 			supported = l_aead_cipher_is_supported(alg->l_aead_id);
 		else
-- 
2.35.1

