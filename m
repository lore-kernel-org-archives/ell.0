Received: from mail-wm1-f46.google.com (mail-wm1-f46.google.com [209.85.128.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3EDF6EC19
	for <ell@lists.linux.dev>; Wed,  9 Nov 2022 17:48:04 +0000 (UTC)
Received: by mail-wm1-f46.google.com with SMTP id ay14-20020a05600c1e0e00b003cf6ab34b61so1762451wmb.2
        for <ell@lists.linux.dev>; Wed, 09 Nov 2022 09:48:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=btXvHWHpOJr2vDz9YLufMHZU5H+n2bbSEHhPAt4jkVI=;
        b=DUnh0Dz+bmrGs2K6TE1tyTh4Frevb45kr7zSa5l6WoDZ+usa2SkIEC35nloJrxIJhm
         M8luPV3+BU3r7fSWnwF5KMXGIrA15LjkZTGLs/EHH1xhNfLbLGx7+fdrSc/9eiQvF5Oa
         YUndilOd5z5j4fD3Ri1lBhE+zyGLEiCAMU6SPudaVS/FOGmWLbmmV4bqiRsQJn7B1DeP
         LgMZU6ARIrzaZpsHopmhjvgLf2J4165daJrdBLU6etkCgDdNvUJjKeFrp7cVszHRMa4O
         I6NulJ+8+MAju2AH3gZfdc0/d53bO6hXbBFK2i6hUtAf8I8ZeLtoeQVfl/z/R72sBOyK
         VERw==
X-Gm-Message-State: ACrzQf2qSprr9Jnc1DQ9eOll2Z5fvxGhRAwwiREbORMeLOZZdjX9Q0kH
	V2S2FVzqPnzTGo8IvfwEE995PNGhTqk=
X-Google-Smtp-Source: AMsMyM5V2wyP1x3uKJVhdHZx/dYHez8NB+Pzex2RMuhpHtRZiZZcPjJrKYJs7L/yrTUji+seHZbsgg==
X-Received: by 2002:a05:600c:6d3:b0:3cf:9b42:b5f5 with SMTP id b19-20020a05600c06d300b003cf9b42b5f5mr19656360wmn.196.1668016082004;
        Wed, 09 Nov 2022 09:48:02 -0800 (PST)
Received: from localhost.localdomain ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id bh2-20020a05600005c200b002366d1cc198sm13934567wrb.41.2022.11.09.09.48.00
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 09 Nov 2022 09:48:00 -0800 (PST)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 4/4] tls: Add missing continue in tls_load_cached_server_session
Date: Wed,  9 Nov 2022 18:47:46 +0100
Message-Id: <20221109174746.569046-4-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20221109174746.569046-1-andrew.zaborowski@intel.com>
References: <20221109174746.569046-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

After we removed an expired session cache entry, move on to the next
entry in the loop.  Ignore the removed entry in the count, in the search
for the requested session ID, etc.  Not ignoring it would cause some
warnings to be logged later and other minor issues.
---
 ell/tls.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/tls.c b/ell/tls.c
index 2a8d509..d363765 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1084,6 +1084,7 @@ static bool tls_load_cached_server_session(struct l_tls *tls,
 					*group + prefix_len + 1);
 			l_settings_remove_group(tls->session_settings, *group);
 			changed = true;
+			continue;
 		}
 
 		cnt++;
-- 
2.34.1

